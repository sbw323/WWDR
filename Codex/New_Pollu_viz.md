I would like to visualize the timeseries of `S_NH4` and `CODe` in the following ways:
1. Create a difference set between the experimental timeseries and nominal timeseries.
2. Normalize the difference of the experimental and nominal timeseries using the value of the Influent timeseries at the same timestep.
3. Repeat the difference and normalization process on the experiments of different lengths. I.e. Experiment length = 4, 5, 6, and 7
4. Plot the normalization difference timeseries for the two variables on the same graph for each iteration.
5. Plot the timeseries of the 99th, 95th, 67th, 50th, and 33rd percentiles for all the iterations over a 14-day period. 
The nominal influent timeseries can be found at this location: `'/Users/aya/github/WWDR/Databases/8AM_ASM3_DB/Results_Nominal/ASM3_OutputDB'`
The experimental timeseries I would like to start with is at this location: `'/Users/aya/github/WWDR/Databases/3_Day_Spread/Day 0'`
The influent timeseries can be found here: `'/Users/aya/github/WWDR/Databases/Influent'`
The column vector for the influent timeseries is as follows:
```
S_O2_ASin =ASinput(m,1);
S_I_ASin = ASinput(m,2);
S_S_ASin = ASinput(m,3);
S_NH4_ASin = ASinput(m,4);
S_N2_ASin =ASinput(m,5);
S_NOX_ASin = ASinput(m,6);
S_ALK_ASin = ASinput(m,7);
X_I_ASin = ASinput(m,8);
X_S_ASin = ASinput(m,9);
X_H_ASin = ASinput(m,10);
X_STO_ASin = ASinput(m,11);
X_A_ASin =ASinput(m,12);
X_SS_ASin = ASinput(m,13);
Q_ASin = ASinput(m,14);
T_ASin = ASinput(m,15);
S_D1_ASin = ASinput(m,16);
S_D2_ASin = ASinput(m,17);
S_D3_ASin = ASinput(m,18);
X_D4_ASin = ASinput(m,19);
X_D5_ASin = ASinput(m,20)
```
Please utilize the code in `pollu_vis.py` as a starting point for this new script.