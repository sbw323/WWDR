#!/usr/bin/env python3
"""Standalone helper to append normalized-difference columns to stacked datasets."""

from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Dict, Optional, Sequence

import numpy as np
import pandas as pd

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

VARIABLES: Sequence[str] = ("S_NH4", "CODe")
INFLUENT_NORMALIZERS: Dict[str, str] = {
    "S_NH4": "S_NH4_ASin",
    "CODe": "CODe_ASin",
}
TIME_STEP_HOURS = 0.25
NORMALIZATION_LAG_STEPS = 0

LOGGER = logging.getLogger(__name__)


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def lag_array(values: np.ndarray, lag: int) -> np.ndarray:
    if lag <= 0:
        return values
    lagged = np.empty_like(values, dtype=float)
    lagged[:lag] = np.nan
    lagged[lag:] = values[:-lag]
    return lagged


def compute_eqi(
    df: pd.DataFrame,
    stoich: Dict[str, float] = STOICHIOMETRY,
    *,
    return_components: bool = False,
) -> pd.Series | tuple[pd.Series, Dict[str, pd.Series]]:
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

    if not return_components:
        return eqi

    components = {
        "SSe": sse,
        "CODe": code,
        "SNKJe": snkje,
        "SNOe": snoe,
        "BOD5e": bod5e,
    }
    return eqi, components


def prepare_for_alignment(df: pd.DataFrame, columns: Sequence[str]) -> pd.DataFrame:
    subset = df.loc[:, columns].astype(float).reset_index(drop=True)
    return subset


def compute_normalized_differences(
    exp_df: pd.DataFrame,
    nom_df: pd.DataFrame,
    influent_df: pd.DataFrame,
) -> tuple[np.ndarray, Dict[str, np.ndarray]]:
    min_len = min(len(exp_df), len(nom_df), len(influent_df))
    if min_len <= NORMALIZATION_LAG_STEPS:
        raise RuntimeError(
            "Insufficient timesteps after applying the normalization lag; "
            f"need more than {NORMALIZATION_LAG_STEPS} samples."
        )

    exp = exp_df.iloc[:min_len]
    nom = nom_df.iloc[:min_len]
    influent = influent_df.iloc[:min_len]

    diff = exp - nom
    time_axis = np.arange(min_len) * TIME_STEP_HOURS

    normalized: Dict[str, np.ndarray] = {}
    for var in VARIABLES:
        influent_series = influent[INFLUENT_NORMALIZERS[var]].to_numpy()
        nominal_series = nom[var].to_numpy()
        base_series = influent_series - nominal_series

        mean_value = float(np.nanmean(base_series))
        denom = lag_array(base_series, NORMALIZATION_LAG_STEPS)
        nan_mask = np.isnan(denom)
        if nan_mask.any():
            denom[nan_mask] = mean_value

        denom = np.where(np.abs(denom) < 1e-9, np.nan, denom)
        series = diff[var].to_numpy()
        normalized[var] = series / denom

    return time_axis, normalized


def append_cod_column(df: pd.DataFrame) -> pd.DataFrame:
    if not set(ASM3_COLUMNS).issubset(df.columns):
        missing = set(ASM3_COLUMNS) - set(df.columns)
        raise ValueError(f"Input frame missing required ASM3 columns: {sorted(missing)}")
    working = df.copy()
    numeric_state = working[ASM3_COLUMNS].astype(float)
    _, components = compute_eqi(numeric_state, return_components=True)
    cod_series = components.get("CODe")
    if cod_series is None:
        raise RuntimeError("compute_eqi did not return a CODe component.")
    cod_series = cod_series.reset_index(drop=True)
    working["CODe"] = cod_series
    working["COD"] = cod_series
    return working


def compute_normalized_columns(
    exp_df: pd.DataFrame,
    nom_df: pd.DataFrame,
    influent_df: pd.DataFrame,
) -> Dict[str, pd.Series]:
    exp_ready = prepare_for_alignment(exp_df, VARIABLES)
    influent_ready = prepare_for_alignment(influent_df, [INFLUENT_NORMALIZERS[var] for var in VARIABLES])

    nominal_columns = [col for col in nom_df.columns if col in VARIABLES]
    if len(nominal_columns) < len(VARIABLES):
        raise ValueError("Nominal dataset does not contain all required variables.")
    nominal_numeric = nom_df.loc[:, nominal_columns].astype(float).reset_index(drop=True)
    min_len = min(len(exp_ready), len(nominal_numeric), len(influent_ready))
    if min_len <= NORMALIZATION_LAG_STEPS:
        raise RuntimeError(
            "Insufficient timesteps after applying the normalization lag; need more samples."
        )

    exp_aligned = exp_ready.iloc[:min_len].reset_index(drop=True)
    nom_aligned = nominal_numeric.iloc[:min_len].reset_index(drop=True)
    influent_aligned = influent_ready.iloc[:min_len].reset_index(drop=True)
    influent_aligned.columns = VARIABLES

    _, normalized = compute_normalized_differences(exp_aligned, nom_aligned, influent_aligned)
    return {f"normalized_{var}": pd.Series(values) for var, values in normalized.items()}


def process_file(
    experiment_path: Path,
    *,
    nominal_dir: Path,
    destination: Path,
) -> None:
    LOGGER.info("Processing %s", experiment_path.name)
    exp_df = pd.read_csv(experiment_path)
    exp_df = append_cod_column(exp_df)

    unit_prefix = experiment_path.name.split("_")[0]
    nominal_path = nominal_dir / f"{unit_prefix}_0hr_day0.csv"
    if not nominal_path.exists():
        raise FileNotFoundError(f"Baseline nominal file not found: {nominal_path}")

    nom_df = pd.read_csv(nominal_path)
    nom_df = append_cod_column(nom_df)

    normalized = compute_normalized_columns(exp_df, nom_df, exp_df)

    for column, series in normalized.items():
        exp_df[column] = series.to_numpy()

    destination.parent.mkdir(parents=True, exist_ok=True)
    exp_df.to_csv(destination, index=False)
    LOGGER.info("Wrote %s", destination)


def iter_csv_files(root: Path) -> Sequence[Path]:
    return sorted(path for path in root.glob("*.csv") if path.is_file())


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Compute normalized difference columns for stacked datasets."
    )
    parser.add_argument(
        "--input-dir",
        type=Path,
        default=Path("/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/normalized_outputs"),
        help="Directory containing experiment stacked CSV files.",
    )
    parser.add_argument(
        "--nominal-dir",
        type=Path,
        default=Path("/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/Nominal_Stacked"),
        help="Directory containing nominal baseline CSV files.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path("/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/normalized_outputs_new"),
        help="Directory where processed files will be written.",
    )
    parser.add_argument(
        "--suffix",
        default="_new",
        help="Suffix appended to the output filenames (default: _new).",
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
    output_dir.mkdir(parents=True, exist_ok=True)

    csv_files = iter_csv_files(input_dir)
    if not csv_files:
        LOGGER.warning("No CSV files found in %s", input_dir)
        return

    for csv_path in csv_files:
        destination = output_dir / (csv_path.stem + args.suffix + csv_path.suffix)
        process_file(csv_path, nominal_dir=nominal_dir, destination=destination)


if __name__ == "__main__":
    main()
