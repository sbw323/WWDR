#!/usr/bin/env python3
"""Attach influent data columns to stacked experiment CSV files."""

from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Optional, Sequence

import pandas as pd

from Codex.energy_use_utils import ENERGY_USE_PREFIX, build_energy_use_column_name
LOGGER = logging.getLogger(__name__)

DEFAULT_INPUT = Path(
    "/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data"
)
DEFAULT_OUTPUT = Path(
    "/Users/ikai/github/WWDR/Databases/3dayspread_ASM3-KLa5-84/naive_stacked_data/with_influent"
)
DEFAULT_INFLUENT = Path(
    "/Users/ikai/github/WWDR/Databases/Influent/influent.csv"
)


def configure_logging(level: str) -> None:
    logging.basicConfig(level=getattr(logging, level), format="%(levelname)s: %(message)s")


def load_influent_columns(metadata_path: Path) -> list[str]:
    with metadata_path.open("r", encoding="utf-8") as handle:
        return [line.strip() for line in handle if line.strip()]


def load_influent_data(csv_path: Path, columns: list[str]) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    df.columns = [str(col).strip() for col in df.columns]

    if "ticker" not in (col.lower() for col in df.columns):
        # Re-read without headers and assign expected names if none available.
        df = pd.read_csv(csv_path, header=None)
        if df.shape[1] < len(columns):
            raise ValueError(
                f"Influent CSV {csv_path} must contain at least {len(columns)} columns."
            )
        df = df.iloc[:, : len(columns)]
        df.columns = columns

    # Normalize the ticker column name.
    ticker_col = next(col for col in df.columns if col.lower() == "ticker")
    if ticker_col != "ticker":
        df = df.rename(columns={ticker_col: "ticker"})

    df = df.apply(pd.to_numeric, errors="ignore")
    df["ticker_key"] = pd.to_numeric(df["ticker"], errors="coerce").round(4)
    df = df.dropna(subset=["ticker_key"])
    df = df.drop_duplicates(subset="ticker_key", keep="first")
    return df


def ensure_ticker(series_df: pd.DataFrame) -> pd.DataFrame:
    df = series_df.copy()
    df.columns = [str(col).strip() for col in df.columns]
    ticker_candidates = [col for col in df.columns if col.lower().startswith("ticker")]
    if not ticker_candidates:
        raise ValueError("Dataset lacks a ticker column (e.g., 'ticker' or 'ticker_x').")
    ticker_col = ticker_candidates[0]
    df = df.rename(columns={ticker_col: "ticker"})
    df["ticker_key"] = pd.to_numeric(df["ticker"], errors="coerce").round(4)
    df = df.dropna(subset=["ticker_key"])
    return df


def ensure_energy_use_column(df: pd.DataFrame, *, identifier: Path) -> pd.DataFrame:
    """Normalize energy-use column naming to include the dataset's reactor suffix."""
    energy_columns = [col for col in df.columns if str(col).lower().startswith(ENERGY_USE_PREFIX)]
    if not energy_columns:
        return df
    try:
        target_name = build_energy_use_column_name(identifier)
    except ValueError as exc:
        LOGGER.warning(
            "Energy-use column detected in %s but reactor suffix could not be derived: %s",
            identifier,
            exc,
        )
        return df
    if target_name in df.columns:
        return df
    rename_map = {energy_columns[0]: target_name}
    if len(energy_columns) > 1:
        LOGGER.warning(
            "Multiple energy-use columns found in %s; renaming first occurrence (%s -> %s).",
            identifier.name,
            energy_columns[0],
            target_name,
        )
    return df.rename(columns=rename_map)


def append_influent(df: pd.DataFrame, influent_df: pd.DataFrame) -> pd.DataFrame:
    working = ensure_ticker(df)

    # Remove duplicate columns that already exist in the experiment dataset.
    influent_cols = [col for col in influent_df.columns if col not in {"ticker", "ticker_key"}]
    overlap = set(working.columns) & set(influent_cols)
    if overlap:
        LOGGER.warning("Overwriting existing columns from influent data: %s", sorted(overlap))
        working = working.drop(columns=list(overlap))

    merged = working.merge(
        influent_df[["ticker_key", *influent_cols]],
        on="ticker_key",
        how="left",
    )
    merged = merged.drop(columns="ticker_key")
    return merged


def process_file(
    path: Path,
    *,
    influent_df: pd.DataFrame,
    output_dir: Path,
    suffix: str,
) -> None:
    LOGGER.info("Joining influent data with %s", path.name)
    df = pd.read_csv(path)
    df = ensure_energy_use_column(df, identifier=path)
    merged = append_influent(df, influent_df)
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / f"{path.stem}{suffix}{path.suffix}"
    merged.to_csv(output_path, index=False)
    LOGGER.info("Wrote %s", output_path)


def iter_csv(root: Path) -> list[Path]:
    return sorted(p for p in root.glob("*.csv") if p.is_file())


def parse_arguments(argv: Optional[Sequence[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Join stacked experiment CSVs with influent data.")
    parser.add_argument("--input-dir", type=Path, default=DEFAULT_INPUT, help="Stacked CSV directory.")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=DEFAULT_OUTPUT,
        help="Destination directory for joined CSV files.",
    )
    parser.add_argument(
        "--influent-csv",
        type=Path,
        default=DEFAULT_INFLUENT,
        help="Path to influent CSV file.",
    )
    parser.add_argument(
        "--influent-metadata",
        type=Path,
        default=Path("Codex/influent_columns.md"),
        help="Path to the metadata file listing influent column names.",
    )
    parser.add_argument(
        "--suffix",
        default="_influent",
        help="Suffix appended to output filenames (default: _influent).",
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
    influent_csv = args.influent_csv.expanduser().resolve()
    metadata_path = args.influent_metadata.expanduser().resolve()

    if not input_dir.exists():
        raise FileNotFoundError(f"Input directory not found: {input_dir}")
    if not influent_csv.exists():
        raise FileNotFoundError(f"Influent CSV not found: {influent_csv}")
    if not metadata_path.exists():
        raise FileNotFoundError(f"Influent metadata file not found: {metadata_path}")

    influent_columns = load_influent_columns(metadata_path)
    influent_df = load_influent_data(influent_csv, influent_columns)
    LOGGER.info("Loaded influent data with %d rows", len(influent_df))

    csv_files = iter_csv(input_dir)
    if not csv_files:
        LOGGER.warning("No CSV files found in %s", input_dir)
        return

    for path in csv_files:
        try:
            process_file(path, influent_df=influent_df, output_dir=output_dir, suffix=args.suffix)
        except Exception as exc:  # pragma: no cover - defensive
            LOGGER.error("Failed to join influent data for %s: %s", path.name, exc)


if __name__ == "__main__":
    main()
