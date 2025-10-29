#!/usr/bin/env python3
"""Plot normalized S_NH4 time-series grouped by source and start day."""

from __future__ import annotations

import numpy as np
import argparse
import logging
import re
from pathlib import Path
from typing import Dict, List, Optional, Sequence

import matplotlib.pyplot as plt
import pandas as pd

LOGGER = logging.getLogger(__name__)

DEFAULT_INPUT = Path(
    "/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/extracted_experiments_normalized"
)
DEFAULT_OUTPUT = Path(
    "/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/plots_normalized_nh4"
)

FILENAME_REGEX = re.compile(
    r"^(?P<source>reactor\d+|settler)_(?P<hours>\d+)hr_(?P<day>day\d+)(?:_.*)?\.csv$",
    re.IGNORECASE,
)


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def discover_files(root: Path, source: str, day: str) -> Dict[str, Path]:
    """Return mapping from hour token to file path for the requested source/day."""
    files: Dict[str, Path] = {}
    for path in root.glob("*.csv"):
        match = FILENAME_REGEX.match(path.name)
        if not match:
            continue
        if match.group("source").lower() != source.lower():
            continue
        if match.group("day").lower() != day.lower():
            continue
        hour_token = match.group("hours")
        files[hour_token] = path
    return dict(sorted(files.items(), key=lambda item: int(item[0])))


def load_series(path: Path, timestamp_col: str, value_col: str) -> pd.Series:
    df = pd.read_csv(path)
    if timestamp_col not in df.columns:
        raise ValueError(f"{path.name}: timestamp column '{timestamp_col}' not found.")
    if value_col not in df.columns:
        raise ValueError(f"{path.name}: value column '{value_col}' not found.")
    timestamps = pd.to_datetime(df[timestamp_col], errors="coerce")
    values = pd.to_numeric(df[value_col], errors="coerce")
    mask = timestamps.notna() & values.notna()
    return pd.Series(values[mask].values, index=timestamps[mask])


def plot_group(
    series_map: Dict[str, pd.Series],
    *,
    source: str,
    day: str,
    output_dir: Path,
    show: bool,
) -> None:
    if not series_map:
        LOGGER.warning("No matching series to plot for %s %s.", source, day)
        return

    plt.figure(figsize=(12, 6))
    for hours, series in series_map.items():
        label = f"{hours} hr"
        plt.plot(series.index, series.values, label=label)

    plt.title(f"Normalized S_NH4 – {source.title()} ({day})")
    plt.xlabel("Timestamp")
    plt.ylabel("normalized_S_NH4")
    plt.yticks(ticks = np.arange(0, 2.5, step = 0.25))
    plt.grid(True, linestyle="--", alpha=0.6)
    plt.legend()
    plt.tight_layout()

    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"{source}_{day}_normalized_S_NH4.png"
    plt.savefig(output_path, dpi=300)
    LOGGER.info("Saved plot to %s", output_path)

    if show:  # pragma: no cover - optional interactive branch
        plt.show()
    else:
        plt.close()


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Plot normalized S_NH4 time-series grouped by source and day."
    )
    parser.add_argument(
        "--input-dir",
        type=Path,
        default=DEFAULT_INPUT,
        help="Directory containing normalized window CSV files.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="Directory to store generated plots.",
    )
    parser.add_argument(
        "--source",
        required=True,
        help="Source to plot (e.g., reactor1, reactor2, settler).",
    )
    parser.add_argument(
        "--day",
        required=True,
        help="Day identifier to plot (e.g., day0, day1).",
    )
    parser.add_argument(
        "--timestamp-col",
        default="timestamp",
        help="Timestamp column name (default: timestamp).",
    )
    parser.add_argument(
        "--value-col",
        default="normalized_S_NH4",
        help="Value column to plot (default: normalized_S_NH4).",
    )
    parser.add_argument(
        "--loglevel",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity.",
    )
    parser.add_argument(
        "--show",
        action="store_true",
        help="Display the plot interactively after saving.",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> None:
    args = parse_arguments(argv)
    configure_logging(args.loglevel)

    input_dir = args.input_dir.expanduser().resolve()
    output_dir = args.output_dir.expanduser().resolve()

    if not input_dir.exists():
        raise FileNotFoundError(f"Input directory not found: {input_dir}")

    files = discover_files(input_dir, args.source, args.day)
    if not files:
        LOGGER.warning(
            "No files found for source '%s' and day '%s' in %s.",
            args.source,
            args.day,
            input_dir,
        )
        return

    series_map: Dict[str, pd.Series] = {}
    for hours, path in files.items():
        try:
            series_map[hours] = load_series(path, args.timestamp_col, args.value_col)
        except Exception as exc:  # pragma: no cover - defensive
            LOGGER.error("Failed to load series from %s: %s", path.name, exc)

    plot_group(series_map, source=args.source, day=args.day, output_dir=output_dir, show=args.show)


if __name__ == "__main__":
    main()
