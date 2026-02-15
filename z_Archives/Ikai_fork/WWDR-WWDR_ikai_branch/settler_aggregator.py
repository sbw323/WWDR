#!/usr/bin/env python3
"""
Collect settler time-series CSVs from each experiment and regroup them by ExpLength.

For every ExpLength_* experiment directory, the script looks inside
`naive_stacked_data/extracted_experiments_snh4` and copies each settler CSV into an
aggregate directory of the form `<root>/aggregated_settler_snh4/ExpLength_<length>h/`.

To distinguish reduction factors, it appends the reduction suffix found in the parent
directory name (e.g., `_0.5pct`) to the copied filename. Example:

    settler_5hr_day0_influent_with_snh4_norm_snh4_window.csv
        -> settler_5hr_day0_influent_with_snh4_norm_snh4_window_0.5pct.csv
"""

from __future__ import annotations

import argparse
import logging
import re
import shutil
from pathlib import Path
from typing import Optional, Sequence

LOGGER = logging.getLogger(__name__)

DEFAULT_ROOT = Path("/Users/ikai/github/WWDR-Databases/Databases/Longterm")
DEFAULT_OUTPUT = DEFAULT_ROOT / "aggregated_settler_snh4"

EXP_PATTERN = re.compile(
    r"ExpLength_(?P<length>\d+)h_startday_\d+_reductionfactor_(?P<fraction>[\d.]+)pct",
    re.IGNORECASE,
)


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def collect_files(root: Path, output_root: Path) -> int:
    copied = 0
    for exp_dir in sorted(root.iterdir()):
        if not exp_dir.is_dir():
            continue

        match = EXP_PATTERN.match(exp_dir.name)
        if not match:
            LOGGER.debug("Skipping %s (does not match expected naming pattern).", exp_dir)
            continue

        exp_length = match.group("length")
        reduction_fraction = match.group("fraction")
        suffix = f"_{reduction_fraction}pct"

        src_dir = exp_dir / "naive_stacked_data" / "extracted_experiments_snh4"
        if not src_dir.is_dir():
            LOGGER.warning("No extracted settler directory found at %s", src_dir)
            continue

        dest_dir = output_root / f"ExpLength_{exp_length}h"
        dest_dir.mkdir(parents=True, exist_ok=True)

        settler_files = sorted(src_dir.glob("settler*.csv"))
        if not settler_files:
            LOGGER.warning("No settler CSVs found in %s", src_dir)
            continue

        for src_file in settler_files:
            dest_file = dest_dir / f"{src_file.stem}{suffix}{src_file.suffix}"
            shutil.copy2(src_file, dest_file)
            copied += 1
            LOGGER.debug("Copied %s -> %s", src_file, dest_file)

    return copied


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Aggregate settler datasets by experiment length."
    )
    parser.add_argument(
        "--root-dir",
        type=Path,
        default=DEFAULT_ROOT,
        help="Root directory containing ExpLength_* experiment folders.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="Destination directory for grouped settler CSVs.",
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

    root_dir = args.root_dir.expanduser().resolve()
    output_dir = args.output_dir.expanduser().resolve()

    if not root_dir.exists():
        raise FileNotFoundError(f"Root directory not found: {root_dir}")

    output_dir.mkdir(parents=True, exist_ok=True)
    copied = collect_files(root_dir, output_dir)
    LOGGER.info("Copied %d settler file(s) into %s", copied, output_dir)


if __name__ == "__main__":
    main()
