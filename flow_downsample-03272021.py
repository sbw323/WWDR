import sys
import pandas as pd
import numpy as np
import pylab
import matplotlib.pyplot as plt
from pandas import DataFrame as df
from datetime import datetime
pd.options.mode.chained_assignment = None

raw_excel = pd.read_excel(r'/Users/aya/Documents/NYU/Dissertation/data/BeerSheva-Online-Data/EQ tanks/21-24 1 2020 main FT.xlsx', index_col=None)
raw_excel
print(raw_excel.shape)

DFraw_flow = raw_excel[3:]
col_list = list(DFraw_flow.columns)
periods = (len(DFraw_flow[col_list[2]]))
DFraw_flow.reset_index(drop = True, inplace = True)
DFraw_flow.drop(columns = col_list[0], inplace = True) #original timestamp is not useful#
DFraw_flow.drop(columns = col_list[1], inplace = True) #original timestamp is not useful#
DFraw_flow.reset_index(drop = True, inplace = True)
DFraw_flow.fillna(method="ffill", inplace = True)

DFraw_flow
times_all = list(raw_excel[col_list[1]][3:])
dates_all = list(raw_excel[col_list[0]][3:])

date_string = datetime.combine(dates_all[0], times_all[0])

datetime_int_list = list()
val_len = len(times_all)
var_linspace = np.linspace(0, val_len, val_len, endpoint=False)
var_linspace = var_linspace.astype(int)

datetime_int_list = list()
for i in var_linspace:
      dt_obj = datetime.combine(dates_all[i],times_all[i])
      dt_val = int(round(dt_obj.timestamp()))
      datetime_int_list.append(dt_val)
if len(var_linspace) == len(datetime_int_list):
      print("true")

DFraw_flow['timestamp'] = datetime_int_list
timestamp_1stDiff = np.diff(DFraw_flow['timestamp'], n = 1)
timestamp_1stDiff = np.hstack((0,timestamp_1stDiff)) #turn the list into a horizontal vector#
DFraw_flow['timestamp_1stDiff'] = timestamp_1stDiff #attach h vector to the df as a new col#

DFraw_flow['index1'] = DFraw_flow.index #Create a new column w/ just index values
DFraw_flow["V__tsDiff11_index"] = list(zip(DFraw_flow.timestamp_1stDiff,DFraw_flow.index1)) #zip together the timestamp diff and index col into a tuple list

V__tsDiff1_index__list = list(DFraw_flow['V__tsDiff11_index'])
V__tsDiff1_index__list.sort(reverse = True, key = lambda y: y[0])
for i in V__tsDiff1_index__list[:5]:
      print(i)

def fill_missing_range(df, field, range_from, range_to, range_step=1, fill_with=0):
    return df.merge(how='right', on=field,right = pd.DataFrame({field:np.arange(range_from, range_to, range_step)})).sort_values(by=field).reset_index().fillna(fill_with).drop(['index'], axis=1)

gap_begin_index = V__tsDiff1_index__list[0][1]-1
gap_end_index = V__tsDiff1_index__list[0][1]

ts_gap_begin = DFraw_flow['timestamp'][gap_begin_index]
ts_gap_end = DFraw_flow['timestamp'][gap_end_index]

#DFraw_flow__copy = DFraw_flow

DFraw_flow__ts_fill = fill_missing_range(DFraw_flow, "timestamp", ts_gap_begin, ts_gap_end, 2, np.nan)

DFraw_flow0 = DFraw_flow[:gap_begin_index]
DFraw_flow1 = DFraw_flow[gap_end_index:]

frames = [DFraw_flow0, DFraw_flow__ts_fill, DFraw_flow1]
DFraw_flow_concat = pd.concat(frames, sort = False)
DFraw_flow_concat['Unnamed: 2'].fillna(method="ffill", inplace = True)
DFraw_flow_concat['timestamp'] = pd.to_datetime(DFraw_flow_concat['timestamp'], unit = 's')
DFraw_flow_concat.reset_index(drop = True, inplace = True)

resampled_flow_df = DFraw_flow_concat.resample('1H', on = 'timestamp').mean()
resampled_flow_df.reset_index(drop = True, inplace = True)
periods = len(resampled_flow_df['Unnamed: 2'])
resampled_flow_df['timestamp'] = pd.date_range(date_string, periods=periods, freq='1H')
resampled_flow_df['flowrate'] = resampled_flow_df['Unnamed: 2']
resampled_flow_df.drop(columns = 'timestamp_1stDiff', inplace = True)
resampled_flow_df.drop(columns = 'Unnamed: 2', inplace = True)
resampled_flow_df.drop(columns = 'index1', inplace = True)
resampled_flow_df[0:]

#resampled_flow_df.to_csv(r'/Users/aya/Documents/NYU/Dissertation/data/BeerSheva-Online-Data/EQ tanks/resampled/1hr__21-24 1 2020 main FT.csv')
