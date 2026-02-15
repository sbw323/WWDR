#!/usr/bin/env python3
"""
Plot normalized S_NH4 time-series grouped by ExpLength and reduction factor.

Assumes the input directory contains subdirectories of the form
`ExpLength_<hours>h/` with settler CSV files whose names include the day token
(e.g., `day0`) and end with suffix `_X.Xpct`.  Each ExpLength is plotted in a
unique color, and each reduction factor uses a distinct line style.
"""

from __future__ import annotations

import argparse
import logging
import re
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

LOGGER = logging.getLogger(__name__)

DEFAULT_INPUT = Path(
    "/Users/ikai/github/WWDR-Databases/Databases/Longterm/aggregated_settler_snh4"
)
DEFAULT_OUTPUT = Path(
    "/Users/ikai/github/WWDR-Databases/Databases/Longterm/plots_normalized_snh4"
)

EXP_DIR_PATTERN = re.compile(r"ExpLength_(?P<length>\d+)h", re.IGNORECASE)
SETTLER_PATTERN = re.compile(
    r"settler_(?P<hours>\d+)hr_(?P<day>day\d+).*_(?P<reduction>\d+\.\d+)pct\.csv",
    re.IGNORECASE,
)

LINESTYLES = {
    "0.25": "-",
    "0.5": "--",
    "0.75": "-.",
    "0.95": ":",
}


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


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


def discover_series(
    root: Path,
    *,
    day: str,
    timestamp_col: str,
    value_col: str,
) -> Dict[str, Dict[str, pd.Series]]:
    """Return mapping {length: {reduction: series}} for the requested day."""
    results: Dict[str, Dict[str, pd.Series]] = {}

    for exp_dir in sorted(root.iterdir()):
        if not exp_dir.is_dir():
            continue
        match_dir = EXP_DIR_PATTERN.match(exp_dir.name)
        if not match_dir:
            LOGGER.debug("Skipping %s (not an ExpLength directory).", exp_dir.name)
            continue
        length_key = match_dir.group("length")

        for csv_path in sorted(exp_dir.glob("settler*.csv")):
            match = SETTLER_PATTERN.match(csv_path.name)
            if not match or match.group("day").lower() != day.lower():
                continue
            reduction = match.group("reduction")
            try:
                series = load_series(csv_path, timestamp_col, value_col)
                results.setdefault(length_key, {})[reduction] = series
            except Exception as exc:  # pragma: no cover
                LOGGER.error("Failed to load %s: %s", csv_path, exc)

    return results


def plot_series_per_length(
    grouped_series: Dict[str, Dict[str, pd.Series]],
    *,
    day: str,
    output_dir: Path,
    show: bool,
) -> None:
    if not grouped_series:
        LOGGER.warning("No matching settler series found to plot.")
        return

    lengths = sorted(grouped_series.keys(), key=int)
    colors = plt.cm.tab10(np.linspace(0, 1, len(lengths)))  # type: ignore[arg-type]
    color_map = {length: colors[idx] for idx, length in enumerate(lengths)}

    for length in lengths:
        reduction_map = grouped_series[length]
        if not reduction_map:
            continue

        plt.figure(figsize=(12, 6))
        for reduction, series in sorted(reduction_map.items(), key=lambda item: float(item[0])):
            linestyle = LINESTYLES.get(reduction, "-")
            label = f"{reduction} pct"
            plt.plot(series.index, series.values, label=label, color=color_map[length], linestyle=linestyle)

        plt.title(f"Settler normalized S_NH4 – ExpLength {length}h ({day})")
        plt.xlabel("Timestamp")
        plt.ylabel("normalized_S_NH4")
        plt.ylim(0, 1.6)
        plt.yticks(np.arange(0, 1.61, 0.2))
        plt.grid(True, linestyle="--", alpha=0.6)
        plt.legend(fontsize="small")
        plt.tight_layout()

        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / f"settler_ExpLength_{length}h_{day}_normalized_S_NH4.png"
        plt.savefig(output_path, dpi=300)
        LOGGER.info("Saved plot to %s", output_path)

        if show:  # pragma: no cover
            plt.show()
        else:
            plt.close()

    # Combined plot
    plt.figure(figsize=(12, 6))
    for length in lengths:
        color = color_map[length]
        for reduction, series in sorted(grouped_series[length].items(), key=lambda item: float(item[0])):
            linestyle = LINESTYLES.get(reduction, "-")
            label = f"ExpLength {length}h – {reduction} pct"
            plt.plot(series.index, series.values, label=label, color=color, linestyle=linestyle)

    plt.title(f"Settler normalized S_NH4 – Combined ExpLengths ({day})")
    plt.xlabel("Timestamp")
    plt.ylabel("normalized_S_NH4")
    plt.ylim(0, 1.6)
    plt.yticks(np.arange(0, 1.61, 0.2))
    plt.grid(True, linestyle="--", alpha=0.6)
    plt.legend(ncol=2, fontsize="small")
    plt.tight_layout()

    output_path = output_dir / f"settler_AllExpLengths_{day}_normalized_S_NH4.png"
    plt.savefig(output_path, dpi=300)
    LOGGER.info("Saved combined plot to %s", output_path)

    if show:  # pragma: no cover
        plt.show()
    else:
        plt.close()


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Plot aggregated settler normalized S_NH4 curves grouped by ExpLength."
    )
    parser.add_argument("--input-dir", type=Path, default=DEFAULT_INPUT, help="Aggregated settler root.")
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT, help="Directory for plots.")
    parser.add_argument("--day", default="day0", help="Day identifier to plot (e.g., day0).")
    parser.add_argument(
        "--timestamp-col",
        default="timestamp",
        help="Timestamp column name inside the CSV files.",
    )
    parser.add_argument(
        "--value-col",
        default="SNH4_inf_norm",
        help="Value column containing the normalized S_NH4 metric.",
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
        help="Show plots interactively after saving.",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> None:
    args = parse_arguments(argv)
    configure_logging(args.loglevel)

    input_dir = args.input_dir.expanduser().resolve()
    output_dir = args.output_dir.expanduser().resolve()

    if not input_dir.exists():
        raise FileNotFoundError(f"Input directory not found: {input_dir}")

    series_map = discover_series(
        input_dir,
        day=args.day,
        timestamp_col=args.timestamp_col,
        value_col=args.value_col,
    )
    plot_series_per_length(series_map, day=args.day, output_dir=output_dir, show=args.show)


if __name__ == "__main__":
    main()
