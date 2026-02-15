"""Normalized pollutant difference visualization for ASM3 datasets.

This tool compares experimental outputs against their nominal baselines for
the S_NH4 and CODe state variables. For each experiment length it computes the
normalized differences (relative to the influent signal, lagged by the average HRT),
renders per-iteration time-series plots, and finally aggregates percentiles
(99th, 95th, 67th, 50th, 33rd) across iterations for successive 14-day windows
with experimental periods highlighted.
"""
from __future__ import annotations

import argparse
import logging
import math
from pathlib import Path
from typing import Dict, Iterable, List, Mapping, Sequence
import csv

try:  # pragma: no cover - optional plotting dependencies
    import matplotlib.pyplot as plt
    from matplotlib import ticker
except ModuleNotFoundError:  # pragma: no cover
    plt = None
    ticker = None

import numpy as np
import pandas as pd

from pollu_vis import ASM3_COLUMNS, SOURCES, compute_eqi

# Experiment folders under the base directory
EXPERIMENTS: Mapping[str, str] = {
    "4h": "Results_ExpLength_4h_startday_0",
    # "5h": "Results_ExpLength_5h_startday_0",
    # "6h": "Results_ExpLength_6h_startday_0",
    # "7h": "Results_ExpLength_7h_startday_0",
}

# Influent CSVs include a leading time column followed by the ASM3 state vector.
VARIABLES: Sequence[str] = ("S_NH4", "CODe")
INFLUENT_NORMALIZERS: Mapping[str, str] = {
    "S_NH4": "S_NH4",
    "CODe": "CODe",
}
PERCENTILES: Sequence[int] = (99, 95, 67, 50, 33)
Y_MAXIMUMS: Mapping[str, float] = {
    "S_NH4": 1.0,
    "CODe": 1.0,
}

TIME_STEP_HOURS = 0.25  # data exported at 15-minute intervals
TIME_STEP_DAYS = TIME_STEP_HOURS / 24
HORIZON_DAYS = 14
HORIZON_STEPS = int(HORIZON_DAYS / TIME_STEP_DAYS)
NORMALIZATION_LAG_STEPS = 64  # 16 hours
NUM_PERIODS = 26
KLA_SETPOINTS_DIR_DEFAULT = Path("/Users/aya/github/WWDR/Databases/KLa_Setpoints")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--base-dir",
        type=Path,
        default=Path("/Users/aya/github/WWDR/Databases/3_Day_Spread/Day 0"),
        help="Directory containing Results_ExpLength_*_startday_0 experiment folders.",
    )
    parser.add_argument(
        "--nominal-dir",
        type=Path,
        default=Path("/Users/aya/github/WWDR/Databases/8AM_ASM3_DB/Results_Nominal/ASM3_OutputDB"),
        help="Directory containing nominal ASM3_OutputDB iteration folders.",
    )
    parser.add_argument(
        "--influent-csv",
        type=Path,
        default=Path("/Users/aya/github/WWDR/Databases/Influent/Inlfuent.csv"),
        help="CSV file containing the influent time-series.",
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
    parser.add_argument(
        "--kla-setpoints",
        type=Path,
        help=(
            "Path to a KLa setpoint CSV (applied to every experiment) or a directory containing "
            "KLa_Setpoints_* files. Defaults to the standard KLa_Setpoints directory."
        ),
    )
    return parser.parse_args()


def discover_iterations(root: Path) -> List[str]:
    if not root.exists():
        return []
    return sorted(p.name for p in root.iterdir() if p.is_dir())


def load_numeric_csv(csv_path: Path, columns: int | None = None) -> np.ndarray:
    rows: List[List[float]] = []
    with open(csv_path, "r", newline="", encoding="utf-8-sig") as fh:
        reader = csv.reader(fh)
        for row in reader:
            if not row:
                continue
            if columns is not None and len(row) > columns:
                row = row[:columns]
            rows.append([float(value) for value in row])

    if not rows:
        raise ValueError(f"{csv_path} is empty")

    return np.asarray(rows, dtype=float)


def load_state_vectors(csv_path: Path) -> pd.DataFrame:
    """Return S_NH4 and CODe time-series from an ASM3 state CSV."""
    data = load_numeric_csv(csv_path, len(ASM3_COLUMNS))
    state = pd.DataFrame(data, columns=ASM3_COLUMNS)

    _, components = compute_eqi(state, return_components=True)
    return pd.DataFrame(
        {
            "S_NH4": state["S_NH4"],
            "CODe": components["CODe"],
        }
    )


def load_influent(csv_path: Path) -> pd.DataFrame:
    data = load_numeric_csv(csv_path)
    arr = np.asarray(data)
    if arr.shape[1] < 1 + len(ASM3_COLUMNS):
        raise ValueError(
            f"Influent CSV {csv_path} does not contain enough columns for ASM3 data."
        )

    state = pd.DataFrame(arr[:, 1 : 1 + len(ASM3_COLUMNS)], columns=ASM3_COLUMNS)
    _, components = compute_eqi(state, return_components=True)

    return pd.DataFrame(
        {
            "S_NH4": state["S_NH4"],
            "CODe": components["CODe"],
        }
    )


def load_experiment_periods(csv_path: Path) -> List[tuple[float, float]]:
    if not csv_path.exists():
        logging.warning("KLa setpoint CSV missing: %s", csv_path)
        return []

    df = pd.read_csv(csv_path, header=None, names=["time_days", "setpoint"])
    if df.empty:
        logging.warning("KLa setpoint CSV is empty: %s", csv_path)
        return []

    times = pd.to_numeric(df["time_days"], errors="coerce")
    values = pd.to_numeric(df["setpoint"], errors="coerce")
    mask = times.notna() & values.notna()
    if not mask.any():
        logging.warning("KLa setpoint CSV contains no numeric data: %s", csv_path)
        return []

    times = times[mask].to_numpy()
    values = values[mask].to_numpy()
    hours = times * 24.0

    periods: List[tuple[float, float]] = []
    in_period = False
    start_time = 0.0

    for t_raw, value_raw in zip(hours, values):
        t = float(t_raw)
        value = float(value_raw)
        if not in_period and math.isclose(value, 0.0, abs_tol=1e-6):
            in_period = True
            start_time = t
        elif in_period and math.isclose(value, 240.0, abs_tol=1e-6):
            end_time = t
            if end_time > start_time:
                periods.append((start_time, end_time))
            in_period = False

    if in_period:
        # Extend final period to the last timestamp if no closing 240 value is present.
        periods.append((start_time, float(hours[-1])))

    return periods


def resolve_kla_setpoint_path(
    experiment_key: str,
    override: Path | None,
) -> Path | None:
    if override:
        if override.is_file():
            return override
        if override.is_dir():
            search_dir = override
        else:
            logging.warning("KLa setpoints path is neither file nor directory: %s", override)
            return None
    else:
        search_dir = KLA_SETPOINTS_DIR_DEFAULT

    pattern = f"KLa_Setpoints_{experiment_key}r_Day*.csv"
    matches = sorted(search_dir.glob(pattern))
    if not matches:
        logging.warning("No KLa setpoint files matching %s in %s", pattern, search_dir)
        return None

    for match in matches:
        if "Day0" in match.name:
            return match
    return matches[0]


def lag_array(values: np.ndarray, lag: int) -> np.ndarray:
    if lag <= 0:
        return values
    lagged = np.empty_like(values, dtype=float)
    lagged[:lag] = np.nan
    lagged[lag:] = values[:-lag]
    return lagged


def select_iterations(
    experiment_iterations: List[str], requested: Iterable[str] | None
) -> List[str]:
    if not requested:
        return experiment_iterations

    requested_set = set(requested)
    missing = requested_set - set(experiment_iterations)
    if missing:
        missing_str = ", ".join(sorted(missing))
        raise FileNotFoundError(f"Iterations missing in experiment data: {missing_str}")

    return sorted(requested_set)


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


def plot_iteration(
    time_axis: np.ndarray,
    normalized: Mapping[str, np.ndarray],
    iteration: str,
    experiment_label: str,
    source_label: str,
    highlight_periods: Sequence[tuple[float, float]],
    output_path: Path | None,
    show: bool,
) -> None:
    if plt is None or ticker is None:
        raise RuntimeError("matplotlib is required for plotting in pollu_norm_vis.")
    fig, ax = plt.subplots(figsize=(12, 5))

    for var in VARIABLES:
        ax.plot(time_axis, normalized[var], label=var)

    ax.set_title(f"Normalized differences – {source_label.title()} ({experiment_label}, {iteration})")
    ax.set_xlabel("Time (hours)")
    ax.set_ylabel("Normalized Δ")
    ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.6)
    ax.legend()
    ax.set_ylim(top=max(Y_MAXIMUMS.values()))
    ax.set_xlim(0, HORIZON_DAYS * 24)
    ax.xaxis.set_major_locator(ticker.MultipleLocator(32))
    ax.xaxis.set_minor_locator(ticker.MultipleLocator(8))

    if highlight_periods:
        series_end_hour = time_axis[-1] if len(time_axis) > 0 else 0.0
        for start, end in highlight_periods:
            if end <= 0 or start >= series_end_hour:
                continue
            span_start = max(start, 0.0)
            span_end = min(end, series_end_hour)
            if span_start >= span_end:
                continue
            ax.axvspan(span_start, span_end, color="#ffb347", alpha=0.25)

    fig.tight_layout()

    if output_path:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        fig.savefig(output_path, dpi=300)
        logging.info("Saved iteration plot to %s", output_path)
        plt.close(fig)
    elif show:
        plt.show()
        plt.close(fig)
    else:
        plt.close(fig)


def compute_percentiles(data: List[np.ndarray]) -> Dict[int, np.ndarray]:
    if not data:
        return {}

    min_len = min(len(arr) for arr in data)
    stack = np.vstack([arr[:min_len] for arr in data])
    return {pct: np.nanpercentile(stack, pct, axis=0) for pct in PERCENTILES}


def plot_percentiles(
    time_axis: np.ndarray,
    percentiles: Mapping[str, Dict[int, np.ndarray]],
    experiment_label: str,
    source_label: str,
    highlight_periods: Sequence[tuple[float, float]],
    output_dir: Path | None,
    show: bool,
) -> None:
    if plt is None or ticker is None:
        raise RuntimeError("matplotlib is required for plotting in pollu_norm_vis.")
    if time_axis.size == 0:
        logging.warning("Percentile plot: empty time axis for experiment %s", experiment_label)
        return

    period_steps = HORIZON_STEPS
    total_steps = time_axis.size
    period_hours = HORIZON_DAYS * 24
    max_periods = math.ceil(total_steps / period_steps)
    target_periods = min(NUM_PERIODS, max_periods)

    for period_idx in range(target_periods):
        start_idx = period_idx * period_steps
        if start_idx >= total_steps:
            break
        end_idx = min(start_idx + period_steps, total_steps)
        period_length = end_idx - start_idx
        if period_length <= 0:
            continue

        period_axis = np.arange(period_length) * TIME_STEP_HOURS
        window_start_hour = start_idx * TIME_STEP_HOURS
        window_end_hour = window_start_hour + period_length * TIME_STEP_HOURS

        fig, axes = plt.subplots(len(VARIABLES), 1, figsize=(12, 8), sharex=True)

        for ax, var in zip(axes, VARIABLES):
            data = percentiles.get(var, {})
            if not data:
                ax.set_visible(False)
                continue
            for pct in PERCENTILES:
                ax.plot(period_axis, data[pct][start_idx:end_idx], label=f"P{pct}")
            ax.axhline(0, color="black", linewidth=0.8, linestyle="--", alpha=0.6)
            ax.set_ylabel(f"{var} normalized Δ")
            ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.6)
            ax.legend(loc="upper right")
            ax.set_ylim(top=Y_MAXIMUMS[var])

            for start, end in highlight_periods:
                overlap_start = max(start, window_start_hour)
                overlap_end = min(end, window_end_hour)
                if overlap_start >= overlap_end:
                    continue
                ax.axvspan(
                    overlap_start - window_start_hour,
                    overlap_end - window_start_hour,
                    color="#ffb347",
                    alpha=0.25,
                )

        axes[-1].set_xlabel("Time (hours)")
        for ax in axes:
            ax.set_xlim(0, period_hours)
            ax.xaxis.set_major_locator(ticker.MultipleLocator(32))
            ax.xaxis.set_minor_locator(ticker.MultipleLocator(8))

        fig.suptitle(
            f"Normalized Δ percentiles – {source_label.title()} ({experiment_label}) – Period {period_idx + 1}"
        )
        fig.tight_layout(rect=[0, 0.03, 1, 0.96])

        if output_dir:
            output_path = (
                output_dir
                / "percentiles"
                / experiment_label
                / f"percentiles_{source_label}_{experiment_label}_period_{period_idx + 1:02d}.png"
            )
            output_path.parent.mkdir(parents=True, exist_ok=True)
            fig.savefig(output_path, dpi=300)
            logging.info("Saved percentile plot to %s", output_path)
            plt.close(fig)
        elif show:
            plt.show()
            plt.close(fig)
        else:
            plt.close(fig)


def plot_combined_95th(
    percentiles_95: Mapping[str, Dict[str, np.ndarray]],
    experiments: Sequence[str],
    source_label: str,
    output_dir: Path | None,
    show: bool,
) -> None:
    if plt is None or ticker is None:
        raise RuntimeError("matplotlib is required for plotting in pollu_norm_vis.")
    if not experiments:
        return

    fig, axes = plt.subplots(len(VARIABLES), 1, figsize=(12, 8), sharex=True)

    time_axis_full = np.arange(HORIZON_STEPS) * TIME_STEP_HOURS

    for ax, var in zip(axes, VARIABLES):
        var_data = percentiles_95.get(var, {})
        if not var_data:
            ax.set_visible(False)
            continue

        for exp_label in experiments:
            series = var_data.get(exp_label)
            if series is None:
                continue
            plot_series = np.full(HORIZON_STEPS, np.nan)
            length = min(len(series), HORIZON_STEPS)
            plot_series[:length] = series[:length]
            ax.plot(time_axis_full, plot_series, label=exp_label)

        ax.axhline(0, color="black", linewidth=0.8, linestyle="--", alpha=0.6)
        ax.set_ylabel(f"{var} normalized Δ (P95)")
        ax.grid(True, linestyle="--", linewidth=0.5, alpha=0.6)
        ax.legend(loc="upper right")
        if var == "S_NH4":
            ax.set_ylim(top=3.0)
        else:
            ax.set_ylim(top=12.0)
        ax.set_xlim(0, HORIZON_DAYS * 24)
        ax.xaxis.set_major_locator(ticker.MultipleLocator(32))
        ax.xaxis.set_minor_locator(ticker.MultipleLocator(8))

    axes[-1].set_xlabel("Time (hours)")
    fig.suptitle(f"P95 normalized Δ – {source_label.title()} (All Experiments)")
    fig.tight_layout(rect=[0, 0.03, 1, 0.96])

    if output_dir:
        output_path = output_dir / "percentiles" / "combined_p95.png"
        output_path.parent.mkdir(parents=True, exist_ok=True)
        fig.savefig(output_path, dpi=300)
        logging.info("Saved combined P95 plot to %s", output_path)
        plt.close(fig)
    elif show:
        plt.show()


def main() -> None:
    args = parse_args()
    logging.basicConfig(level=getattr(logging, args.log_level.upper()), format="%(levelname)s: %(message)s")

    if args.output_dir:
        args.output_dir.mkdir(parents=True, exist_ok=True)

    experiments = args.experiments or sorted(EXPERIMENTS.keys())
    influent_df = load_influent(args.influent_csv)
    highlight_cache: Dict[Path, List[tuple[float, float]]] = {}
    combined_percentiles: Dict[str, Dict[str, np.ndarray]] = {var: {} for var in VARIABLES}

    for exp_key in experiments:
        exp_dir = args.base_dir / EXPERIMENTS[exp_key] / "ASM3_OutputDB"
        experiment_iterations = discover_iterations(exp_dir)
        if not experiment_iterations:
            logging.warning("Skipping %s: no iterations found under %s", exp_key, exp_dir)
            continue

        nominal_dir = args.nominal_dir
        if nominal_dir.name != "ASM3_OutputDB":
            nominal_dir = nominal_dir / "ASM3_OutputDB"

        selected_iterations = select_iterations(experiment_iterations, args.iterations)
        iteration_series: Dict[str, Dict[str, np.ndarray]] = {}
        kla_path = resolve_kla_setpoint_path(exp_key, args.kla_setpoints)
        highlight_periods: List[tuple[float, float]] = []
        if kla_path:
            highlight_periods = highlight_cache.setdefault(kla_path, load_experiment_periods(kla_path))

        for iter_name in selected_iterations:
            iter_id = iter_name.replace("iter", "")
            pattern = SOURCES[args.source]
            exp_csv = exp_dir / iter_name / pattern.format(iter_id=iter_id)
            nom_csv = nominal_dir / iter_name / pattern.format(iter_id=iter_id)

            if not exp_csv.exists():
                logging.warning("Experimental CSV missing: %s", exp_csv)
                continue
            if not nom_csv.exists():
                logging.warning("Nominal CSV missing: %s", nom_csv)
                continue

            exp_df = load_state_vectors(exp_csv)
            nom_df = load_state_vectors(nom_csv)

            time_axis, normalized = compute_normalized_differences(exp_df, nom_df, influent_df)
            iteration_series[iter_name] = {var: normalized[var] for var in VARIABLES}

            iteration_output = None
            if args.output_dir:
                iteration_output = (
                    args.output_dir
                    / "iterations"
                    / exp_key
                    / f"normalized_diff_{args.source}_{iter_name}.png"
                )

            plot_iteration(
                time_axis,
                normalized,
                iter_name,
                exp_key,
                args.source,
                highlight_periods,
                iteration_output,
                show=not args.no_show and not args.output_dir,
            )

        if not iteration_series:
            logging.warning("No iteration data collected for experiment %s", exp_key)
            continue

        # Collect percentile inputs for this experiment length
        percentiles_by_var: Dict[str, Dict[int, np.ndarray]] = {}
        min_len = min(len(data["S_NH4"]) for data in iteration_series.values())
        time_axis = np.arange(min_len) * TIME_STEP_HOURS

        for var in VARIABLES:
            data = [series[var][:min_len] for series in iteration_series.values()]
            percentiles_by_var[var] = compute_percentiles(data)

        plot_percentiles(
            time_axis,
            percentiles_by_var,
            exp_key,
            args.source,
            highlight_periods,
            args.output_dir,
            show=not args.no_show and not args.output_dir,
        )

        for var in VARIABLES:
            series_95 = percentiles_by_var[var].get(95)
            if series_95 is not None:
                combined_percentiles[var][exp_key] = series_95

    available_experiments = sorted(
        {exp for var_dict in combined_percentiles.values() for exp in var_dict.keys()}
    )
    plot_combined_95th(
        combined_percentiles,
        available_experiments,
        args.source,
        args.output_dir,
        show=not args.no_show and not args.output_dir,
    )


if __name__ == "__main__":
    main()
