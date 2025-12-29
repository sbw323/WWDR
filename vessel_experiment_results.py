#!/usr/bin/env python3
"""
Generate experiment-window averages for reactor datasets using normalized energy signals.

The pipeline:
1. Scans a normalized dataset directory for reactor CSVs.
2. Parses reactor number, duration, day start, and energy reduction fraction from filenames.
3. Detects experiment windows by locating energy_use_R#_normalized equal to the reduction factor,
   then advances by fixed stagger intervals.
4. Computes mean values for configured columns per window.
5. Writes one flattened summary CSV per reactor (R3–R5).
"""

from __future__ import annotations

import argparse
import logging
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Optional, Sequence

import pandas as pd

INPUT_DIR = Path("naive_stacked_data/with_snh4_norm/")
OUTPUT_DIR = Path("naive_stacked_data/with_snh4_norm/vessel_experiment_results/")
TARGET_REACTORS = (3, 4, 5)
TIMESTEP_LEN = 4
TIMESTEP_DAY = 24 * TIMESTEP_LEN
EXP_DAYS = 3
INDEX_STAGGER = EXP_DAYS * TIMESTEP_DAY
TICKER_COLUMN = "ticker"
WINDOW_ROWS = 192

AVERAGE_COLUMNS = [
    "SNH4_inf_nom",
    "SNH4_nom_norm",
    "SNH4_nomdiff_norm",
]
SETTLER_TARGET_COLUMNS = [
    "SNH4_inf_norm",
    "SNH4_inf_nom",
    "SNH4_nom_norm",
    "SNH4_nomdiff_norm",
]

COMMON_PATTERN = re.compile(
    r"(?P<prefix>reactor(?P<reactor>\d+)|settler)_"
    r"(?P<duration>\d+)(?P<unit>h|hr|d|day)_"
    r"day(?P<day>\d+)"
    r"(?:_red(?P<reduc>[\d\.]+)pct)?",
    re.IGNORECASE,
)


LOGGER = logging.getLogger(__name__)


@dataclass(frozen=True)
class DatasetMeta:
    path: Path
    reactor: Optional[int]
    duration_hours: int
    day_start: int
    energy_reduc: float
    is_settler: bool = False

    @property
    def energy_column(self) -> str:
        if self.reactor is None:
            raise ValueError("Reactor ID is required to build energy column name.")
        return f"energy_use_R{self.reactor}_normalized"


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def parse_file_meta(filename: str) -> Optional[DatasetMeta]:
    """Parse metadata for reactor or settler datasets."""
    match = COMMON_PATTERN.search(filename)
    if not match:
        return None

    prefix = match.group("prefix").lower()
    is_settler = prefix.startswith("settler")
    reactor_str = match.group("reactor")
    reactor = int(reactor_str) if reactor_str else None

    duration_value = int(match.group("duration"))
    unit = match.group("unit").lower()
    day_start = int(match.group("day"))
    reduc_str = match.group("reduc")
    energy_reduc = float(reduc_str) if reduc_str is not None else 1.0

    if unit in {"h", "hr"}:
        duration_hours = duration_value
    else:
        duration_hours = duration_value * 24

    return DatasetMeta(
        path=Path(filename),
        reactor=reactor,
        duration_hours=duration_hours,
        day_start=day_start,
        energy_reduc=energy_reduc,
        is_settler=is_settler,
    )


def duration_to_timesteps(duration_hours: int) -> int:
    return duration_hours * TIMESTEP_LEN


def detect_experiment_windows(df: pd.DataFrame, meta: DatasetMeta) -> list[tuple[int, int]]:
    """Locate sequential experiment windows using energy reduction markers."""
    if meta.energy_column not in df.columns:
        LOGGER.warning("%s: energy column %s not found; skipping.", meta.path.name, meta.energy_column)
        return []

    energy_series = pd.to_numeric(df[meta.energy_column], errors="coerce")
    tol = 1e-4
    first_matches = (energy_series > meta.energy_reduc - tol) & (energy_series < meta.energy_reduc + tol)
    if not first_matches.any():
        return []

    first_index = int(first_matches[first_matches].index[0])

    start = first_index
    windows: list[tuple[int, int]] = []

    while start < len(df):
        end = start + WINDOW_ROWS - 1
        windows.append((start, end))
        start += INDEX_STAGGER

    return windows


def resolve_average_columns(df: pd.DataFrame) -> list[str]:
    """Return target columns, mapping SNH4_inf_nom to SNH4_inf_norm when needed."""
    resolved: list[str] = []
    for col in AVERAGE_COLUMNS:
        if col in df.columns:
            resolved.append(col)
            continue
        if col == "SNH4_inf_nom" and "SNH4_inf_norm" in df.columns:
            LOGGER.debug("Using SNH4_inf_norm in place of missing SNH4_inf_nom.")
            resolved.append("SNH4_inf_norm")
            continue
        LOGGER.warning("Target column %s missing; it will be skipped.", col)
    return resolved


def resolve_max_column_mappings(df: pd.DataFrame, target_columns: Sequence[str]) -> list[tuple[str, str]]:
    """Return list of (source_col, output_name) for max computations with fallbacks."""
    mappings: list[tuple[str, str]] = []
    for col in target_columns:
        if col in df.columns:
            mappings.append((col, col))
            continue
        if col == "SNH4_inf_nom" and "SNH4_inf_norm" in df.columns:
            mappings.append(("SNH4_inf_norm", "SNH4_inf_norm"))
        elif col == "SNH4_inf_norm" and "SNH4_inf_nom" in df.columns:
            mappings.append(("SNH4_inf_nom", "SNH4_inf_norm"))
    return mappings


def compute_window_means(
    df: pd.DataFrame,
    windows: Sequence[tuple[int, int]],
    columns: Sequence[str],
    *,
    meta: DatasetMeta,
    ticker_col: str = TICKER_COLUMN,
) -> list[dict[str, float]]:
    ticker_available = ticker_col in df.columns
    if not ticker_available:
        LOGGER.warning("%s: ticker column '%s' missing; start tickers will be NaN.", meta.path.name, ticker_col)

    records: list[dict[str, float]] = []
    for start, end in windows:
        window_df = df.iloc[start : end + 1]
        row: dict[str, float] = {
            "duration": meta.duration_hours,
            "energy_reduc": meta.energy_reduc,
        }
        if ticker_available:
            row["experiment_start_ticker"] = window_df.iloc[0][ticker_col]
        else:
            row["experiment_start_ticker"] = float("nan")
        for col in columns:
            row[f"avg_{col}"] = window_df[col].mean()
        records.append(row)
    return records


def compute_window_maxes(
    df: pd.DataFrame,
    windows: Sequence[tuple[int, int]],
    column_mappings: Sequence[tuple[str, str]],
    *,
    meta: DatasetMeta,
) -> list[dict[str, float]]:
    records: list[dict[str, float]] = []
    for idx, (start, end) in enumerate(windows):
        window_df = df.iloc[start : end + 1]
        row: dict[str, float] = {
            "reactor": meta.reactor if meta.reactor is not None else -1,
            "duration_hr": meta.duration_hours,
            "energy_reduc": meta.energy_reduc,
            "window_index": idx,
            "window_start": start,
            "window_end": end,
        }
        for src_col, out_col in column_mappings:
            if src_col in window_df.columns:
                row[f"max_{out_col}"] = window_df[src_col].max()
        records.append(row)
    return records


def extract_settler_windows(
    settler_df: pd.DataFrame,
    windows: Sequence[tuple[int, int]],
    column_mappings: Sequence[tuple[str, str]],
    *,
    reactor: int,
    duration_hr: int,
    energy_reduc: float,
) -> list[dict[str, float]]:
    results: list[dict[str, float]] = []
    for idx, (start, end) in enumerate(windows):
        window_df = settler_df.iloc[start : end + 1]
        entry: dict[str, float] = {
            "reactor": reactor,
            "duration_hr": duration_hr,
            "energy_reduc": energy_reduc,
            "window_index": idx,
            "window_start": start,
            "window_end": end,
        }
        for src_col, out_col in column_mappings:
            if src_col in window_df.columns:
                entry[f"max_{out_col}"] = window_df[src_col].max()
        results.append(entry)
    return results


def load_vessel_results_lookup(path: Path) -> dict[tuple[int, int, float], list[tuple[int, int]]]:
    df = pd.read_csv(path)
    required_cols = {"reactor", "duration_hr", "energy_reduc", "window_start", "window_end"}
    if not required_cols.issubset(df.columns):
        raise ValueError(f"{path} missing required columns {required_cols}")
    lookup: dict[tuple[int, int, float], list[tuple[int, int]]] = {}
    for _, row in df.iterrows():
        key = (int(row["reactor"]), int(row["duration_hr"]), float(row["energy_reduc"]))
        lookup.setdefault(key, []).append((int(row["window_start"]), int(row["window_end"])))
    return lookup


def process_settler_companion_data(
    settler_folder: Path,
    reactor_results: dict[tuple[int, int, float], list[tuple[int, int]]],
    target_columns: Sequence[str],
    output_dir: Path,
) -> pd.DataFrame:
    settler_files = iter_csv_files(settler_folder)
    records: list[dict[str, float]] = []

    for path in settler_files:
        meta = parse_file_meta(path.name)
        if not meta or not meta.is_settler:
            continue
        matching_keys = [
            key for key in reactor_results if key[1] == meta.duration_hours and abs(key[2] - meta.energy_reduc) < 1e-9
        ]
        if not matching_keys:
            continue
        matching_keys.sort(key=lambda k: k[0])
        key = matching_keys[0]
        windows = reactor_results[key]
        df = pd.read_csv(path)
        mappings = resolve_max_column_mappings(df, target_columns)
        if not mappings:
            LOGGER.info("No settler columns available for %s; skipping.", path.name)
            continue
        records.extend(
            extract_settler_windows(
                df,
                windows,
                mappings,
                reactor=key[0],
                duration_hr=key[1],
                energy_reduc=key[2],
            )
        )

    if records:
        df_out = build_reactor_dataframe(records)
        output_path = output_dir / "settler_experiment_results_MAX.csv"
        df_out.to_csv(output_path, index=False)
        LOGGER.info("Wrote %s (%d rows)", output_path, len(df_out))
        return df_out
    return pd.DataFrame()


def build_reactor_dataframe(records: Iterable[dict[str, float]]) -> pd.DataFrame:
    return pd.DataFrame(records)


def iter_csv_files(root: Path) -> list[Path]:
    return sorted(path for path in root.glob("*.csv") if path.is_file())


def run_pipeline(
    input_dir: Path = INPUT_DIR,
    output_dir: Path = OUTPUT_DIR,
    skip_energy_reduc: Sequence[float] | None = None,
    skip_settler_energy_reduc: Sequence[float] | None = None,
    settler_folder: Optional[Path] = None,
    settler_target_columns: Sequence[str] = SETTLER_TARGET_COLUMNS,
) -> None:
    input_dir = input_dir.expanduser().resolve()
    output_dir = output_dir.expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    files = iter_csv_files(input_dir)
    if not files:
        LOGGER.warning("No CSV files found in %s", input_dir)
        return

    metas: list[DatasetMeta] = []
    for csv_path in files:
        parsed = parse_file_meta(csv_path.name)
        if not parsed:
            continue
        meta = DatasetMeta(
            path=csv_path,
            reactor=parsed.reactor,
            duration_hours=parsed.duration_hours,
            day_start=parsed.day_start,
            energy_reduc=parsed.energy_reduc,
            is_settler=parsed.is_settler,
        )
        if meta.is_settler or (meta.reactor is not None and meta.reactor in TARGET_REACTORS):
            metas.append(meta)

    grouped_records = {reactor: [] for reactor in TARGET_REACTORS}
    start_tickers: set[float] = set()
    reactor_window_map: dict[tuple[int, int, float], list[tuple[int, int]]] = {}
    reactor_max_records: list[dict[str, float]] = []

    # Reactor processing
    for meta in metas:
        if meta.is_settler or meta.reactor not in TARGET_REACTORS:
            continue
        if skip_energy_reduc and any(abs(meta.energy_reduc - skip) < 1e-9 for skip in skip_energy_reduc):
            LOGGER.info(
                "Skipping %s due to energy reduction %.3f in skip list.",
                meta.path.name,
                meta.energy_reduc,
            )
            continue

        df = pd.read_csv(meta.path)
        windows = detect_experiment_windows(df, meta)
        if not windows:
            LOGGER.info("No windows detected for %s; skipping.", meta.path.name)
            continue

        reactor_window_map.setdefault((meta.reactor, meta.duration_hours, meta.energy_reduc), []).extend(windows)

        if TICKER_COLUMN in df.columns:
            ticker_series = pd.to_numeric(df[TICKER_COLUMN], errors="coerce")
            for start, _ in windows:
                if start < len(ticker_series):
                    tick = ticker_series.iloc[start]
                    if pd.notna(tick):
                        start_tickers.add(float(tick))
        else:
            LOGGER.warning("%s: ticker column '%s' missing; start tickers not recorded.", meta.path.name, TICKER_COLUMN)

        columns = resolve_average_columns(df)
        if not columns:
            LOGGER.info("No averageable columns present in %s; skipping.", meta.path.name)
            continue

        records = compute_window_means(df, windows, columns, meta=meta, ticker_col=TICKER_COLUMN)
        grouped_records[meta.reactor].extend(records)
        max_mappings = resolve_max_column_mappings(df, columns)
        if max_mappings:
            reactor_max_records.extend(compute_window_maxes(df, windows, max_mappings, meta=meta))

    for reactor, records in grouped_records.items():
        if not records:
            LOGGER.info("No records produced for reactor %d; skipping export.", reactor)
            continue
        df_out = build_reactor_dataframe(records)
        output_path = output_dir / f"reactor{reactor}_experiment_summary.csv"
        df_out.to_csv(output_path, index=False)
        LOGGER.info("Wrote %s (%d rows)", output_path, len(df_out))

    if start_tickers:
        ticker_df = pd.DataFrame(sorted(start_tickers), columns=[TICKER_COLUMN])
        start_ticker_path = output_dir / "reactor_window_start_tickers.csv"
        ticker_df.to_csv(start_ticker_path, index=False)
        LOGGER.info("Wrote %s (%d unique start tickers)", start_ticker_path, len(ticker_df))

    if reactor_max_records:
        reactor_max_df = build_reactor_dataframe(reactor_max_records)
        reactor_max_path = output_dir / "vessel_experiment_results_MAX.csv"
        reactor_max_df.to_csv(reactor_max_path, index=False)
        LOGGER.info("Wrote %s (%d rows)", reactor_max_path, len(reactor_max_df))

    settler_dir = settler_folder.expanduser().resolve() if settler_folder else input_dir
    if skip_settler_energy_reduc:
        # filter out windows for skipped reductions to avoid companion processing
        reactor_window_map = {
            key: val for key, val in reactor_window_map.items() if not any(abs(key[2] - s) < 1e-9 for s in skip_settler_energy_reduc)
        }
    settler_df = process_settler_companion_data(
        settler_dir,
        reactor_window_map,
        settler_target_columns,
        output_dir,
    )

    if reactor_max_records and not settler_df.empty:
        combined = pd.concat(
            [
                reactor_max_df.assign(dataset_type="reactor"),
                settler_df.assign(dataset_type="settler"),
            ],
            axis=0,
            ignore_index=True,
        )
        combined_path = output_dir / "combined_reactor_settler_MAX.csv"
        combined.to_csv(combined_path, index=False)
        LOGGER.info("Wrote %s (%d rows)", combined_path, len(combined))


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Compute experiment-window averages for reactor datasets."
    )
    parser.add_argument(
        "--input-dir",
        type=Path,
        default=INPUT_DIR,
        help="Directory containing normalized reactor CSV files.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=OUTPUT_DIR,
        help="Destination directory for summary CSV files.",
    )
    parser.add_argument(
        "--loglevel",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity.",
    )
    parser.add_argument(
        "--skip-energy-reduc",
        type=float,
        nargs="*",
        help="Energy reduction values to skip (e.g., 1.0).",
    )
    parser.add_argument(
        "--skip-settler-energy-reduc",
        type=float,
        nargs="*",
        help="Energy reduction values to skip for settler datasets (e.g., 1.0).",
    )
    parser.add_argument(
        "--settler-dir",
        type=Path,
        help="Directory containing settler CSV files (defaults to input-dir).",
    )
    parser.add_argument(
        "--settler-target-cols",
        nargs="*",
        help="Settler columns to compute max values for (default: same as reactor columns).",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> None:
    args = parse_arguments(argv)
    configure_logging(args.loglevel)
    run_pipeline(
        input_dir=args.input_dir,
        output_dir=args.output_dir,
        skip_energy_reduc=args.skip_energy_reduc,
        skip_settler_energy_reduc=args.skip_settler_energy_reduc,
        settler_folder=args.settler_dir,
        settler_target_columns=args.settler_target_cols or SETTLER_TARGET_COLUMNS,
    )


if __name__ == "__main__":
    main()
