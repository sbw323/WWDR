column_names = [
"S_I", "S_S", "X_I", "X_S", "X_H", "X_A", "X_STO",
"S_O2", "S_NOX", "S_NH4", "S_N2", "S_ALK", "X_SS", "Q"
]
nominal.columns = column_names
iteration.columns = column_names

# Step 3: Define EQI constants

stoichi_ratio_dict = {
"i_SSXS":0.07, 
"i_NBM":0.01, 
"i_NSI":0.03, 
"i_NSS":0.02, 
"i_NXI":0.04, 
"i_NXS":0.90, 
"i_SSBM":0.60, 
"i_SSSTO":0.75, 
"i_SSXI":0.75,
"f_ns":0.0023,
"f_P":0.08,
"f_SI":0.0,
"f_XI":0.20
}

BSS = 2
BCOD = 1
BNKj = 30
BNO = 10
BBOD5 = 2
i_XB = 0.08
i_XP = 0.06

def compute_eqi(df, stoich=stoichi_ratio_dict):
    # Pull stoichiometric parameters
    i_NBM = stoich["i_NBM"]
    i_NSI = stoich["i_NSI"]
    i_NSS = stoich["i_NSS"]
    i_NXI = stoich["i_NXI"]
    i_NXS = stoich["i_NXS"]
    f_P   = stoich["f_P"]

    # Effluent terms aligned with UPDATED FUNCTIONS
    SSe   = df["X_SS"]
    CODe  = df["S_I"] + df["S_S"] + df["X_I"] + df["X_S"] + df["X_H"] + df["X_A"] + df["X_STO"]
    SNKje = (
        df["S_NH4"]
        + i_NSI * df["S_I"]
        + i_NSS * df["S_S"]
        + i_NXI * df["X_I"]
        + i_NXS * df["X_S"]
        + i_NBM * (df["X_H"] + df["X_A"])
    )
    SNOe  = df["S_NOX"]
    BOD5e = 0.25 * (df["S_S"] + df["X_S"] + (1 - f_P) * (df["X_H"] + df["X_A"] + df["X_STO"]))
    Qevec = df["Q"]

    # EQI (vectorized)
    EQIvecinst = (BSS * SSe + BCOD * CODe + BNKj * SNKje + BNO * SNOe + BBOD5 * BOD5e) * Qevec
    return EQIvecinst