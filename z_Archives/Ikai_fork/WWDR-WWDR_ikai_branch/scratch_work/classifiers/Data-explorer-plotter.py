import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from numpy import hstack
from sklearn.preprocessing import MinMaxScaler
import keras
from keras.models import Sequential
from keras.layers import Dense

in_csv = pd.read_csv(r'/Users/aya/Documents/NYU/Dissertation/data/BIOWIN_database/1_Datasets/Monthly/normal-28days.csv')
len(in_csv.columns)

for i in in_csv.columns[15:]:
    print(i)
for i in in_csv.columns[0:14]:
    print(i)

def moving_average(x, w):
    return np.convolve(x, np.ones(w), 'valid') / w

def data_plotter(x, y, c, ylabel, title):
    fig_size = plt.rcParams["figure.figsize"]
    fig_size[0] = 15
    fig_size[1] = 10
    plt.rcParams["figure.figsize"] = fig_size

    fig, ax1 = plt.subplots()

    ax1.plot(x1, m1, marker = 'o', color = c, linestyle = '--')

    ax1.set_ylabel(ylabel)
    ax1.set_title(title)
    plt.scatter(y=y, x=x)

Xlist = list(in_csv.columns[15:])
Xlist.append('Final Effluent Total suspended solids')

m1 = in_csv['Final Effluent Total suspended solids']
N = len(m1)
x1 = np.linspace(0, 29, N, endpoint=True)

data_plotter(x1, m1, c = 'blue', ylabel = 'TSS Effluent', title = 'Final Effluent Total suspended solids')
print(len(efTSSarr))

efTSSarr = np.asarray(in_csv['Final Effluent Total suspended solids'])
efTSSarr.shape
efTSSarr = efTSSarr.reshape(-1, 1)

scaler = MinMaxScaler()
TSSMMscaled = scaler.fit_transform(efTSSarr)

print(scaler.data_max_)
print(scaler.data_min_)

max(efTSSarr)
min(efTSSarr)

m1 = TSSMMscaled

N = len(m1)
x1 = np.linspace(0, 29, N, endpoint=True)

data_plotter(x1, m1, c = 'blue', ylabel = 'TSS Effluent', title = 'Final Effluent Total suspended solids')

PSTBODarr = np.asarray(in_csv['PST x3 BOD - Total Carbonaceous'])
PSTBODarr = PSTBODarr.reshape(-1, 1)
scaler = MinMaxScaler()
MMscalled = scaler.fit_transform(PSTBODarr)

m1 = MMscalled
N = len(m1)
x1 = np.linspace(0, 29, N, endpoint=True)

data_plotter(x1, m1, c = 'orange', ylabel = 'PST x3 BOD - Total Carbonaceous', title = 'Primary Settler BOD - Total C')


m1 = in_csv['PST x3 BOD - Total Carbonaceous']
N = len(m1)
x1 = np.linspace(0, 29, N, endpoint=True)

fig, ax1 = plt.subplots()

ax1.plot(x1, m1, marker = 'o', color = 'orange', linestyle = '--')

ax1.set_ylabel('PST-BODtC')
ax1.set_title('PST x3 BOD - Total Carbonaceous')
plt.scatter(y=m1, x=x1)
