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
        # + i_nsi * df["S_I"]
        # + i_nss * df["S_S"]
        # + i_nxi * df["X_I"]
        # + i_nxs * df["X_S"]
        # + i_nbm * (df["X_H"] + df["X_A"])
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