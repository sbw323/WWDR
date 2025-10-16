import pandas as pd
import statsmodels.tsa.stattools as ts
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np

raw_csv = pd.read_csv(r'/Users/aya/Documents/NYU/Dissertation/data/BIOWIN_database/1_Datasets/Monthly/normal-op_28days-1hr_alldata.csv')

plt.scatter(raw_csv["Time (days)"], raw_csv["AERZ1 x2 (75) Gas - Dissolved oxygen"])

plt.scatter(raw_csv["Time (days)"], raw_csv["ML Recycle N - Ammonia"])

m2=raw_csv["ML Recycle N - Ammonia"].rolling(window=24).mean()
N = len(m2)
x1 = np.linspace(0, 29, N, endpoint=True)
plt.scatter(y=m2, x=x1)


m1=raw_csv["AERZ1 x2 (75) COD - Total"].rolling(window=24).mean()
N = len(m1)
x1 = np.linspace(0, 29, N, endpoint=True)
plt.scatter(y=m1, x=x1)
