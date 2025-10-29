#!/usr/bin/env python3
"""
Naïve stacker that concatenates ASM3 reactor/settler outputs sequentially.

Given an experiment directory containing Results_ExpLength_* subfolders,
the script walks each experiment, discovers reactor/settler CSV exports
within iteration subdirectories, and vertically stacks them (without any
timestamp alignment). A synthetic `ticker` column is appended to each
stacked dataset to align with other time series in downstream analysis.

Outputs are written to `<output-root>/naive_stacked_data/` with filenames
of the form `<type>_<length><unit>_day<start>.csv`, e.g. `reactor1_1hr_day0.csv`.
"""

from __future__ import annotations

import argparse
import logging
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

try:
    import pandas as pd
except ImportError as exc:  # pragma: no cover - informative guard
    raise SystemExit("pandas is required. Install it with 'pip install pandas'.") from exc

from Codex.pollu_vis import ASM3_COLUMNS

LOGGER = logging.getLogger(__name__)

TYPE_PATTERNS: Dict[str, re.Pattern[str]] = {
    "reactor1": re.compile(r"reactor[_-]?1", re.IGNORECASE),
    "reactor2": re.compile(r"reactor[_-]?2", re.IGNORECASE),
    "reactor3": re.compile(r"reactor[_-]?3", re.IGNORECASE),
    "reactor4": re.compile(r"reactor[_-]?4", re.IGNORECASE),
    "reactor5": re.compile(r"reactor[_-]?5", re.IGNORECASE),
    "settler": re.compile(r"settler", re.IGNORECASE),
}

RUN_PATTERN = re.compile(
    r"ExpLength_(?P<length>\d+)(?P<unit>[a-zA-Z]+)_startday_(?P<start>\d+)", re.IGNORECASE
)

UNIT_LABELS = {
    "h": "hr",
    "hr": "hr",
    "d": "day",
    "day": "day",
}


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def generate_time_sequence(length: int) -> List[float]:
    """Return evenly spaced quarter-hour ticks starting from zero."""
    return [i / 96 for i in range(length)]


def build_ticker(length: int) -> List[float]:
    """Create the ticker column starting at 245 with quarter-hour increments."""
    base = generate_time_sequence(length)
    ticker = [245 + value for value in base]
    if ticker:
        end_value = ticker[-1]
        if abs(end_value - 609) > 1e-6:
            LOGGER.warning(
                "Ticker sequence length %d ends at %.3f instead of 609. "
                "Check dataset length or downstream alignment assumptions.",
                length,
                end_value,
            )
    return ticker


def natural_key(text: str) -> Tuple:
    """Split text into digit/non-digit chunks for natural sorting."""
    return tuple(int(chunk) if chunk.isdigit() else chunk for chunk in re.split(r"(\d+)", text))


@dataclass(frozen=True)
class ExperimentRun:
    path: Path
    label: str


def discover_experiments(root: Path) -> List[ExperimentRun]:
    experiments: List[ExperimentRun] = []
    for child in sorted(p for p in root.iterdir() if p.is_dir()):
        match = RUN_PATTERN.search(child.name)
        if not match:
            LOGGER.debug("Skipping %s (unrecognised naming pattern).", child.name)
            continue
        length = match.group("length")
        unit = match.group("unit").lower()
        unit_label = UNIT_LABELS.get(unit, unit)
        start = int(match.group("start"))
        label = f"{length}{unit_label}_day{start}"
        experiments.append(ExperimentRun(path=child, label=label))
    return experiments


def discover_iteration_dirs(exp_path: Path) -> List[Path]:
    candidate = exp_path / "ASM3_OutputDB"
    if candidate.is_dir():
        iter_dirs = [d for d in candidate.iterdir() if d.is_dir()]
    else:
        iter_dirs = [d for d in exp_path.iterdir() if d.is_dir() and d.name.lower().startswith("iter")]
    iter_dirs.sort(key=lambda p: natural_key(p.name))
    return iter_dirs


def gather_type_buckets(iter_dirs: Sequence[Path]) -> Dict[str, List[Tuple[str, Path]]]:
    buckets: Dict[str, List[Tuple[str, Path]]] = {key: [] for key in TYPE_PATTERNS}
    for iter_dir in iter_dirs:
        for csv_path in sorted(iter_dir.glob("*.csv"), key=lambda p: natural_key(p.name)):
            for type_key, pattern in TYPE_PATTERNS.items():
                if pattern.search(csv_path.name):
                    buckets[type_key].append((iter_dir.name, csv_path))
                    break
    return buckets


def load_csv(path: Path) -> pd.DataFrame:
    df = pd.read_csv(path, header=None)
    if df.shape[1] < len(ASM3_COLUMNS):
        raise ValueError(f"{path}: expected at least {len(ASM3_COLUMNS)} columns, found {df.shape[1]}.")
    if df.shape[1] > len(ASM3_COLUMNS):
        LOGGER.warning(
            "%s: trimming extra %d column(s) beyond ASM3 schema.",
            path,
            df.shape[1] - len(ASM3_COLUMNS),
        )
    df = df.iloc[:, : len(ASM3_COLUMNS)]
    df.columns = ASM3_COLUMNS
    return df


def build_timestamp_sequence(length: int, start_timestamp: Optional[str]) -> List[pd.Timestamp]:
    """Generate a list of timestamps spaced at 15-minute intervals."""
    if start_timestamp:
        base = pd.to_datetime(start_timestamp)
    else:
        base = pd.Timestamp("2000-01-01 00:00:00")
    return [base + pd.Timedelta(minutes=15 * i) for i in range(length)]


def stack_bucket(
    records: Sequence[Tuple[str, Path]],
    *,
    type_key: str,
    start_timestamp: Optional[str],
) -> pd.DataFrame:
    frames: List[pd.DataFrame] = []
    for iteration_name, csv_path in records:
        df = load_csv(csv_path)
        df["iteration"] = iteration_name
        frames.append(df)
    if not frames:
        return pd.DataFrame()
    stacked = pd.concat(frames, axis=0, ignore_index=True)
    ticker = build_ticker(len(stacked))
    stacked.insert(0, "ticker", ticker)
    timestamps = build_timestamp_sequence(len(stacked), start_timestamp)
    stacked.insert(1, "timestamp", timestamps)
    return stacked


def write_output(df: pd.DataFrame, output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path, index=False)
    LOGGER.info("Wrote stacked dataset (%d rows) to %s", len(df), output_path)


def process_experiment(
    exp: ExperimentRun,
    output_root: Path,
    *,
    start_timestamp: Optional[str],
) -> None:
    iter_dirs = discover_iteration_dirs(exp.path)
    if not iter_dirs:
        LOGGER.warning("No iteration directories found in %s; skipping.", exp.path)
        return

    buckets = gather_type_buckets(iter_dirs)
    for type_key, records in buckets.items():
        if not records:
            LOGGER.debug("%s: no files detected for %s.", exp.label, type_key)
            continue
        stacked = stack_bucket(records, type_key=type_key, start_timestamp=start_timestamp)
        if stacked.empty:
            LOGGER.warning("%s: stacked data empty for %s.", exp.label, type_key)
            continue
        filename = f"{type_key}_{exp.label}.csv"
        write_output(stacked, output_root / filename)


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Naïvely stack ASM3 reactor/settler outputs sequentially across iterations."
    )
    parser.add_argument(
        "--input-dir",
        type=Path,
        required=True,
        help="Directory containing Results_ExpLength_* experiment folders.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="Destination directory for stacked outputs (default: <input-dir>/naive_stacked_data).",
    )
    parser.add_argument(
        "--loglevel",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity.",
    )
    parser.add_argument(
        "--start-timestamp",
        help="Optional ISO-8601 timestamp used to seed the synthetic 15-minute column. "
        "Defaults to 2000-01-01T00:00:00 when omitted.",
    )
    return parser.parse_args(argv)


def main(argv: Optional[Sequence[str]] = None) -> None:
    args = parse_arguments(argv)
    configure_logging(args.loglevel)

    input_dir = args.input_dir.expanduser().resolve()
    if not input_dir.exists():
        raise FileNotFoundError(f"Input directory not found: {input_dir}")

    output_root = (
        args.output_dir.expanduser().resolve()
        if args.output_dir
        else (input_dir / "naive_stacked_data").resolve()
    )
    output_root.mkdir(parents=True, exist_ok=True)

    experiments = discover_experiments(input_dir)
    if not experiments:
        LOGGER.warning("No experiment folders detected under %s.", input_dir)
        return

    LOGGER.info("Discovered %d experiment(s) to process.", len(experiments))
    for exp in experiments:
        LOGGER.info("Processing experiment %s", exp.label)
        process_experiment(exp, output_root, start_timestamp=args.start_timestamp)


if __name__ == "__main__":
    main()
