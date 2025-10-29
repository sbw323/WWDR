#!/usr/bin/env python3
"""Compute normalized S_NH4 features for stacked experiment datasets."""

from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Optional, Sequence

import pandas as pd

LOGGER = logging.getLogger(__name__)

DEFAULT_INPUT = Path(
    "/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/with_influent"
)
DEFAULT_NOMINAL = Path(
    "/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/Nominal_Stacked"
)
DEFAULT_OUTPUT = Path(
    "/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/with_snh4_norm"
)

TIME_COLUMN = "timestamp"
EXP_SNH4_COLUMN = "S_NH4"
INFLUENT_SNH4_COLUMN = "S_NH4_ASin"
NOMINAL_SNH4_COLUMN = "S_NH4"


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def ensure_timestamp(df: pd.DataFrame) -> pd.Series:
    if TIME_COLUMN not in df.columns:
        raise ValueError(f"Dataset missing '{TIME_COLUMN}' column.")
    series = pd.to_datetime(df[TIME_COLUMN], errors="coerce")
    if series.isna().all():
        raise ValueError("All timestamps are NaT after parsing; check input data.")
    return series


def align_nominal_to_experiment(exp_df: pd.DataFrame, nom_df: pd.DataFrame) -> pd.Series:
    exp_time = ensure_timestamp(exp_df)
    nom_time = ensure_timestamp(nom_df)

    nominal_series = nom_df.set_index(nom_time)[NOMINAL_SNH4_COLUMN]
    aligned = nominal_series.reindex(exp_time, method="nearest")
    if aligned.isna().any():
        LOGGER.warning("Nominal alignment produced NaNs; forward/backward filling gaps.")
        aligned = aligned.fillna(method="ffill").fillna(method="bfill")
    return aligned.reset_index(drop=True)


def compute_normalized_columns(df: pd.DataFrame) -> pd.DataFrame:
    for column in (EXP_SNH4_COLUMN, INFLUENT_SNH4_COLUMN, f"nominal_{EXP_SNH4_COLUMN}"):
        if column not in df.columns:
            raise KeyError(f"Required column '{column}' not found in dataset.")

    exp_values = pd.to_numeric(df[EXP_SNH4_COLUMN], errors="coerce")
    nom_values = pd.to_numeric(df[f"nominal_{EXP_SNH4_COLUMN}"], errors="coerce")
    infl_values = pd.to_numeric(df[INFLUENT_SNH4_COLUMN], errors="coerce")

    diff = exp_values - nom_values

    with pd.option_context("mode.use_inf_as_na", True):
        snh4_inf_norm = diff / infl_values.replace(0, pd.NA)
        snh4_nom_norm = diff / nom_values.replace(0, pd.NA)
        snh4_nomdiff_denom = (infl_values - nom_values).replace(0, pd.NA)
        snh4_nomdiff_norm = diff / snh4_nomdiff_denom

    df["SNH4_inf_norm"] = snh4_inf_norm
    df["SNH4_nom_norm"] = snh4_nom_norm
    df["SNH4_nomdiff_norm"] = snh4_nomdiff_norm
    return df


def process_file(
    exp_path: Path,
    *,
    nominal_dir: Path,
    output_dir: Path,
    suffix: str,
) -> None:
    LOGGER.info("Processing %s", exp_path.name)
    exp_df = pd.read_csv(exp_path)

    unit_prefix = exp_path.name.split("_")[0]
    nominal_path = nominal_dir / f"{unit_prefix}_0hr_day0.csv"
    if not nominal_path.exists():
        raise FileNotFoundError(f"Nominal baseline not found: {nominal_path}")

    nom_df = pd.read_csv(nominal_path)
    aligned_nominal = align_nominal_to_experiment(exp_df, nom_df)
    exp_df[f"nominal_{EXP_SNH4_COLUMN}"] = aligned_nominal

    exp_df = compute_normalized_columns(exp_df)

    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"{exp_path.stem}{suffix}{exp_path.suffix}"
    exp_df.to_csv(output_path, index=False)
    LOGGER.info("Wrote %s", output_path)


def iter_csv(root: Path) -> list[Path]:
    return sorted(path for path in root.glob("*.csv") if path.is_file())


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Append normalized S_NH4 columns to stacked datasets."
    )
    parser.add_argument("--input-dir", type=Path, default=DEFAULT_INPUT, help="Stacked CSV directory.")
    parser.add_argument(
        "--nominal-dir",
        type=Path,
        default=DEFAULT_NOMINAL,
        help="Directory containing nominal baseline CSV files.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="Destination directory for augmented CSV files.",
    )
    parser.add_argument(
        "--suffix",
        default="_with_snh4_norm",
        help="Suffix appended to output filenames (default: _with_snh4_norm).",
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
    nominal_dir = args.nominal_dir.expanduser().resolve()
    output_dir = args.output_dir.expanduser().resolve()

    if not input_dir.exists():
        raise FileNotFoundError(f"Input directory not found: {input_dir}")
    if not nominal_dir.exists():
        raise FileNotFoundError(f"Nominal directory not found: {nominal_dir}")

    csv_files = iter_csv(input_dir)
    if not csv_files:
        LOGGER.warning("No CSV files found in %s", input_dir)
        return

    for exp_path in csv_files:
        try:
            process_file(
                exp_path,
                nominal_dir=nominal_dir,
                output_dir=output_dir,
                suffix=args.suffix,
            )
        except Exception as exc:  # pragma: no cover
            LOGGER.error("Failed to compute normalized S_NH4 for %s: %s", exp_path.name, exc)


if __name__ == "__main__":
    main()
