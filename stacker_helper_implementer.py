#!/usr/bin/env python3
"""
Batch controller that groups experiment outputs by type and feeds them to
vstack_timeseries_helper for quarter-hour aligned stacking.

For each experiment directory matching the requested ExpLength/startday filters,
the orchestrator discovers every CSV, assigns it to a reactor/settler bucket
using configurable regexes, and produces one stacked CSV per bucket (R1–R5, S).
"""

from __future__ import annotations

import argparse
import json
import logging
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple, Union

from ts_stacker_helper import LOGGER as STACKER_LOGGER, vstack_timeseries_helper

LOGGER = logging.getLogger(__name__)

# Default regexes for file classification.
TYPE_MAP_DEFAULT: Dict[str, str] = {
    "R1": r"\bR1\b|reactor[_-]?1[_-]?.*",
    "R2": r"\bR2\b|reactor[_-]?2[_-]?.*",
    "R3": r"\bR3\b|reactor[_-]?3[_-]?.*",
    "R4": r"\bR4\b|reactor[_-]?4[_-]?.*",
    "R5": r"\bR5\b|reactor[_-]?5[_-]?.*",
    "S": r"\bS\b|settler[_-]?.*",
}

DEFAULT_PARENT_DIR = Path("./data/experiments")
DEFAULT_OUTPUT_DIR = Path("./combined")
DEFAULT_EXP_PATTERN = r"Exp(?P<exp>\d+)d"
DEFAULT_DAY_PATTERN = r"day(?P<day>\d{3})"

SummaryRecord = Dict[str, Union[str, int]]


@dataclass(frozen=True)
class ExperimentCase:
    """Concrete experiment directory with parsed metadata."""

    path: Path
    exp_length: int
    startday: int


def configure_logging(level: str) -> None:
    """Initialise logging for the orchestrator."""
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def _compile_pattern(pattern: str, label: str) -> re.Pattern[str]:
    try:
        return re.compile(pattern, re.IGNORECASE)
    except re.error as exc:  # pragma: no cover - defensive
        raise ValueError(f"Invalid {label} regex '{pattern}': {exc}") from exc


def _extract_int(match: re.Match[str], preferred_group: str, fallback_index: int = 1) -> int:
    if preferred_group in match.groupdict():
        return int(match.group(preferred_group))
    return int(match.group(fallback_index))


def parse_experiment_directory(
    path: Path,
    *,
    exp_regex: re.Pattern[str],
    day_regex: re.Pattern[str],
) -> Optional[ExperimentCase]:
    """Parse ExpLength/startday from a directory name."""
    exp_match = exp_regex.search(path.name)
    day_match = day_regex.search(path.name)
    if not exp_match or not day_match:
        return None
    exp_length = _extract_int(exp_match, "exp")
    startday = _extract_int(day_match, "day")
    return ExperimentCase(path=path, exp_length=exp_length, startday=startday)


def discover_experiments(
    parent_dir: Path,
    *,
    exp_regex: re.Pattern[str],
    day_regex: re.Pattern[str],
) -> List[ExperimentCase]:
    """Discover candidate experiment directories beneath parent_dir."""
    if not parent_dir.exists():
        raise FileNotFoundError(f"Parent directory not found: {parent_dir}")

    experiments: List[ExperimentCase] = []
    for child in sorted(parent_dir.iterdir()):
        if not child.is_dir():
            continue
        parsed = parse_experiment_directory(child, exp_regex=exp_regex, day_regex=day_regex)
        if parsed:
            experiments.append(parsed)
        else:
            LOGGER.debug("Skipping %s (failed to match experiment patterns).", child.name)
    return experiments


def _materialise_sequence(arg: Optional[Union[int, Sequence[int]]]) -> List[int]:
    if arg is None:
        return []
    if isinstance(arg, int):
        return [arg]
    return [int(value) for value in arg]


def _filter_values(
    experiments: Iterable[ExperimentCase],
    *,
    exp_values: Optional[Sequence[int]],
    exp_range: Optional[Tuple[int, int]],
    start_values: Optional[Sequence[int]],
    start_range: Optional[Tuple[int, int]],
) -> List[ExperimentCase]:
    exp_value_list = _materialise_sequence(exp_values)
    start_value_list = _materialise_sequence(start_values)

    def in_range(value: int, bounds: Optional[Tuple[int, int]]) -> bool:
        if bounds is None:
            return True
        lo, hi = bounds
        return lo <= value <= hi

    filtered: List[ExperimentCase] = []
    for case in experiments:
        if exp_value_list and case.exp_length not in exp_value_list:
            continue
        if start_value_list and case.startday not in start_value_list:
            continue
        if not in_range(case.exp_length, exp_range):
            continue
        if not in_range(case.startday, start_range):
            continue
        filtered.append(case)
    return filtered


def _collect_csv_files(directory: Path) -> List[Path]:
    """Gather all CSV files recursively within a directory."""
    return sorted(p for p in directory.rglob("*.csv") if p.is_file())


def _compile_type_map(type_map: Dict[str, str]) -> Dict[str, re.Pattern[str]]:
    return {key: re.compile(pattern, re.IGNORECASE) for key, pattern in type_map.items()}


def bucket_files_by_type(
    files: Sequence[Path],
    *,
    type_map: Dict[str, str],
) -> Dict[str, List[Path]]:
    """Assign files to type buckets using regex mappings."""
    compiled = _compile_type_map(type_map)
    buckets: Dict[str, List[Path]] = {key: [] for key in compiled}

    for file_path in files:
        matched = False
        for key, pattern in compiled.items():
            if pattern.search(file_path.name):
                buckets[key].append(file_path)
                matched = True
                break
        if not matched:
            LOGGER.warning("Unclassified file skipped: %s", file_path)
    return buckets


def parse_range(values: Optional[Sequence[Union[int, str]]]) -> Optional[Tuple[int, int]]:
    """Convert a one or two value sequence into an inclusive integer range."""
    if not values:
        return None
    if len(values) == 1:
        value = int(values[0])
        return value, value
    if len(values) == 2:
        lo, hi = int(values[0]), int(values[1])
        if lo > hi:
            raise ValueError("Range lower bound cannot exceed the upper bound.")
        return lo, hi
    raise ValueError("Range arguments accept at most two integers.")


def load_type_map(path: Optional[Path]) -> Dict[str, str]:
    """Load a type mapping from JSON when provided."""
    if path is None:
        return TYPE_MAP_DEFAULT
    with path.expanduser().open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise ValueError("Type map JSON must contain an object of {type_key: regex}.")
    return {str(key): str(value) for key, value in data.items()}


def stacker_helper_implementer(
    *,
    parent_dir: Path,
    outdir: Path,
    exp_lengths: Optional[Sequence[int]] = None,
    exp_length_range: Optional[Tuple[int, int]] = None,
    startdays: Optional[Sequence[int]] = None,
    startday_range: Optional[Tuple[int, int]] = None,
    type_map: Optional[Dict[str, str]] = None,
    pattern_exp: str = DEFAULT_EXP_PATTERN,
    pattern_day: str = DEFAULT_DAY_PATTERN,
    delimiter: str = ",",
    has_header: bool = False,
    generate_timestamps: bool = True,
    timestamp_column: Optional[str] = None,
    dry_run: bool = False,
    helper_log_level: str = "INFO",
) -> List[SummaryRecord]:
    """Main entry point used by the CLI and tests."""
    type_map = type_map or TYPE_MAP_DEFAULT
    exp_regex = _compile_pattern(pattern_exp, "ExpLength")
    day_regex = _compile_pattern(pattern_day, "startday")

    experiments = discover_experiments(parent_dir, exp_regex=exp_regex, day_regex=day_regex)
    experiments = _filter_values(
        experiments,
        exp_values=exp_lengths,
        exp_range=exp_length_range,
        start_values=startdays,
        start_range=startday_range,
    )

    if not experiments:
        LOGGER.warning("No experiment directories matched the supplied filters.")
        return []

    STACKER_LOGGER.setLevel(getattr(logging, helper_log_level))

    summaries: List[SummaryRecord] = []
    for case in experiments:
        csv_files = _collect_csv_files(case.path)
        if not csv_files:
            LOGGER.warning("%s: no CSV files discovered; skipping.", case.path)
            continue

        buckets = bucket_files_by_type(csv_files, type_map=type_map)
        for type_key, bucket in buckets.items():
            if not bucket:
                LOGGER.warning(
                    "%s ExpLength=%s startday=%s: no files found for type %s.",
                    case.path.name,
                    case.exp_length,
                    case.startday,
                    type_key,
                )
                continue

            bucket = sorted(bucket)
            if len(bucket) < 2:
                LOGGER.warning(
                    "%s ExpLength=%s startday=%s type=%s: only %d file(s); stacking will continue.",
                    case.path.name,
                    case.exp_length,
                    case.startday,
                    type_key,
                    len(bucket),
                )

            target_dir = outdir / f"Exp{case.exp_length}h_day{case.startday:03d}"
            output_path = target_dir / f"stack_{type_key}_Exp{case.exp_length}h_day{case.startday:03d}.csv"

            LOGGER.info(
                "Exp%s day%03d (%s): stacking %d file(s) into %s",
                case.exp_length,
                case.startday,
                type_key,
                len(bucket),
                output_path,
            )

            if not dry_run:
                vstack_timeseries_helper(
                    bucket,
                    output_path,
                    type_key=type_key,
                    timestamp_column=timestamp_column,
                    delimiter=delimiter,
                    has_header=has_header,
                    generate_timestamps=generate_timestamps,
                )

            summaries.append(
                {
                    "experiment_dir": str(case.path),
                    "type": type_key,
                    "exp_length": case.exp_length,
                    "startday": case.startday,
                    "output_file": str(output_path),
                    "file_count": len(bucket),
                }
            )

    return summaries


def _parse_cli_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Stack experiment outputs by type (R1–R5, S) on quarter-hour timestamps."
    )
    parser.add_argument(
        "--parentdir",
        "--parent-dir",
        dest="parent_dir",
        type=Path,
        default=DEFAULT_PARENT_DIR,
        help=f"Root directory containing experiment folders (default: {DEFAULT_PARENT_DIR}).",
    )
    parser.add_argument(
        "--outdir",
        "--output-dir",
        dest="outdir",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help=f"Destination root for stacked outputs (default: {DEFAULT_OUTPUT_DIR}).",
    )
    parser.add_argument(
        "--ExpLength",
        "--exp-length",
        dest="exp_lengths",
        nargs="+",
        type=int,
        help="Filter experiments by explicit ExpLength values (e.g., 1 14 28).",
    )
    parser.add_argument(
        "--ExpLength-range",
        "--exp-length-range",
        dest="exp_length_range",
        nargs="+",
        type=int,
        metavar=("MIN", "MAX"),
        help="Inclusive ExpLength range (supply one value for an exact match, two for a range).",
    )
    parser.add_argument(
        "--startday",
        nargs="+",
        type=int,
        help="Filter experiments by explicit startday values (e.g., 0 1 2).",
    )
    parser.add_argument(
        "--startday-range",
        nargs="+",
        type=int,
        metavar=("MIN", "MAX"),
        help="Inclusive startday range (one value for exact match, two for a range).",
    )
    parser.add_argument(
        "--pattern-exp",
        default=DEFAULT_EXP_PATTERN,
        help=f"Regex used to extract ExpLength from directory names (default: {DEFAULT_EXP_PATTERN}).",
    )
    parser.add_argument(
        "--pattern-day",
        default=DEFAULT_DAY_PATTERN,
        help=f"Regex used to extract startday from directory names (default: {DEFAULT_DAY_PATTERN}).",
    )
    parser.add_argument(
        "--type-map-file",
        type=Path,
        help="Optional JSON file overriding the default {type: regex} classification map.",
    )
    parser.add_argument(
        "--delimiter",
        default=",",
        help="CSV delimiter to pass through to the stacker helper.",
    )
    parser.add_argument(
        "--has-header",
        action="store_true",
        help="Indicate that input CSV files contain a header row.",
    )
    parser.add_argument(
        "--no-generate-timestamps",
        action="store_true",
        help="Disable synthetic timestamp generation inside the stacker.",
    )
    parser.add_argument(
        "--timestamp-column",
        help="Optional timestamp column name to pass through to the stacker.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Discover and log matching files without invoking the stacker helper.",
    )
    parser.add_argument(
        "--loglevel",
        "--verbose",
        dest="loglevel",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity for the orchestrator.",
    )
    parser.add_argument(
        "--helper-loglevel",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity for the underlying stacker helper.",
    )
    parser.add_argument(
        "--run-smoke-tests",
        action="store_true",
        help="Execute in-module smoke tests instead of stacking data.",
    )
    return parser.parse_args(argv)


def _smoke_test_full_pipeline() -> None:
    """Validate contract requirements using synthetic CSVs."""
    import tempfile

    import pandas as pd

    with tempfile.TemporaryDirectory() as tmp_dir:
        base = Path(tmp_dir)
        parent = base / "Exp1d_day000"
        (parent / "ASM3_OutputDB" / "iter001").mkdir(parents=True)
        (parent / "ASM3_OutputDB" / "iter002").mkdir(parents=True)

        def make_csv(iteration: str, filename: str, values: Sequence[int]) -> Path:
            target = parent / "ASM3_OutputDB" / iteration / filename
            pd.DataFrame({"value": list(values)}).to_csv(target, header=False, index=False)
            return target

        files_per_type: Dict[str, List[Path]] = {
            "R1": [
                make_csv("iter001", "reactor1_data_iteration_001.csv", [1, 2, 3, 4]),
                make_csv("iter002", "R1_timeseries_iter002.csv", [5, 6, 7, 8]),
            ],
            "R2": [
                make_csv("iter001", "reactor_2_iteration_001.csv", [1, 1, 1, 1]),
                make_csv("iter002", "reactor-2-iteration-002.csv", [2, 2, 2, 2]),
            ],
            "R3": [
                make_csv("iter001", "R3.csv", [10, 11, 12, 13]),
                make_csv("iter002", "reactor3_data_iteration_002.csv", [14, 15, 16, 17]),
            ],
            "R4": [
                make_csv("iter001", "reactor4_data_iteration_001.csv", [3, 3, 3, 3]),
                make_csv("iter002", "R-4_iteration_002.csv", [4, 4, 4, 4]),
            ],
            "R5": [
                make_csv("iter001", "reactor5_data_iteration_001.csv", [5, 6, 7, 8]),
                make_csv("iter002", "R5-timeseries-iter002.csv", [9, 10, 11, 12]),
            ],
            "S": [
                make_csv("iter001", "settler_iteration_001.csv", [100, 101, 102, 103]),
                make_csv("iter002", "S_iteration_002.csv", [104, 105, 106, 107]),
            ],
        }

        outdir = base / "combined"
        summaries = stacker_helper_implementer(
            parent_dir=base,
            outdir=outdir,
            exp_lengths=[1],
            startdays=[0],
            generate_timestamps=True,
        )
        assert len(summaries) == 6, "Expected six outputs (one per type)."

        for record in summaries:
            output_path = Path(record["output_file"])
            assert output_path.exists(), f"Missing output file {output_path}"
            df = pd.read_csv(output_path)
            timestamps = pd.to_datetime(df["timestamp"])
            assert timestamps.dt.minute.isin([0, 15, 30, 45]).all(), "Timestamps must align to quarter hours."
            type_key = record["type"]
            type_sources = {Path(p).stem for p in files_per_type[type_key]}
            assert set(df["source_id"]).issubset(type_sources), "Cross-type mixing detected."


def _run_smoke_tests() -> None:
    LOGGER.info("Running stacker_helper_implementer smoke tests...")
    _smoke_test_full_pipeline()
    LOGGER.info("All orchestrator smoke tests passed.")


def main(argv: Optional[Sequence[str]] = None) -> None:
    args = _parse_cli_arguments(argv)
    configure_logging(args.loglevel)

    if args.run_smoke_tests:
        _run_smoke_tests()
        return

    summaries = stacker_helper_implementer(
        parent_dir=args.parent_dir.expanduser().resolve(),
        outdir=args.outdir.expanduser().resolve(),
        exp_lengths=args.exp_lengths,
        exp_length_range=parse_range(args.exp_length_range),
        startdays=args.startday,
        startday_range=parse_range(args.startday_range),
        type_map=load_type_map(args.type_map_file),
        pattern_exp=args.pattern_exp,
        pattern_day=args.pattern_day,
        delimiter=args.delimiter,
        has_header=args.has_header,
        generate_timestamps=not args.no_generate_timestamps,
        timestamp_column=args.timestamp_column,
        dry_run=args.dry_run,
        helper_log_level=args.helper_loglevel,
    )

    LOGGER.info("Completed stacking for %d (ExpLength, startday, type) combination(s).", len(summaries))


if __name__ == "__main__":
    main()
