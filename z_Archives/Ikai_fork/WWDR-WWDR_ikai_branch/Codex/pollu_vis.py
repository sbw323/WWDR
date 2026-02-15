"""Pollutant component percentile visualization for ASM3 datasets.

This tool compares tagged experimental outputs against their nominal
baselines for the pollutant-oriented EQI components (SSe, CODe, SNKJe,
SNOe, BOD5e). For each experiment length it collects matching iterations,
computes the time-series differences, derives the 10th/50th/95th/99th
percentiles, and renders a five-panel plot (one per component).
"""
from __future__ import annotations

import argparse
import logging
from pathlib import Path
from typing import Dict, Iterable, List, Sequence, Tuple
from dataclasses import dataclass

try:
    import numpy as np
except ModuleNotFoundError as exc:  # pragma: no cover - informative guard
    raise SystemExit("numpy is required for Codex.pollu_vis.") from exc
import pandas as pd

try:  # pragma: no cover - optional plotting dependency
    import matplotlib.pyplot as plt
except ModuleNotFoundError:  # pragma: no cover - optional plotting dependency
    plt = None


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


def compute_eqi(
    df: pd.DataFrame,
    stoich: dict[str, float] = STOICHIOMETRY,
    *,
    return_components: bool = False,
) -> pd.Series | tuple[pd.Series, dict[str, pd.Series]]:
    """Compute the instantaneous Effluent Quality Index (EQI).

    When ``return_components`` is True, the function also returns the contributing
    terms (SSe, CODe, SNKJe, SNOe, BOD5e) so callers can persist them.
    """
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

EXPERIMENTS: Dict[str, str] = {
    "4h": "Results_ExpLength_4h_0",
    "5h": "Results_ExpLength_5h_0",
    "6h": "Results_ExpLength_6h_0",
    "7h": "Results_ExpLength_7h_0",
}

SOURCES: Dict[str, str] = {
    "reactor1": "reactor1_data_iteration_{iter_id}.csv",
    "reactor2": "reactor2_data_iteration_{iter_id}.csv",
    "reactor3": "reactor3_data_iteration_{iter_id}.csv",
    "reactor4": "reactor4_data_iteration_{iter_id}.csv",
    "reactor5": "reactor5_data_iteration_{iter_id}.csv",
    "settler": "settler_data_DR_iteration_{iter_id}.csv",
}

COMPONENTS: Sequence[str] = ("SSe", "CODe", "SNKJe", "SNOe", "BOD5e")
PERCENTILES: Sequence[int] = (10, 50, 95, 99)
TIME_STEP_HOURS = 0.25


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--base-dir",
        default=Path("/Users/aya/github/WWDR/8AM_ASM3_DB/Tagged_Datasets"),
        type=Path,
        help="Directory containing Results_ExpLength_* folders with tagged experimental CSVs.",
    )
    parser.add_argument(
        "--nominal-dir",
        default=Path("/Users/aya/github/WWDR/8AM_ASM3_DB/Results_Nominal/ASM3_OutputDB"),
        type=Path,
        help="Directory containing nominal ASM3_OutputDB iteration folders.",
    )
    parser.add_argument(
        "--experiments",
        nargs="*",
        choices=sorted(EXPERIMENTS.keys()),
        help="Subset of experiment lengths to process (default: all).",
    )
    parser.add_argument(
        "--source",
        choices=sorted(SOURCES.keys()),
        default="settler",
        help="Reactor/settler dataset to analyze.",
    )
    parser.add_argument(
        "--iterations",
        nargs="*",
        help="Optional subset of iteration folder names (e.g. iter245 iter259). Applies to every experiment length.",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        help="If supplied, save figures into this directory instead of displaying them.",
    )
    parser.add_argument(
        "--no-show",
        action="store_true",
        help="Suppress interactive display (useful when only saving figures).",
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


def load_experimental_components(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path)
    if not all(col in df.columns for col in COMPONENTS):
        logging.debug("Components missing in %s; recomputing", csv_path)
        if df.shape[1] == len(ASM3_COLUMNS):
            df.columns = ASM3_COLUMNS
        _, components = compute_eqi(df, return_components=True)
        for name, series in components.items():
            df[name] = series
    return df[list(COMPONENTS)]


def load_nominal_components(csv_path: Path) -> pd.DataFrame:
    df = pd.read_csv(csv_path, header=None, names=ASM3_COLUMNS)
    _, components = compute_eqi(df, return_components=True)
    return pd.DataFrame(components)


def collect_differences(
    experiment_root: Path,
    nominal_root: Path,
    pattern: str,
    iterations: Iterable[str] | None,
) -> Dict[str, List[np.ndarray]]:
    exp_iters = discover_iterations(experiment_root)
    if not exp_iters:
        raise FileNotFoundError(f"No iteration folders under {experiment_root}")

    if iterations:
        selected: List[str] = []
        missing: List[str] = []
        for name in iterations:
            if name in exp_iters:
                selected.append(name)
            else:
                missing.append(name)
        if missing:
            raise FileNotFoundError(f"Iterations missing in experiment data: {missing}")
    else:
        selected = exp_iters

    differences: Dict[str, List[np.ndarray]] = {comp: [] for comp in COMPONENTS}

    for iter_name in selected:
        iter_id = iter_name.replace("iter", "")
        exp_csv = experiment_root / iter_name / pattern.format(iter_id=iter_id)
        nominal_csv = nominal_root / iter_name / pattern.format(iter_id=iter_id)

        if not exp_csv.exists():
            logging.warning("Experimental CSV missing: %s", exp_csv)
            continue
        if not nominal_csv.exists():
            logging.warning("Nominal CSV missing: %s", nominal_csv)
            continue

        exp_df = load_experimental_components(exp_csv)
        nom_df = load_nominal_components(nominal_csv)

        min_len = min(len(exp_df), len(nom_df))
        if len(exp_df) != len(nom_df):
            logging.debug(
                "Length mismatch for %s (exp=%d, nominal=%d); clipping to %d",
                iter_name,
                len(exp_df),
                len(nom_df),
                min_len,
            )
        diff = exp_df.iloc[:min_len] - nom_df.iloc[:min_len]

        for comp in COMPONENTS:
            differences[comp].append(diff[comp].to_numpy())

    return differences


def compute_percentiles(differences: Dict[str, List[np.ndarray]]) -> Tuple[Dict[str, Dict[int, np.ndarray]], int]:
    percentile_data: Dict[str, Dict[int, np.ndarray]] = {}
    series_length = None

    for comp, series_list in differences.items():
        if not series_list:
            continue
        min_len = min(len(arr) for arr in series_list)
        stack = np.vstack([arr[:min_len] for arr in series_list])
        comp_percentiles = {pct: np.percentile(stack, pct, axis=0) for pct in PERCENTILES}
        percentile_data[comp] = comp_percentiles
        if series_length is None or min_len < series_length:
            series_length = min_len

    if not percentile_data or series_length is None:
        raise RuntimeError("No percentile data computed; ensure inputs contain data.")

    return percentile_data, series_length


def plot_percentiles(
    percentile_data: Dict[str, Dict[int, np.ndarray]],
    series_length: int,
    experiment_label: str,
    source_label: str,
    output_path: Path | None,
    show: bool,
) -> None:
    time_axis = np.arange(series_length) * TIME_STEP_HOURS

    if plt is None:
        raise RuntimeError("matplotlib is required for plotting functionality in pollu_vis.")

    fig, axes = plt.subplots(len(COMPONENTS), 1, figsize=(14, 12), sharex=True)

    for ax, comp in zip(axes, COMPONENTS):
        data = percentile_data.get(comp)
        if not data:
            ax.set_visible(False)
            continue
        for pct in PERCENTILES:
            ax.plot(time_axis, data[pct], label=f"P{pct}")
        ax.axhline(0, color="black", linewidth=0.8, linestyle="--", alpha=0.6)
        ax.set_ylabel(comp)
        ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.5)
        ax.legend(loc="upper right")

    axes[-1].set_xlabel("Time (hours)")
    fig.suptitle(f"Component Difference Percentiles – {source_label.title()} ({experiment_label})")
    plt.tight_layout(rect=[0, 0.03, 1, 0.95])

    if output_path:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        plt.savefig(output_path, dpi=300)
        logging.info("Saved percentile plot to %s", output_path)
        plt.close(fig)
    elif show:
        plt.show()


def main() -> None:
    args = parse_args()
    logging.basicConfig(level=getattr(logging, args.log_level.upper()), format="%(levelname)s: %(message)s")

    experiments = args.experiments or sorted(EXPERIMENTS.keys())

    if args.output_dir:
        args.output_dir.mkdir(parents=True, exist_ok=True)

    nominal_root = args.nominal_dir
    if nominal_root.name != "ASM3_OutputDB":
        nominal_root = nominal_root / "ASM3_OutputDB"

    for exp_key in experiments:
        exp_dir = args.base_dir / EXPERIMENTS[exp_key] / "ASM3_OutputDB"
        if not exp_dir.exists():
            logging.warning("Skipping %s: experiment directory missing (%s)", exp_key, exp_dir)
            continue

        differences = collect_differences(exp_dir, nominal_root, SOURCES[args.source], args.iterations)
        percentile_data, series_length = compute_percentiles(differences)

        output_path = None
        if args.output_dir:
            output_path = args.output_dir / f"pollu_percentiles_{args.source}_{exp_key}.png"

        plot_percentiles(
            percentile_data,
            series_length,
            exp_key,
            args.source,
            output_path,
            show=not args.no_show,
        )


if __name__ == "__main__":
    main()
