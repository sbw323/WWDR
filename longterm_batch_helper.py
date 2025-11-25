#!/usr/bin/env python3
"""
Batch helper that runs the full stacked-data pipeline across all Longterm experiments.

The helper orchestrates the following stages for each experiment directory:
    1. naive_vstacker.py
    2. stacked_exp_influent_combiner.py
    3. SNH4_normalizer.py (uses a shared nominal baseline)
    4. experiment_extractor.py

It is configured by default for /Users/ikai/github/WWDR-Databases/Databases/Longterm
but paths and plotting options can be overridden via CLI flags.
"""

from __future__ import annotations

import argparse
import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Iterator, List, Optional, Sequence

import experiment_extractor
import naive_vstacker
import SNH4_normalizer
import stacked_exp_influent_combiner

LOGGER = logging.getLogger(__name__)

DEFAULT_ROOT = Path("/Users/ikai/github/WWDR-Databases/Databases/Longterm")
DEFAULT_BASELINE = DEFAULT_ROOT / "ExpLength_0h_startday_0_reductionfactor_1.0pct"
DEFAULT_INFLUENT = Path("/Users/ikai/github/WWDR-Databases/Databases/Influent/influent.csv")
DEFAULT_START_TIMESTAMP = "2023-01-01T00:00:00"


@dataclass(frozen=True)
class PipelineConfig:
    root_dir: Path
    baseline_dir: Path
    influent_csv: Path
    start_timestamp: str
    loglevel: str


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def call_stage(label: str, func, args: List[str]) -> None:
    LOGGER.debug("Running %s: %s", label, " ".join(args))
    try:
        func(args)
    except SystemExit as exc:
        code = 0 if exc.code is None else exc.code
        if code != 0:
            raise RuntimeError(f"{label} exited with code {code}") from exc
    except Exception as exc:
        raise RuntimeError(f"{label} failed: {exc}") from exc


def iter_experiments(root_dir: Path) -> Iterator[Path]:
    for child in sorted(root_dir.iterdir(), key=lambda p: p.name):
        if child.is_dir() and child.name.startswith("ExpLength_"):
            yield child


def process_dataset(dataset_dir: Path, config: PipelineConfig, baseline_naive_dir: Path) -> None:
    label = dataset_dir.name
    LOGGER.info("=== Processing %s ===", label)

    asm3_dir = dataset_dir / "ASM3_OutputDB"
    if not asm3_dir.is_dir():
        raise FileNotFoundError(f"ASM3_OutputDB not found in {dataset_dir}")

    naive_output = dataset_dir / "naive_stacked_data"
    with_influent = naive_output / "with_influent"
    with_snh4 = naive_output / "with_snh4_norm"
    extracted_dir = naive_output / "extracted_experiments_snh4"

    # Stage 1: naive stacking
    call_stage(
        "naive_vstacker",
        naive_vstacker.main,
        [
        "--input-dir",
        str(dataset_dir),
        "--start-timestamp",
        config.start_timestamp,
            "--loglevel",
            config.loglevel,
        ],
    )

    # Stage 2: join influent columns
    call_stage(
        "stacked_exp_influent_combiner",
        stacked_exp_influent_combiner.main,
        [
            "--input-dir",
            str(naive_output),
            "--output-dir",
            str(with_influent),
            "--influent-csv",
            str(config.influent_csv),
            "--suffix",
            "_influent",
            "--loglevel",
            config.loglevel,
        ],
    )

    if not baseline_naive_dir.exists():
        raise FileNotFoundError(
            f"Baseline naive stacks not found: {baseline_naive_dir}. "
            "Ensure the baseline experiment is processed first."
        )

    # Stage 3: compute SNH4 normalized columns
    call_stage(
        "SNH4_normalizer",
        SNH4_normalizer.main,
        [
            "--input-dir",
            str(with_influent),
            "--nominal-dir",
            str(baseline_naive_dir),
            "--output-dir",
            str(with_snh4),
            "--suffix",
            "_with_snh4_norm",
            "--loglevel",
            config.loglevel,
        ],
    )

    # Stage 4: extract first three days
    call_stage(
        "experiment_extractor",
        experiment_extractor.main,
        [
            "--input-dir",
            str(with_snh4),
            "--output-dir",
            str(extracted_dir),
            "--suffix",
            "_snh4_window",
            "--timestamp-col",
            "timestamp",
            "--loglevel",
            config.loglevel,
        ],
    )

    LOGGER.info("=== Completed %s ===", label)


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Batch apply the stacked data pipeline to Longterm experiments."
    )
    parser.add_argument(
        "--root-dir",
        type=Path,
        default=DEFAULT_ROOT,
        help="Directory containing ExpLength_* experiment folders.",
    )
    parser.add_argument(
        "--baseline-dir",
        type=Path,
        default=DEFAULT_BASELINE,
        help="Experiment directory to use as the nominal baseline.",
    )
    parser.add_argument(
        "--influent-csv",
        type=Path,
        default=DEFAULT_INFLUENT,
        help="Path to influent.csv used for the influent combiner stage.",
    )
    parser.add_argument(
        "--start-timestamp",
        default=DEFAULT_START_TIMESTAMP,
        help="Start timestamp passed to naive_vstacker (ISO-8601).",
    )
    parser.add_argument(
        "--loglevel",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity for all stages.",
    )
    parser.add_argument(
        "--max-datasets",
        type=int,
        help="Optional limit on the number of datasets to process (for testing).",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> None:
    args = parse_arguments(argv)
    configure_logging(args.loglevel)

    root_dir = args.root_dir.expanduser().resolve()
    baseline_dir = args.baseline_dir.expanduser().resolve()
    influent_csv = args.influent_csv.expanduser().resolve()

    if not root_dir.exists():
        raise FileNotFoundError(f"Root directory not found: {root_dir}")
    if not baseline_dir.exists():
        raise FileNotFoundError(f"Baseline directory not found: {baseline_dir}")
    if not influent_csv.exists():
        raise FileNotFoundError(f"Influent CSV not found: {influent_csv}")

    config = PipelineConfig(
        root_dir=root_dir,
        baseline_dir=baseline_dir,
        influent_csv=influent_csv,
        start_timestamp=args.start_timestamp,
        loglevel=args.loglevel,
    )

    baseline_name = baseline_dir.name
    datasets = list(iter_experiments(root_dir))
    datasets.sort(key=lambda p: (p.name != baseline_name, p.name))

    if args.max_datasets:
        datasets = datasets[: args.max_datasets]

    if not datasets:
        LOGGER.warning("No experiment directories found under %s.", root_dir)
        return

    baseline_naive_dir = baseline_dir / "naive_stacked_data"
    failures: List[str] = []

    for dataset_dir in datasets:
        try:
            process_dataset(dataset_dir, config, baseline_naive_dir)
        except Exception as exc:  # pragma: no cover - defensive
            LOGGER.error("Dataset %s failed: %s", dataset_dir.name, exc)
            failures.append(dataset_dir.name)

    LOGGER.info("Processed %d dataset(s). Failures: %s", len(datasets), failures or "none")


if __name__ == "__main__":
    main()
