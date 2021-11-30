import pandas as pd
import statsmodels.tsa.stattools as ts
import matplotlib.pyplot as plt
import numpy as np
from statsmodels.graphics.tsaplots import plot_acf
from statsmodels.graphics.tsaplots import plot_pacf


raw_csv = pd.read_csv(r'/Users/aya/Documents/NYU/Dissertation/data/BIOWIN_database/1_Datasets/Monthly/normal-28days.csv')

for i in raw_csv.columns:
    print(i)

X = raw_csv["Time (days)"]
y = raw_csv["ML Recycle N - Ammonia"]

fig, ax1 = plt.subplots()

ax1.plot(X, y, marker = 'o', color = 'orange', linestyle = '--')

ax1.set_ylabel('Ammonia')
ax1.set_title('ML Recycle N - Ammonia')

fig_size = plt.rcParams["figure.figsize"]
fig_size[0] = 10
fig_size[1] = 5
plt.rcParams["figure.figsize"] = fig_size

X = raw_csv["Time (days)"]
y = raw_csv["AERZ4 x2 (45) Gas - Dissolved oxygen"]

fig, ax1 = plt.subplots()

ax1.plot(X, y, marker = 'o', color = 'orange', linestyle = '--')


m2=raw_csv["AERZ4 x2 (45) Gas - Dissolved oxygen"].rolling(window=24).mean()
N = len(m2)
x1 = np.linspace(0, 29, N, endpoint=True)

fig, ax1 = plt.subplots()

ax1.plot(x1, m2, marker = 'o', color = 'orange', linestyle = '--')

ax1.set_ylabel('O2')
ax1.set_title('AERZ4 x2 (45) Gas - Dissolved oxygen')
plt.scatter(y=m2, x=x1)


m1=raw_csv["ML Recycle N - Ammonia"].rolling(window=24).mean()
N = len(m1)
x1 = np.linspace(0, 29, N, endpoint=True)

fig, ax1 = plt.subplots()

ax1.plot(x1, m1, marker = 'o', color = 'orange', linestyle = '--')

ax1.set_ylabel('TKN')
ax1.set_title('ML Recycle N - Total Kjeldahl Nitrogen')
plt.scatter(y=m1, x=x1)

raw_csv['first_diff!ML Recycle N - Ammonia']=raw_csv['ML Recycle N - Ammonia'].diff()

m1=raw_csv["first_diff!ML Recycle N - Ammonia"].rolling(window=24).mean()
N = len(m1)
x1 = np.linspace(0, 29, N, endpoint=True)

fig, ax1 = plt.subplots()

ax1.plot(x1, m1, marker = 'o', color = 'orange', linestyle = '--')

ax1.set_ylabel('TKN')
ax1.set_title('ML Recycle N - Total Kjeldahl Nitrogen')
plt.scatter(y=m1, x=x1)

print("No. of nan values:", raw_csv['first_diff!ML Recycle N - Ammonia'].isnull().sum())

df_test=ts.adfuller(raw_csv['first_diff!ML Recycle N - Ammonia'][1:],autolag='AIC')
df_results=pd.Series(df_test[0:4],index=['Test Statistic','p-value','Lags Used','Observations Used'])
for key,value in df_test[4].items():
    df_results['Critical Value (%s)'%key] = value
print(df_results)

plot_acf(raw_csv["ML Recycle N - Ammonia"],lags=100)

plot_pacf(raw_csv["ML Recycle N - Ammonia"],lags=100, use_vlines=True)
pd.plotting.autocorrelation_plot(raw_csv["ML Recycle N - Ammonia"])
pd.plotting.autocorrelation_plot(raw_csv["first_diff!ML Recycle N - Ammonia"][1:])
pd.plotting.lag_plot(raw_csv["ML Recycle N - Ammonia"], lag=1)
pd.plotting.lag_plot(raw_csv["first_diff!ML Recycle N - Ammonia"], lag=1)
