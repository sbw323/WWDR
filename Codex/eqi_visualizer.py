"""EQI visualization utility for ASM3 tagged datasets.

Given a set of experiment outputs under ``Tagged_Datasets``, this script
collects the instantaneous EQI series (``EQIvecinst``) for a chosen
reactor/settler across multiple iterations, then plots the individual
trajectories along with the per-timestep mean and ±1σ envelopes.
"""
from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Iterable, List, Sequence, Tuple

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from Codex.asm3_risk_tagging import ASM3_COLUMNS, STOICHIOMETRY, compute_eqi

EXPERIMENTS = {
    "4h": "Results_ExpLength_4h",
    "5h": "Results_ExpLength_5h",
    "6h": "Results_ExpLength_6h",
    "7h": "Results_ExpLength_7h",
}

SOURCES = {
    "reactor1": "reactor1_data_iteration_{iter_id}.csv",
    "reactor2": "reactor2_data_iteration_{iter_id}.csv",
    "reactor3": "reactor3_data_iteration_{iter_id}.csv",
    "reactor4": "reactor4_data_iteration_{iter_id}.csv",
    "reactor5": "reactor5_data_iteration_{iter_id}.csv",
    "settler": "settler_data_DR_iteration_{iter_id}.csv",
}

TIME_STEP_HOURS = 0.25  # 15-minute sampling


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--base-dir",
        default=Path("/Users/aya/github/WWDR/8AM_ASM3_DB/Tagged_Datasets"),
        type=Path,
        help="Root directory containing Results_ExpLength_* folders.",
    )
    parser.add_argument(
        "--experiment",
        choices=sorted(EXPERIMENTS.keys()),
        default="4h",
        help="Experiment length to visualize.",
    )
    parser.add_argument(
        "--source",
        choices=sorted(SOURCES.keys()),
        default="settler",
        help="Reactor/settler to visualize.",
    )
    parser.add_argument(
        "--iterations",
        nargs="*",
        help="Optional subset of iteration folder names (e.g. iter245 iter259)."
             " Defaults to all iterations present for the experiment.",
    )
    parser.add_argument(
        "--output-path",
        type=Path,
        help="Save the plot to this path instead of displaying it.",
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity.",
    )
    return parser.parse_args()


def discover_iterations(root: Path) -> List[str]:
    return sorted(p.name for p in root.iterdir() if p.is_dir())


def load_eqi_series(csv_path: Path) -> pd.Series:
    df = pd.read_csv(csv_path)
    if "EQIvecinst" not in df.columns:
        logging.debug("EQIvecinst missing in %s; recomputing", csv_path)
        if df.shape[1] == len(ASM3_COLUMNS):
            df.columns = ASM3_COLUMNS
        df["EQIvecinst"] = compute_eqi(df, STOICHIOMETRY)
    return df["EQIvecinst"]


def collect_series(
    base_dir: Path,
    experiment: str,
    source: str,
    iterations: Iterable[str] | None,
) -> Tuple[np.ndarray, List[str]]:
    exp_dir = base_dir / EXPERIMENTS[experiment] / "ASM3_OutputDB"
    if not exp_dir.exists():
        raise FileNotFoundError(f"Experiment directory not found: {exp_dir}")

    all_iters = discover_iterations(exp_dir)
    if not all_iters:
        raise FileNotFoundError(f"No iteration folders under {exp_dir}")

    if iterations:
        selected = []
        missing = []
        for item in iterations:
            if item in all_iters:
                selected.append(item)
            else:
                missing.append(item)
        if missing:
            raise FileNotFoundError(f"Iterations not found for {experiment}: {missing}")
    else:
        selected = all_iters

    pattern = SOURCES[source]
    series_list: List[np.ndarray] = []

    lengths: List[int] = []
    for iter_name in selected:
        iter_id = iter_name.replace("iter", "")
        csv_path = exp_dir / iter_name / pattern.format(iter_id=iter_id)
        if not csv_path.exists():
            logging.warning("Missing CSV: %s", csv_path)
            continue
        eqi_series = load_eqi_series(csv_path).to_numpy()
        series_list.append(eqi_series)
        lengths.append(len(eqi_series))

    if not series_list:
        raise RuntimeError("No EQI series were loaded; check inputs.")

    min_len = min(lengths)
    max_len = max(lengths)
    if min_len != max_len:
        logging.warning(
            "Series lengths inconsistent (min=%d, max=%d); clipping to %d samples",
            min_len,
            max_len,
            min_len,
        )
    clipped = np.vstack([series[:min_len] for series in series_list])
    return clipped, selected


def plot_eqi(
    matrix: np.ndarray,
    iterations: Sequence[str],
    experiment: str,
    source: str,
    output_path: Path | None,
) -> None:
    time_index = np.arange(matrix.shape[1]) * TIME_STEP_HOURS

    mean_series = matrix.mean(axis=0)
    std_series = matrix.std(axis=0, ddof=0)

    fig, ax = plt.subplots(figsize=(14, 7))

    # Individual trajectories in light lines
    ax.plot(time_index, matrix.T, color="lightgray", linewidth=0.6, alpha=0.6)

    # Mean and ±1σ envelope
    ax.plot(time_index, mean_series, color="tab:blue", linewidth=2.5, label="Mean EQI")
    ax.fill_between(
        time_index,
        mean_series - std_series,
        mean_series + std_series,
        color="tab:blue",
        alpha=0.2,
        label="±1σ",
    )

    ax.set_xlabel("Time (hours)")
    ax.set_ylabel("EQI")
    ax.set_title(f"EQI Trajectories – {source.title()} ({experiment})")

    total_days = time_index[-1] / 24
    day_marks = np.arange(0, matrix.shape[1] + 1, int(24 / TIME_STEP_HOURS))
    ax.set_xticks(day_marks * TIME_STEP_HOURS)
    ax.grid(True, which="both", linestyle="--", linewidth=0.5, alpha=0.5)
    ax.legend()

    text_lines = [
        f"Iterations plotted: {len(iterations)}",
        f"Mean EQI (overall): {mean_series.mean():.3e}",
        f"Std EQI (overall): {std_series.mean():.3e}",
    ]
    ax.text(
        0.02,
        0.02,
        "\n".join(text_lines),
        transform=ax.transAxes,
        fontsize=9,
        verticalalignment="bottom",
        bbox=dict(facecolor="white", alpha=0.6, edgecolor="None"),
    )

    plt.tight_layout()

    if output_path:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(output_path, dpi=300)
        logging.info("Saved EQI plot to %s", output_path)
        plt.close(fig)
    else:
        plt.show()


def main() -> None:
    args = parse_args()
    logging.basicConfig(level=getattr(logging, args.log_level.upper()), format="%(levelname)s: %(message)s")

    matrix, iterations = collect_series(args.base_dir, args.experiment, args.source, args.iterations)

    output_path = args.output_path
    if output_path and output_path.is_dir():
        output_path = output_path / f"eqi_{args.source}_{args.experiment}.png"

    plot_eqi(matrix, iterations, args.experiment, args.source, output_path)


if __name__ == "__main__":
    main()
