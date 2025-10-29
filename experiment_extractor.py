#!/usr/bin/env python3
"""Extract the first three days of data from normalized stacked experiment outputs."""

from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Optional, Sequence

import pandas as pd

LOGGER = logging.getLogger(__name__)

DEFAULT_INPUT = Path(
    "/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/normalized_outputs_new"
)
DEFAULT_OUTPUT = Path(
    "/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/extracted_experiments_normalized"
)


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def extract_window(df: pd.DataFrame, *, timestamp_col: str) -> pd.DataFrame:
    if timestamp_col not in df.columns:
        raise ValueError(f"Timestamp column '{timestamp_col}' not found in dataset.")

    timestamps = pd.to_datetime(df[timestamp_col], errors="coerce")
    if timestamps.isna().all():
        raise ValueError("All timestamps are NaT after parsing; check input data.")

    anchor = timestamps.min().floor("D") + pd.Timedelta(days=3)
    window_start = anchor
    window_end = anchor + pd.Timedelta(days=3) - pd.Timedelta(minutes=15)

    mask = (timestamps >= window_start) & (timestamps <= window_end)
    extracted = df.loc[mask].copy()
    extracted[timestamp_col] = timestamps[mask]
    return extracted


def process_file(path: Path, *, output_dir: Path, timestamp_col: str, suffix: str) -> None:
    LOGGER.info("Extracting window from %s", path.name)
    df = pd.read_csv(path)
    subset = extract_window(df, timestamp_col=timestamp_col)
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"{path.stem}{suffix}{path.suffix}"
    subset.to_csv(output_path, index=False)
    if subset.empty:
        LOGGER.warning("Window extraction produced no rows for %s", path.name)
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
        "--suffix",
        default="_window",
        help="Suffix to append to the output filenames (default: _window).",
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
            process_file(csv_path, output_dir=output_dir, timestamp_col=args.timestamp_col, suffix=args.suffix)
        except Exception as exc:  # pragma: no cover - defensive
            LOGGER.error("Failed to extract window from %s: %s", csv_path.name, exc)


if __name__ == "__main__":
    main()
