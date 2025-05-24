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

Xlist = list(in_csv.columns[15:])
Xlist.append('Final Effluent Total suspended solids')
Xlist

df_X = pd.DataFrame()
for i in Xlist:
    df_X = df_X.append(in_csv[i])

df_X = df_X.T
DF_X = pd.DataFrame()

df_X.head()

for i in df_X.columns:
    temparr = np.asarray(df_X[i])
    temparr = temparr.reshape(-1, 1)
    scaler = MinMaxScaler()
    MMtemparr = scaler.fit_transform(temparr)
    DF_X["MM!__" + i] = MMtemparr.flatten().tolist()

dataset = DF_X.to_numpy()

DF_X

def split_sequences(sequences, n_steps_in, n_steps_out):
  X, y = list(), list()
  for i in range(len(sequences)):
    # find the end of this pattern
    end_ix = i + n_steps_in
    out_end_ix = end_ix + n_steps_out-1
    # check if we are beyond the dataset
    if out_end_ix > len(sequences):
        break
    # gather input and output parts of the pattern
    seq_x, seq_y = sequences[i:end_ix, :-1], sequences[end_ix-1:out_end_ix, -1]
    X.append(seq_x)
    y.append(seq_y)
  return np.array(X), np.array(y)

type(dataset)

# choose a number of time steps
n_steps_in, n_steps_out = 3, 2
X, y = split_sequences(dataset,n_steps_in, n_steps_out)
print(X.shape, y.shape)
for i in range(len(X)):
    print(X[i], y[i])

# flatten input: calculate the length of the input vector as the number of time steps mutilplied by the number of features or time series.
n_input = X.shape[1] * X.shape[2]
# use this vector size to reshape the input.
X = X.reshape((X.shape[0], n_input))
X.shape
# define model with a multivariate input where the vector length is the used for the input dimension arguement of the model
model = keras.Sequential()
model.add(Dense(100, activation='relu', input_dim=n_input))
model.add(Dense(n_steps_out))
model.compile(optimizer='adam', loss='mse')
# fit model
model.fit(X, y, epochs=2000, verbose=0)

# demonstrate prediction
print(len(X))
#x_input = X[51:150]
x_input = X[0:1]
x_input.shape
yhat = model.predict(x_input, verbose=0)

Y_hat = list()
for i in range(0,len(yhat)):
    Y_hat.append(yhat[i][0])
np.array(Y_hat)

m1 = yhat.flatten()
m1 = np.interp(np.arange(0, len(m1), 2), np.arange(0, len(m1)), m1)
len(m1)
m1
m1.shape[0]
m1
m2 = DF_X['MM!__Final Effluent Total suspended solids'][0:3]
m2
N = len(m1)
N2 = len(m2)
N2
len(Y_hat)
xYhat = np.linspace(0, len(Y_hat[2:101]), N, endpoint=True)
x1 = np.linspace(0, len(m1), N, endpoint=True)
x2 = np.linspace(0, len(m2), N2, endpoint=True)

fig, ax1 = plt.subplots()

ax1.plot(xYhat, Y_hat[2:101], marker = 'o', color = 'orange', linestyle = '--')
ax1.plot(x2, m2, marker = 'o', color = 'blue', linestyle = '--')

ax1.set_ylabel('yhat')
ax1.set_title('yhat (orange) vs y (blue)')
