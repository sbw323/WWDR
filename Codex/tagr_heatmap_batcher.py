"""Generate per-iteration TagR heatmaps from asm3_risk_tagging.py outputs."""
from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Dict, Iterable, List, Sequence, Tuple

import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

EXPERIMENTS: Sequence[Tuple[str, str]] = (
    ("Results_ExpLength_4h", "4h"),
    ("Results_ExpLength_5h", "5h"),
    ("Results_ExpLength_6h", "6h"),
    ("Results_ExpLength_7h", "7h"),
)

SOURCES: Sequence[Tuple[str, str, str]] = (
    ("reactor1", "R1", "reactor1_data_iteration_{iter_id}.csv"),
    ("reactor2", "R2", "reactor2_data_iteration_{iter_id}.csv"),
    ("reactor3", "R3", "reactor3_data_iteration_{iter_id}.csv"),
    ("reactor4", "R4", "reactor4_data_iteration_{iter_id}.csv"),
    ("reactor5", "R5", "reactor5_data_iteration_{iter_id}.csv"),
    ("settler", "S", "settler_data_DR_iteration_{iter_id}.csv"),
)

CMAP = mcolors.ListedColormap(["black", "green", "yellow", "orange", "red"])
TIMESTEPS_PER_DAY = 96
DAYS_PER_ITERATION = 14
SAMPLES_PER_ITERATION = TIMESTEPS_PER_DAY * DAYS_PER_ITERATION


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--base-dir",
        default=Path("/Users/aya/github/WWDR/8AM_ASM3_DB/Tagged_Datasets"),
        type=Path,
        help="Root directory containing Results_ExpLength_* folders with tagged CSVs.",
    )
    parser.add_argument(
        "--iterations",
        nargs="*",
        help="Optional iteration folder names to include (e.g. iter245 iter259). Defaults to the intersection across experiments.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="Directory to save the generated heatmaps. If omitted, figures display interactively.",
    )
    parser.add_argument(
        "--log-level",
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Logging verbosity.",
    )
    return parser.parse_args()


def read_tagR(csv_path: Path) -> np.ndarray:
    df = pd.read_csv(csv_path)
    for key in ("tagR", "TagR"):
        if key in df.columns:
            return df[key].to_numpy()
    raise KeyError(f"TagR column not found in {csv_path}")


def available_iterations(base_dir: Path) -> Dict[str, List[str]]:
    mapping: Dict[str, List[str]] = {}
    for exp_dir, _ in EXPERIMENTS:
        root = base_dir / exp_dir / "ASM3_OutputDB"
        if not root.exists():
            raise FileNotFoundError(f"Missing output directory: {root}")
        iters = sorted(p.name for p in root.iterdir() if p.is_dir())
        if not iters:
            raise FileNotFoundError(f"No iteration folders under {root}")
        mapping[exp_dir] = iters
    return mapping


def resolve_iterations(requested: Iterable[str] | None, mapping: Dict[str, List[str]]) -> List[str]:
    if requested:
        requested = list(dict.fromkeys(requested))
        missing = [name for name in requested if any(name not in iters for iters in mapping.values())]
        if missing:
            raise FileNotFoundError(
                f"Requested iterations are unavailable in every experiment directory: {missing}"
            )
        return requested

    common = set(mapping[next(iter(mapping))])
    for iters in mapping.values():
        common &= set(iters)
    if not common:
        raise ValueError("No common iteration folders found across experiment lengths")
    return sorted(common)


def load_iteration_matrix(base_dir: Path, iteration: str) -> Tuple[np.ndarray, List[str]]:
    rows: List[np.ndarray] = []
    labels: List[str] = []
    lengths: List[int] = []
    iter_id = iteration.replace("iter", "")

    for source_key, source_label, template in SOURCES:
        for exp_dir, exp_label in EXPERIMENTS:
            csv_path = base_dir / exp_dir / "ASM3_OutputDB" / iteration / template.format(iter_id=iter_id)
            if not csv_path.exists():
                raise FileNotFoundError(f"Missing CSV: {csv_path}")
            series = read_tagR(csv_path)
            rows.append(series)
            labels.append(f"{source_label} {exp_label}")
            lengths.append(len(series))

    if not rows:
        raise RuntimeError(f"No TagR data collected for iteration {iteration}")

    min_len = min(lengths)
    max_len = max(lengths)
    if min_len != max_len:
        logging.warning(
            "Iteration %s has inconsistent lengths (min=%d, max=%d); clipping to %d entries",
            iteration,
            min_len,
            max_len,
            min_len,
        )

    clipped_rows = [series[:min_len] for series in rows]
    matrix = np.vstack(clipped_rows)
    return matrix, labels


def plot_iteration_heatmap(
    matrix: np.ndarray,
    labels: Sequence[str],
    iteration: str,
    output_path: Path | None,
) -> None:
    num_rows, num_cols = matrix.shape
    start_day = int(iteration.replace("iter", ""))
    day_ticks = [i * TIMESTEPS_PER_DAY for i in range(DAYS_PER_ITERATION + 1)]
    day_labels = [str(start_day + i) for i in range(DAYS_PER_ITERATION + 1)]

    fig, ax = plt.subplots(figsize=(14, 8))
    im = ax.imshow(matrix, aspect="auto", cmap=CMAP, interpolation="nearest", vmin=0, vmax=4)

    ax.set_yticks(range(num_rows))
    ax.set_yticklabels(labels)

    ax.set_xticks(day_ticks)
    ax.set_xticklabels(day_labels)
    ax.set_xlim(0, num_cols - 1)
    ax.set_xlabel("Day")
    ax.set_title(
        f"ASM3 TagR Heatmap – {iteration} (Days {start_day}–{start_day + DAYS_PER_ITERATION})"
    )

    for x in day_ticks:
        ax.axvline(x, color="white", linewidth=0.6, alpha=0.3)

    cbar = plt.colorbar(im, ticks=[0, 1, 2, 3, 4])
    cbar.set_label("TagR")

    plt.tight_layout()
    if output_path:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(output_path, dpi=300)
        logging.info("Saved heatmap to %s", output_path)
        plt.close(fig)
    else:
        plt.show()


def main() -> None:
    args = parse_args()
    logging.basicConfig(level=getattr(logging, args.log_level.upper()), format="%(levelname)s: %(message)s")

    iteration_map = available_iterations(args.base_dir)
    iterations = resolve_iterations(args.iterations, iteration_map)
    logging.info("Rendering %d iteration heatmaps", len(iterations))

    for iteration in iterations:
        matrix, labels = load_iteration_matrix(args.base_dir, iteration)
        if matrix.shape[1] != SAMPLES_PER_ITERATION:
            logging.warning(
                "Iteration %s has %d samples (expected %d)",
                iteration,
                matrix.shape[1],
                SAMPLES_PER_ITERATION,
            )

        output_path = None
        if args.output_dir:
            output_path = args.output_dir / f"tagr_heatmap_{iteration}.png"

        plot_iteration_heatmap(matrix, labels, iteration, output_path)


if __name__ == "__main__":
    main()
