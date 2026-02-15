#!/usr/bin/env python3
"""Plot max_SNH4_nomdiff_norm vs Total Energy Volume derived from settler_experiment_results_MAX.csv."""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Optional, Sequence

import matplotlib.pyplot as plt
import pandas as pd

# Constants from build_surface_grid in plot_settler_results_3d.py
R3 = 14.811
R4 = 14.811
R5 = 5.183
COEFF = R3 + R4 + R5
MAX_E = COEFF * 96

REQUIRED_COLUMNS = ["duration_hr", "energy_reduc", "max_SNH4_nomdiff_norm"]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Plot max_SNH4_nomdiff_norm vs Total Energy Volume derived from settler_experiment_results_MAX.csv."
    )
    parser.add_argument(
        "--input",
        type=Path,
        default=Path(
            "/Users/ikai/github/WWDR-Databases/Databases/Nov25/naive_stacked_data/with_snh4_norm/vessel_experiment_results/settler_experiment_results_MAX.csv"
        ),
        help="Path to settler_experiment_results_MAX.csv",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("snh4_vs_total_energy.png"),
        help="Output image file (default: snh4_vs_total_energy.png)",
    )
    parser.add_argument(
        "--line",
        action="store_true",
        help="Connect points with a line sorted by Total Energy.",
    )
    parser.add_argument(
        "--filter-window-index",
        type=int,
        nargs="+",
        help="Only plot rows matching these window_index values.",
    )
    parser.add_argument(
        "--filter-duration-hr",
        type=float,
        nargs="+",
        help="Only plot rows matching these duration_hr values.",
    )
    return parser.parse_args()


def load_and_prepare(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    missing = [col for col in REQUIRED_COLUMNS if col not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns {missing} in {csv_path}")
    df = df.copy()
    df["total_energy_vol"] = (COEFF * df["duration_hr"] * (1-df["energy_reduc"]) * 4)/MAX_E
    return df


def plot_data(
    df: pd.DataFrame,
    output_path: Path,
    connect_line: bool,
    filter_window: Optional[Sequence[int]] = None,
    filter_duration: Optional[Sequence[float]] = None,
) -> None:
    if filter_window:
        df = df[df["window_index"].isin(filter_window)]
    if filter_duration:
        df = df[df["duration_hr"].isin(filter_duration)]
    if df.empty:
        raise ValueError("No data to plot after applying filters.")

    fig, ax = plt.subplots(figsize=(8, 5))
    x = df["total_energy_vol"]
    y = df["max_SNH4_nomdiff_norm"]
    # Scale marker sizes based on duration_hr
    dur = df["duration_hr"]
    size_scaled = 20 + 80 * (dur - dur.min()) / (dur.max() - dur.min()) if dur.max() != dur.min() else 50

    markers = ["o", "s", "^", "v", "D", "P", "X", "*", "h"]
    scatter_handles = []
    for idx, marker in enumerate(markers):
        subset = df[df["window_index"] == idx]
        if subset.empty:
            continue
        x_sub = subset["total_energy_vol"]
        y_sub = subset["max_SNH4_nomdiff_norm"]
        dur_sub = subset["duration_hr"]
        sizes_sub = (
            20 + 80 * (dur_sub - dur.min()) / (dur.max() - dur.min()) if dur.max() != dur.min() else 50
        )
        h = ax.scatter(
            x_sub,
            y_sub,
            c=dur_sub,
            s=sizes_sub,
            cmap="viridis",
            alpha=0.7,
            marker=marker,
            label=f"window {idx}",
        )
        scatter_handles.append(h)

    if connect_line:
        sorted_df = df.sort_values("total_energy_vol")
        ax.plot(sorted_df["total_energy_vol"], sorted_df["max_SNH4_nomdiff_norm"], color="C1", alpha=0.7, label="Trend")

    ax.set_xlabel("Total Energy Volume")
    ax.set_ylabel("max_SNH4_nomdiff_norm")
    ax.grid(True, linestyle="--", alpha=0.5)
    if scatter_handles:
        ax.legend(handles=scatter_handles, title="window_index")
    if scatter_handles:
        cbar = fig.colorbar(scatter_handles[0], ax=ax, label="duration_hr")
    else:
        cbar = None
    fig.tight_layout()

    output_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output_path, dpi=300)
    plt.close(fig)
    print(f"Saved plot to {output_path}")


def main() -> None:
    args = parse_args()
    df = load_and_prepare(args.input)
    plot_data(
        df,
        args.output,
        args.line,
        filter_window=args.filter_window_index,
        filter_duration=args.filter_duration_hr,
    )


if __name__ == "__main__":
    main()
