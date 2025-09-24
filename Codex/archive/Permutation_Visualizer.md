```python
"""Visualize TagR heatmaps created from asm3_risk_tagging.py outputs."""
import argparse
import logging
from pathlib import Path

import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

EXPERIMENTS = [
    ("Results_ExpLength_4h", "4h"),
    ("Results_ExpLength_5h", "5h"),
    ("Results_ExpLength_6h", "6h"),
    ("Results_ExpLength_7h", "7h"),
]

SOURCES = [
    ("reactor1", "R1", "reactor1_data_iteration_{iter_id}.csv"),
    ("reactor2", "R2", "reactor2_data_iteration_{iter_id}.csv"),
    ("reactor3", "R3", "reactor3_data_iteration_{iter_id}.csv"),
    ("reactor4", "R4", "reactor4_data_iteration_{iter_id}.csv"),
    ("reactor5", "R5", "reactor5_data_iteration_{iter_id}.csv"),
    ("settler", "S", "settler_data_DR_iteration_{iter_id}.csv"),
]

CMAP = mcolors.ListedColormap(["black", "red", "orange", "green", "blue"])


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
        "--save-path",
        type=Path,
        help="Write the heatmap to this path instead of displaying it interactively.",
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
    raise KeyError(f"TagR column missing in {csv_path}")


def discover_iterations(base_dir: Path) -> dict[str, list[str]]:
    mapping: dict[str, list[str]] = {}
    for exp_dir, _ in EXPERIMENTS:
        root = base_dir / exp_dir / "ASM3_OutputDB"
        if not root.exists():
            raise FileNotFoundError(f"Missing directory: {root}")
        iters = sorted(p.name for p in root.iterdir() if p.is_dir())
        if not iters:
            raise FileNotFoundError(f"No iteration folders found under {root}")
        mapping[exp_dir] = iters
    return mapping


def select_iterations(requested: list[str] | None, mapping: dict[str, list[str]]) -> list[str]:
    if requested:
        unknown = [name for name in requested if any(name not in iters for iters in mapping.values())]
        if unknown:
            raise FileNotFoundError(f"Requested iterations are not present in every experiment: {unknown}")
        return list(dict.fromkeys(requested))

    common = set(mapping[next(iter(mapping))])
    for iters in mapping.values():
        common &= set(iters)
    if not common:
        raise ValueError("No common iterations across experiment folders")
    return sorted(common)


def load_tagR(base_dir: Path, iterations: list[str]):
    cache = {}
    min_len = None

    for exp_dir, _ in EXPERIMENTS:
        exp_root = base_dir / exp_dir / "ASM3_OutputDB"
        for iteration in iterations:
            iter_id = iteration.replace("iter", "")
            for source_key, _, template in SOURCES:
                csv_path = exp_root / iteration / template.format(iter_id=iter_id)
                if not csv_path.exists():
                    raise FileNotFoundError(f"Missing CSV: {csv_path}")
                series = read_tagR(csv_path)
                cache[(exp_dir, source_key, iteration)] = series
                if min_len is None or len(series) < min_len:
                    min_len = len(series)

    if min_len is None:
        raise RuntimeError("Unable to determine TagR lengths")
    return cache, min_len


def build_matrix(cache, iterations, block_len):
    rows = []
    labels = []

    for source_key, label, _ in SOURCES:
        for exp_dir, exp_label in EXPERIMENTS:
            labels.append(f"{label} {exp_label}")
            segments = [cache[(exp_dir, source_key, iteration)][:block_len] for iteration in iterations]
            rows.append(np.concatenate(segments))

    matrix = np.vstack(rows)
    return matrix, labels


def plot_heatmap(matrix: np.ndarray, labels: list[str], iterations: list[str], save_path: Path | None) -> None:
    block_len = matrix.shape[1] // len(iterations)

    fig, ax = plt.subplots(figsize=(14, 8))
    im = ax.imshow(matrix, aspect="auto", cmap=CMAP, interpolation="nearest", vmin=0, vmax=4)

    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels)

    tick_positions = [(idx + 0.5) * block_len for idx in range(len(iterations))]
    ax.set_xticks(tick_positions)
    ax.set_xticklabels(iterations, rotation=45, ha="right")
    ax.set_xlabel("Iterations (TagR samples concatenated)")
    ax.set_title("ASM3 TagR Heatmap by Reactor and Experiment Length")

    cbar = plt.colorbar(im, ticks=[0, 1, 2, 3, 4])
    cbar.set_label("TagR")

    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=300)
    else:
        plt.show()


def main() -> None:
    args = parse_args()
    logging.basicConfig(level=getattr(logging, args.log_level.upper()), format="%(levelname)s: %(message)s")

    iteration_map = discover_iterations(args.base_dir)
    iterations = select_iterations(args.iterations, iteration_map)
    logging.info("Using iterations: %s", ", ".join(iterations))

    cache, block_len = load_tagR(args.base_dir, iterations)
    matrix, labels = build_matrix(cache, iterations, block_len)
    plot_heatmap(matrix, labels, iterations, args.save_path)


if __name__ == "__main__":
    main()
```
