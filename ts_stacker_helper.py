#!/usr/bin/env python3
"""
Core utilities for stacking time-series CSV files on a quarter-hour grid.

The vstack_timeseries_helper() function ingests one or more CSV files,
standardises/creates a timestamp index, intersects timestamps across all inputs,
then vertically stacks the aligned frames while recording which file each row
came from. The helper is intentionally strict: timestamps must fall exactly on
15-minute boundaries, and only the common timestamps across every input file
are retained in the final dataset.

The module also exposes a small CLI for one-off stacking and a couple of
lightweight smoke tests that exercise the core behaviour.
"""

from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Iterable, List, Optional, Sequence

try:
    import pandas as pd
except ImportError as exc:  # pragma: no cover - import guard
    raise SystemExit("pandas is required to run ts_stacker_helper. Install it with 'pip install pandas'.") from exc

LOGGER = logging.getLogger(__name__)

# All datasets are aligned to the same 15-minute cadence.
QUARTER_HOUR = pd.Timedelta(minutes=15)
BASE_TIMESTAMP = pd.Timestamp("2000-01-01 00:00:00")


class StackingError(RuntimeError):
    """Raised when alignment or stacking fails."""


def configure_logging(level: str) -> None:
    """Initialise module logging."""
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def _load_csv(path: Path, *, has_header: bool, delimiter: str) -> pd.DataFrame:
    header = 0 if has_header else None
    df = pd.read_csv(path, sep=delimiter, header=header)
    LOGGER.debug("Loaded %s with shape %s", path, df.shape)
    return df


def _create_timestamp_index(length: int, base: pd.Timestamp) -> pd.DatetimeIndex:
    """Generate a deterministic timestamp index spaced at 15-minute intervals."""
    return base + pd.timedelta_range(start=0, periods=length, freq=QUARTER_HOUR)


def _ensure_datetime_index(
    df: pd.DataFrame,
    *,
    path: Path,
    timestamp_column: Optional[str],
    generate_timestamps: bool,
    base_timestamp: pd.Timestamp,
) -> pd.DataFrame:
    """
    Return the DataFrame with a datetime index named 'timestamp'.

    If timestamp_column is provided (and present) it is used and dropped from the
    DataFrame. Otherwise, synthetic timestamps are generated when
    generate_timestamps is True. If neither condition is satisfied a StackingError
    is raised.
    """
    candidate: Optional[pd.Series] = None
    if timestamp_column and timestamp_column in df.columns:
        candidate = df.pop(timestamp_column)
    elif not generate_timestamps:
        # Fall back to the first column when synthetic timestamps are disabled.
        first_column = df.columns[0]
        candidate = df.pop(first_column)

    if candidate is not None:
        timestamps = pd.to_datetime(candidate, errors="coerce", utc=False)
        if timestamps.isna().all():
            raise StackingError(f"{path}: unable to parse timestamp column '{timestamp_column or first_column}'.")
        mask = ~timestamps.isna()
        if not mask.all():
            LOGGER.warning("%s: dropping %d row(s) with invalid timestamps.", path, (~mask).sum())
            df = df.loc[mask]
            timestamps = timestamps.loc[mask]
        df = df.copy()
        df.index = timestamps
        df.index.name = "timestamp"
        return df

    if generate_timestamps:
        generated_index = _create_timestamp_index(len(df), base_timestamp)
        df = df.copy()
        df.index = generated_index
        df.index.name = "timestamp"
        return df

    raise StackingError(
        f"{path}: no timestamp column available and synthetic timestamps disabled."
    )


def _filter_quarter_hour(df: pd.DataFrame, *, path: Path) -> pd.DataFrame:
    """Keep only rows aligned with the 15-minute grid."""
    mask = (
        (df.index.minute % 15 == 0)
        & (df.index.second == 0)
        & (df.index.microsecond == 0)
    )
    if not mask.all():
        dropped = (~mask).sum()
        LOGGER.warning("%s: dropping %d row(s) not on a 15-minute boundary.", path, dropped)
        df = df.loc[mask]
    if df.empty:
        raise StackingError(f"{path}: no quarter-hour aligned rows remain after filtering.")
    return df


def vstack_timeseries_helper(
    files: Sequence[Path],
    output_file: Path,
    *,
    type_key: str,
    timestamp_column: Optional[str] = None,
    delimiter: str = ",",
    has_header: bool = False,
    generate_timestamps: bool = True,
    base_timestamp: pd.Timestamp = BASE_TIMESTAMP,
    source_column: str = "source_id",
) -> Path:
    """
    Align and vertically stack CSV files that share a quarter-hour timestamp grid.

    Parameters
    ----------
    files:
        Sequence of CSV file paths to stack. All files must align on the 15-minute
        grid and share overlapping timestamps.
    output_file:
        Destination CSV path. Parent directories are created automatically.
    type_key:
        Identifier for the data type (e.g., "R1", "S"). Logged for context only.
    timestamp_column:
        Optional column name containing timestamps. When omitted the helper will
        generate synthetic timestamps spaced every 15 minutes.
    delimiter:
        CSV delimiter to pass to pandas.read_csv.
    has_header:
        Whether the CSV files include a header row.
    generate_timestamps:
        Generate standardised timestamps when True. When False, timestamps must be
        present in the CSV (either in `timestamp_column` or the first column).
    base_timestamp:
        Base timestamp used when generating synthetic timestamps.
    source_column:
        Name of the column that records the origin file per row.

    Returns
    -------
    Path
        The output_file path for convenience.
    """
    if not files:
        raise ValueError("No input files were supplied to vstack_timeseries_helper.")

    prepared_frames: List[pd.DataFrame] = []
    column_union: List[str] = []
    common_index: Optional[pd.DatetimeIndex] = None

    for path in files:
        df = _load_csv(path, has_header=has_header, delimiter=delimiter)
        df = _ensure_datetime_index(
            df,
            path=path,
            timestamp_column=timestamp_column,
            generate_timestamps=generate_timestamps,
            base_timestamp=base_timestamp,
        )
        df = _filter_quarter_hour(df, path=path)
        df = df[~df.index.duplicated(keep="first")].sort_index()

        for column in df.columns:
            column_name = str(column)
            if column_name not in column_union:
                column_union.append(column_name)
        if common_index is None:
            common_index = df.index
        else:
            common_index = common_index.intersection(df.index)

        prepared_frames.append(df)

    if common_index is None or common_index.empty:
        raise StackingError("No overlapping quarter-hour timestamps across supplied files.")

    ordered_columns = column_union
    stacked_frames: List[pd.DataFrame] = []
    for frame, path in zip(prepared_frames, files):
        aligned = frame.copy()
        aligned.columns = [str(col) for col in aligned.columns]
        aligned = aligned.reindex(common_index, columns=ordered_columns)
        missing_all = aligned.isna().all(axis=1).sum()
        if missing_all:
            LOGGER.warning(
                "%s: %d timestamp(s) contain only NaN after alignment; verify source data.",
                path,
                missing_all,
            )
        aligned = aligned.reset_index()
        aligned[source_column] = path.stem
        stacked_frames.append(aligned)

    stacked = pd.concat(stacked_frames, axis=0, ignore_index=True)
    stacked = stacked.sort_values(["timestamp", source_column]).reset_index(drop=True)

    output_file = output_file.expanduser().resolve()
    output_file.parent.mkdir(parents=True, exist_ok=True)
    stacked.to_csv(output_file, index=False)

    timestamp_series = pd.to_datetime(stacked["timestamp"])
    LOGGER.info(
        "Stacked %d file(s) for type %s -> %s (%d rows, %s to %s).",
        len(files),
        type_key,
        output_file,
        len(stacked),
        timestamp_series.min(),
        timestamp_series.max(),
    )
    return output_file


def _parse_cli(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Stack CSV files on quarter-hour timestamps, tagging each row with its source file."
    )
    parser.add_argument(
        "files",
        nargs="+",
        type=Path,
        help="CSV files to stack.",
    )
    parser.add_argument(
        "--output",
        type=Path,
        required=True,
        help="Destination CSV file.",
    )
    parser.add_argument(
        "--type-key",
        required=True,
        help="Identifier for the data type (e.g., R1, S).",
    )
    parser.add_argument(
        "--timestamp-column",
        help="Optional timestamp column name.",
    )
    parser.add_argument(
        "--delimiter",
        default=",",
        help="CSV delimiter (default: ',').",
    )
    parser.add_argument(
        "--has-header",
        action="store_true",
        help="Indicate that the CSVs contain a header row.",
    )
    parser.add_argument(
        "--no-generate-timestamps",
        action="store_true",
        help="Disable synthetic timestamp generation; CSVs must include timestamps.",
    )
    parser.add_argument(
        "--source-column",
        default="source_id",
        help="Name of the source identifier column in the output.",
    )
    parser.add_argument(
        "--loglevel",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity.",
    )
    parser.add_argument(
        "--run-smoke-tests",
        action="store_true",
        help="Execute module smoke tests instead of stacking.",
    )
    return parser.parse_args(argv)


def _smoke_test_alignment() -> None:
    """Ensure two CSV files align on the generated quarter-hour grid."""
    import tempfile

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        file_a = tmp_path / "reactor1.csv"
        file_b = tmp_path / "reactor1_variant.csv"
        # Create small datasets without headers to mimic raw exports.
        pd.DataFrame({"a": [1, 2, 3, 4]}).to_csv(file_a, index=False, header=False)
        pd.DataFrame({"a": [10, 20, 30, 40], "b": [100, 200, 300, 400]}).to_csv(
            file_b, index=False, header=False
        )

        output = tmp_path / "stacked.csv"
        vstack_timeseries_helper(
            [file_a, file_b],
            output,
            type_key="R1",
            has_header=False,
            generate_timestamps=True,
        )
        result = pd.read_csv(output)
        timestamps = pd.to_datetime(result["timestamp"])
        assert timestamps.dt.minute.isin([0, 15, 30, 45]).all(), "Timestamps should align to 15-minute grid."
        assert set(result["source_id"]) == {file_a.stem, file_b.stem}, "All sources must be preserved."


def _smoke_test_union_columns() -> None:
    """Verify that column unions are respected and missing values are preserved."""
    import tempfile

    with tempfile.TemporaryDirectory() as tmp:
        tmp_path = Path(tmp)
        file_a = tmp_path / "reactor1_iter1.csv"
        file_b = tmp_path / "reactor1_iter2.csv"
        pd.DataFrame({"x": [1, 2, 3]}).to_csv(file_a, index=False, header=False)
        pd.DataFrame({"y": [4, 5, 6]}).to_csv(file_b, index=False, header=False)

        output = tmp_path / "stacked.csv"
        vstack_timeseries_helper(
            [file_a, file_b],
            output,
            type_key="R1",
            has_header=False,
            generate_timestamps=True,
        )
        result = pd.read_csv(output)
        assert {"x", "y"}.issubset(result.columns), "Union of columns must be present."
        grouped = result.groupby("source_id")
        assert grouped.size().eq(3).all(), "Each source should contribute three rows after alignment."


def _run_smoke_tests() -> None:
    LOGGER.info("Running ts_stacker_helper smoke tests...")
    _smoke_test_alignment()
    _smoke_test_union_columns()
    LOGGER.info("All smoke tests passed.")


def main(argv: Optional[Sequence[str]] = None) -> None:
    args = _parse_cli(argv)
    configure_logging(args.loglevel)

    if args.run_smoke_tests:
        _run_smoke_tests()
        return

    vstack_timeseries_helper(
        args.files,
        args.output,
        type_key=args.type_key,
        timestamp_column=args.timestamp_column,
        delimiter=args.delimiter,
        has_header=args.has_header,
        generate_timestamps=not args.no_generate_timestamps,
        source_column=args.source_column,
    )


if __name__ == "__main__":
    main()
