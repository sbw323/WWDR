"""Utility to generate risk tags for ASM3 data outputs.

This script walks the experimental result directories within the
`8AM_ASM3_DB` tree, compares each dataset against its corresponding
nominal baseline, and writes out tagged datasets with severity, frequency,
"risk" (TagR), and supporting metrics. Tagged datasets are written into
`8AM_ASM3_DB/Tagged_Datasets`, mirroring the source directory structure.
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass
import logging
from pathlib import Path
from typing import Iterable, Optional

import numpy as np
import pandas as pd

# Column schema shared by reactor and settler CSV exports
ASM3_COLUMNS = [
    "S_I",
    "S_S",
    "X_I",
    "X_S",
    "X_H",
    "X_A",
    "X_STO",
    "S_O2",
    "S_NOX",
    "S_NH4",
    "S_N2",
    "S_ALK",
    "X_SS",
    "Q",
]

# Five-by-five risk matrix (severity rows, frequency columns)
RISK_MATRIX = np.array(
    [
        [0, 0, 0, 1, 2],
        [1, 1, 1, 2, 3],
        [1, 1, 2, 3, 4],
        [2, 2, 3, 4, 4],
        [2, 3, 3, 4, 4],
    ]
)

STOICHIOMETRY = {
    "i_SSXS": 0.07,
    "i_NBM": 0.01,
    "i_NSI": 0.03,
    "i_NSS": 0.02,
    "i_NXI": 0.04,
    "i_NXS": 0.90,
    "i_SSBM": 0.60,
    "i_SSSTO": 0.75,
    "i_SSXI": 0.75,
    "f_ns": 0.0023,
    "f_P": 0.08,
    "f_SI": 0.0,
    "f_XI": 0.20,
}

BSS = 2
BCOD = 1
BNKj = 30
BNO = 10
BBOD5 = 2

ROLLING_WINDOW = 96  # 4 days at 15-minute timesteps
SCALING_FACTOR = 10 ** 8  # Normalize EQI deltas prior to scoring


@dataclass(frozen=True)
class DatasetPair:
    experiment_file: Path
    nominal_file: Path
    output_file: Path

    @property
    def iteration(self) -> str:
        return self.experiment_file.parent.name

    @property
    def label(self) -> str:
        return self.experiment_file.name


def compute_eqi(df: pd.DataFrame, stoich: dict[str, float] = STOICHIOMETRY) -> pd.Series:
    """Compute the instantaneous Effluent Quality Index (EQI)."""
    i_nbm = stoich["i_NBM"]
    i_nsi = stoich["i_NSI"]
    i_nss = stoich["i_NSS"]
    i_nxi = stoich["i_NXI"]
    i_nxs = stoich["i_NXS"]
    f_p = stoich["f_P"]

    sse = df["X_SS"]
    code = df[["S_I", "S_S", "X_I", "X_S", "X_H", "X_A", "X_STO"]].sum(axis=1)
    snkje = (
        df["S_NH4"]
        + i_nsi * df["S_I"]
        + i_nss * df["S_S"]
        + i_nxi * df["X_I"]
        + i_nxs * df["X_S"]
        + i_nbm * (df["X_H"] + df["X_A"])
    )
    snoe = df["S_NOX"]
    bod5e = 0.25 * (df["S_S"] + df["X_S"] + (1 - f_p) * (df["X_H"] + df["X_A"] + df["X_STO"]))
    q = df["Q"]

    eqi = (BSS * sse + BCOD * code + BNKj * snkje + BNO * snoe + BBOD5 * bod5e) * q
    return eqi


def assign_severity(iter_df: pd.DataFrame, nominal_df: pd.DataFrame) -> pd.DataFrame:
    """Assign severity tags (tagS) by comparing experiment to nominal baseline."""
    iter_df = iter_df.copy()
    nominal_eqi = nominal_df["EQIvecinst"]
    diff = ((iter_df["EQIvecinst"] - nominal_eqi) / SCALING_FACTOR).clip(lower=0)

    mean = diff.mean()
    std = diff.std(ddof=0)
    thresholds = (
        mean + np.array([1.0, 1.5, 2.0, 2.5]) * std if std and not np.isnan(std) else np.full(4, np.inf)
    )

    severity = np.zeros(len(diff), dtype=int)
    for idx, value in enumerate(diff.fillna(0)):
        if value > thresholds[3]:
            severity[idx] = 4
        elif value > thresholds[2]:
            severity[idx] = 3
        elif value > thresholds[1]:
            severity[idx] = 2
        elif value > thresholds[0]:
            severity[idx] = 1
        else:
            severity[idx] = 0

    iter_df["series_diff"] = diff
    iter_df["tagS"] = severity
    return iter_df


def assign_frequency(df: pd.DataFrame) -> pd.DataFrame:
    """Assign frequency tags (tagF) using recent severity history."""
    df = df.copy()
    severity = df["tagS"].to_list()
    freq = [0] * len(df)

    for i in range(len(df)):
        if i < 4:
            continue  # First four entries remain at the default frequency

        window = severity[i - 4 : i]  # Four most recent severities
        recent = severity[i]

        if recent == 4:
            if all(val >= 1 for val in window):
                freq[i] = 4
            elif all(val >= 1 for val in window[1:]):
                freq[i] = 4
            elif all(val >= 1 for val in window[2:]):
                freq[i] = 3
            elif window[-1] >= 1:
                freq[i] = 3
            else:
                freq[i] = 2
        elif recent == 3:
            if all(val >= 1 for val in window):
                freq[i] = 4
            elif all(val >= 1 for val in window[1:]):
                freq[i] = 4
            elif all(val >= 1 for val in window[2:]):
                freq[i] = 3
            else:
                freq[i] = 2
        elif recent == 2:
            if all(val >= 1 for val in window):
                freq[i] = 4
            elif all(val >= 1 for val in window[1:]):
                freq[i] = 3
            elif all(val >= 1 for val in window[2:]):
                freq[i] = 2
            else:
                freq[i] = 1
        elif recent == 1:
            if all(val >= 1 for val in window):
                freq[i] = 3
            elif all(val >= 1 for val in window[1:]):
                freq[i] = 2
            elif all(val >= 1 for val in window[2:]):
                freq[i] = 1
            else:
                freq[i] = 1
        else:
            if all(val >= 1 for val in window):
                freq[i] = 2
            elif all(val >= 1 for val in window[1:]):
                freq[i] = 1
            elif all(val >= 1 for val in window[2:]):
                freq[i] = 1
            else:
                freq[i] = 0

    df["tagF"] = freq
    return df


def assign_risk(df: pd.DataFrame) -> pd.DataFrame:
    """Assign risk tags using the 5x5 risk matrix."""
    df = df.copy()
    severity = np.clip(df["tagS"].astype(int), 0, 4)
    frequency = np.clip(df["tagF"].astype(int), 0, 4)
    df["tagR"] = [RISK_MATRIX[s, f] for s, f in zip(severity, frequency)]
    return df


def prepare_dataframe(csv_path: Path) -> pd.DataFrame:
    """Load a CSV into a DataFrame with standard columns and derived metrics."""
    df = pd.read_csv(csv_path, header=None, names=ASM3_COLUMNS)
    df["EQIvecinst"] = compute_eqi(df)
    df["mR"] = df["EQIvecinst"].rolling(window=ROLLING_WINDOW, min_periods=1).mean()
    df["tagS"] = 0
    df["tagF"] = 0
    return df


def process_dataset(pair: DatasetPair) -> Optional[pd.DataFrame]:
    try:
        experiment_df = prepare_dataframe(pair.experiment_file)
    except FileNotFoundError:
        logging.warning("Missing experiment file: %s", pair.experiment_file)
        return None

    try:
        nominal_df = prepare_dataframe(pair.nominal_file)
    except FileNotFoundError:
        logging.warning("Missing nominal baseline for %s", pair.experiment_file)
        return None

    if len(experiment_df) != len(nominal_df):
        logging.warning(
            "Length mismatch (exp=%d, nominal=%d) for %s",
            len(experiment_df),
            len(nominal_df),
            pair.experiment_file,
        )
        return None

    tagged = assign_severity(experiment_df, nominal_df)
    tagged = assign_frequency(tagged)
    tagged = assign_risk(tagged)

    tagged.to_csv(pair.output_file, index=False)
    logging.info("Tagged dataset written: %s", pair.output_file)
    return tagged


def discover_pairs(base_dir: Path, output_root: Path) -> Iterable[DatasetPair]:
    nominal_root = base_dir / "Results_Nominal" / "ASM3_OutputDB"
    experiment_dirs = sorted(
        p for p in base_dir.iterdir() if p.is_dir() and p.name.startswith("Results_ExpLength_")
    )

    for experiment_dir in experiment_dirs:
        exp_output = experiment_dir / "ASM3_OutputDB"
        if not exp_output.exists():
            logging.debug("Skipping %s (no ASM3_OutputDB)", experiment_dir)
            continue

        for iter_dir in sorted(exp_output.iterdir()):
            if not iter_dir.is_dir():
                continue

            nominal_iter_dir = nominal_root / iter_dir.name
            if not nominal_iter_dir.exists():
                logging.warning("Missing nominal directory for %s", iter_dir)
                continue

            for csv_file in sorted(iter_dir.glob("*.csv")):
                nominal_file = nominal_iter_dir / csv_file.name
                relative = Path(experiment_dir.name) / "ASM3_OutputDB" / iter_dir.name
                output_dir = output_root / relative
                output_dir.mkdir(parents=True, exist_ok=True)
                output_file = output_dir / csv_file.name
                yield DatasetPair(csv_file, nominal_file, output_file)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--base-dir",
        default=Path("/Users/aya/github/WWDR/8AM_ASM3_DB"),
        type=Path,
        help="Root directory containing experiment and nominal result folders.",
    )
    parser.add_argument(
        "--output-dir",
        default=Path("/Users/aya/github/WWDR/8AM_ASM3_DB/Tagged_Datasets"),
        type=Path,
        help="Destination directory for tagged datasets (will mirror source structure).",
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    logging.basicConfig(level=getattr(logging, args.log_level.upper()), format="%(levelname)s: %(message)s")

    base_dir: Path = args.base_dir
    output_dir: Path = args.output_dir

    if not base_dir.exists():
        raise FileNotFoundError(f"Base directory not found: {base_dir}")

    output_dir.mkdir(parents=True, exist_ok=True)

    processed = 0
    for pair in discover_pairs(base_dir, output_dir):
        result = process_dataset(pair)
        if result is not None:
            processed += 1

    logging.info("Processing complete: %d datasets tagged", processed)


if __name__ == "__main__":
    main()
