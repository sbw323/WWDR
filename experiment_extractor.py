#!/usr/bin/env python3
"""Extract experiment windows anchored by normalized energy-use signals."""

from __future__ import annotations

import argparse
import logging
import math
import re
from pathlib import Path
from typing import Optional, Sequence

import pandas as pd

LOGGER = logging.getLogger(__name__)

DEFAULT_INPUT = Path(
    "/Users/ikai/github/WWDR-Databases/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/normalized_outputs_new"
)
DEFAULT_OUTPUT = Path(
    "/Users/ikai/github/WWDR-Databases/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/extracted_experiments_normalized"
)
DEFAULT_ANCHOR_COLUMN = "ticker"
ENERGY_PATTERN = re.compile(r"energy_use_R([3-5])_normalized", re.IGNORECASE)
DEFAULT_THRESHOLD = 1.0
DEFAULT_WINDOW_DAYS = 3


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def _resolve_anchor_series(df: pd.DataFrame, *, anchor_col: str) -> pd.Series:
    if anchor_col not in df.columns:
        raise ValueError(f"Anchor column '{anchor_col}' not found in dataset.")

    series = pd.to_numeric(df[anchor_col], errors="coerce")
    if series.isna().all():
        timestamps = pd.to_datetime(df[anchor_col], errors="coerce")
        if timestamps.isna().all():
            raise ValueError(
                f"Anchor column '{anchor_col}' could not be parsed as numeric or datetime."
            )
        series = timestamps.view("int64") / (1e9 * 60 * 60 * 24)  # days as float
    return series


def detect_first_anchor(
    df: pd.DataFrame,
    *,
    anchor_col: str,
    threshold: float = DEFAULT_THRESHOLD,
) -> Optional[int]:
    """Find the first anchor where any energy-use normalized column drops below the threshold."""
    energy_columns = [col for col in df.columns if ENERGY_PATTERN.fullmatch(str(col))]
    if not energy_columns:
        LOGGER.warning("No normalized energy-use columns (R3–R5) found; skipping anchor detection.")
        return None

    anchor_series = _resolve_anchor_series(df, anchor_col=anchor_col)
    energy_df = pd.DataFrame({col: pd.to_numeric(df[col], errors="coerce") for col in energy_columns})
    mask = (energy_df < threshold).any(axis=1)
    if not mask.any():
        return None

    first_index = mask.idxmax()
    if not mask.loc[first_index]:
        return None
    first_anchor = anchor_series.loc[first_index]
    if pd.isna(first_anchor):
        return None
    return int(math.floor(first_anchor))


def extract_windows(
    df: pd.DataFrame,
    *,
    anchor_col: str,
    start_anchor: int,
    window_days: int = DEFAULT_WINDOW_DAYS,
) -> list[tuple[int, pd.DataFrame]]:
    """Extract sequential windows starting at start_anchor and stepping by window_days."""
    anchor_series = _resolve_anchor_series(df, anchor_col=anchor_col)
    windows: list[tuple[int, pd.DataFrame]] = []

    max_anchor = anchor_series.max()
    anchor = start_anchor
    while anchor <= max_anchor:
        window_start = anchor
        window_end = anchor + window_days
        mask = (anchor_series >= window_start) & (anchor_series <= window_end)
        window_df = df.loc[mask].copy()
        if not window_df.empty:
            window_df[anchor_col] = anchor_series[mask]
            window_df["window_anchor"] = anchor
            windows.append((anchor, window_df))
        anchor += window_days
    return windows


def process_file(
    path: Path,
    *,
    output_dir: Path,
    timestamp_col: str,
    suffix: str,
    anchor_col: str,
    window_days: int,
    threshold: float,
) -> None:
    LOGGER.info("Extracting windows from %s", path.name)
    df = pd.read_csv(path)
    start_anchor = detect_first_anchor(df, anchor_col=anchor_col, threshold=threshold)
    if start_anchor is None:
        LOGGER.warning("No experiment anchors detected in %s; skipping.", path.name)
        return

    windows = extract_windows(df, anchor_col=anchor_col, start_anchor=start_anchor, window_days=window_days)
    if not windows:
        LOGGER.warning("Anchor windows produced no rows for %s", path.name)
        return

    output_dir.mkdir(parents=True, exist_ok=True)
    for start, window_df in windows:
        output_path = output_dir / f"{path.stem}_start{start}{suffix}{path.suffix}"
        window_df.to_csv(output_path, index=False)
        LOGGER.info("Wrote %s", output_path)


def iter_csv_files(root: Path) -> list[Path]:
    return sorted(p for p in root.glob("*.csv") if p.is_file())


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract the first three days of experiment data from normalized outputs."
    )
    parser.add_argument(
        "--input-dir",
        type=Path,
        default=DEFAULT_INPUT,
        help="Directory containing normalized experiment CSV files.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="Directory where extracted windows will be saved.",
    )
    parser.add_argument(
        "--timestamp-col",
        default="timestamp",
        help="Name of the timestamp column (default: timestamp).",
    )
    parser.add_argument(
        "--anchor-col",
        default=DEFAULT_ANCHOR_COLUMN,
        help=f"Column used to anchor windows (default: {DEFAULT_ANCHOR_COLUMN}).",
    )
    parser.add_argument(
        "--suffix",
        default="_window",
        help="Suffix to append to the output filenames (default: _window).",
    )
    parser.add_argument(
        "--energy-threshold",
        type=float,
        default=DEFAULT_THRESHOLD,
        help="Threshold for energy-use normalized drop signalling experiment start (default: 1.0).",
    )
    parser.add_argument(
        "--window-days",
        type=int,
        default=DEFAULT_WINDOW_DAYS,
        help="Number of days to include after each experiment start (default: 3).",
    )
    parser.add_argument(
        "--loglevel",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity.",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> None:
    args = parse_arguments(argv)
    configure_logging(args.loglevel)

    input_dir = args.input_dir.expanduser().resolve()
    output_dir = args.output_dir.expanduser().resolve()

    if not input_dir.exists():
        raise FileNotFoundError(f"Input directory not found: {input_dir}")

    csv_files = iter_csv_files(input_dir)
    if not csv_files:
        LOGGER.warning("No CSV files found in %s", input_dir)
        return

    for csv_path in csv_files:
        try:
            process_file(
                csv_path,
                output_dir=output_dir,
                timestamp_col=args.timestamp_col,
                suffix=args.suffix,
                anchor_col=args.anchor_col,
                window_days=args.window_days,
                threshold=args.energy_threshold,
            )
        except Exception as exc:  # pragma: no cover - defensive
            LOGGER.error("Failed to extract window from %s: %s", csv_path.name, exc)


if __name__ == "__main__":
    main()
