import pandas as pd
import statsmodels.tsa.stattools as ts
import matplotlib.pyplot as plt
import numpy as np
from statsmodels.graphics.tsaplots import plot_acf
from statsmodels.graphics.tsaplots import plot_pacf

plot_filepath = r'/Users/aya/Documents/NYU/Dissertation/data/BIOWIN_database/Plots'

in_csv = pd.read_csv(r'/Users/aya/Documents/NYU/Dissertation/data/BIOWIN_database/1_Datasets/Monthly/normal-28days.csv')
len(in_csv.columns)

for i in in_csv.columns:
    print(i)

in_csv['rllmean5!Final Effluent COD - Total']=in_csv["Final Effluent COD - Total"].rolling(window=5).mean()

in_csv['rllmean5!Final Effluent COD - Total'].fillna(0, inplace = True)

def acf_batch_plotter(input_df, save):

    for i in input_df:
        cn = i
        Y = input_df[cn]

        plot_acf(Y, lags = 23)
        plt.suptitle(cn)

        if save is not False:
            plt.savefig(plot_filepath)
            plt.show()
        else:
            plt.show()

    return

acf_batch_plotter(in_csv, save = False)

def pacf_batch_plotter(input_df, save):

    for i in input_df.columns:
        cn = i
        Y = input_df[cn]

        plot_pacf(Y, lags = 300)
        plt.suptitle(cn)

        if save is not False:
            plt.savefig(plot_filepath)
            plt.show()
        else:
            plt.show()

    return

pacf_batch_plotter(in_csv, save = False)
pacf_batch_plotter(in_csv, save = False)
