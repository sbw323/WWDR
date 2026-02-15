#!/usr/bin/env python3
"""Render a 3D scatter plot from settler_experiment_results_MAX.csv."""

from __future__ import annotations

import argparse
from pathlib import Path

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401  (activates 3D projection)
import pandas as pd
import numpy as np
from matplotlib import cm
from matplotlib.ticker import FuncFormatter


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="3D plot for settler_experiment_results_MAX.csv.")
    parser.add_argument(
        "--input",
        type=Path,
        required=True,
        help="Path to settler_experiment_results_MAX.csv",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("settler_results_3d.png"),
        help="Output image file (default: settler_results_3d.png)",
    )
    parser.add_argument(
        "--y-column",
        choices=["max_SNH4_nomdiff_norm", "max_SNH4_inf_norm", "max_SNH4_nom_norm"],
        default="max_SNH4_nomdiff_norm",
        help="Column to plot on the Y axis (default: max_SNH4_nomdiff_norm).",
    )
    return parser.parse_args()


def load_data(csv_path: Path, y_column: str) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    required = {"duration_hr", "energy_reduc", y_column}
    missing = required - set(df.columns)
    if missing:
        raise ValueError(f"Missing required columns in {csv_path}: {sorted(missing)}")
    df = df.copy()
    df["duration_days"] = df["duration_hr"] / 24.0
    return df


def build_surface_grid(steps: int = 96):
    """Create X, Y grids and corresponding Z values for the reference surface."""
    r3 = 14.811
    r4 = 14.811
    r5 = 5.183
    coeff = r3 + r4 + r5
    norm = coeff*24

    x_vals = np.linspace(1.0, 0.0, steps, endpoint=False)
    y_vals = np.linspace(1.0 / steps, 1.0, steps)

    X, Y = np.meshgrid(x_vals, y_vals)
    Z = (coeff * X * Y * 24)/norm
    return X, Y, Z


def plot_3d(df: pd.DataFrame, y_column: str, output_path: Path) -> None:
    fig = plt.figure(figsize=(8, 6))
    ax = fig.add_subplot(111, projection="3d")

    # Reassign axes: X -> energy_reduc, Y -> duration_days, Z -> selected column
    x = 1 - df["energy_reduc"]
    y = df["duration_days"]
    z_raw = df[y_column]
    z_max = z_raw.max() if not df.empty else 1.0
    z = z_raw / z_max if z_max else z_raw

    scatter = ax.scatter(x, y, z, c=z, cmap="viridis", depthshade=True)
    ax.set_xlabel("Energy Reduction")
    ax.set_ylabel("Duration (days)")
    ax.set_zlabel(y_column)
    ax.set_xlim(0, 1.0)
    ax.set_ylim(0, 1.0)
    ax.invert_yaxis()  # Reverse Y so axes start from the same corner as X.
    ax.set_zlim(0, 1.0)
    ax.view_init(elev=0, azim=180)  # tilt up 30°, rotate 120°

    # Add energy reduction surface with 30% transparency.
    X, Y, Z = build_surface_grid()
    ax.plot_surface(X, Y, Z, cmap=cm.viridis, linewidth=0, antialiased=True, alpha=0.3)

    # Re-label Z ticks to show denormalized values.
    formatter = FuncFormatter(lambda tick, _: f"{tick * z_max:.2f}")
    ax.zaxis.set_major_formatter(formatter)

    fig.colorbar(scatter, ax=ax, label="Energy Reduction")
    fig.tight_layout()

    output_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output_path, dpi=300)
    plt.close(fig)
    print(f"Saved plot to {output_path}")


def main() -> None:
    args = parse_args()
    df = load_data(args.input, args.y_column)
    plot_3d(df, args.y_column, args.output)


if __name__ == "__main__":
    main()
