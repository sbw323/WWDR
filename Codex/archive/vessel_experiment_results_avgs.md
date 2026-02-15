- stable variables:
number: timestep_leng = 4
number: timestep_day_leng = 24 * 4
- user variables:
number: exp_spread_days = 3
string: subdirectory location of naive_stacked_data\with_snh4_norm
number list: target_vessels = [3, 4, 5]
string list: average_column_targets = ["SNH4_inf_nom", "SNH4_nom_norm", "SNH4_nomdiff_norm"]
string: output_location = naive_stacked_data\with_snh4_norm\vessel_experiment_results
- parse filenames of naive_stacked_data\with_snh4_norm. example: 
string: reactor3_13hr_day0_red0.75pct_with_snh4_norm.csv
parsed output: 
number: reactor_no = 3
number: duration = 13
number: day_start = 0
number: energy_reduc = 0.75
- construct target list of filenames where variable reactor_no is in target_vessels list
string list: target_datasets = where reactor_no is in target_vessels
- load first filename in target list
- formulate energy_use_reacno_norm column name: energy_use_reacno_norm = "energy_use_R" + reac_no.as_text() + "_normalized" 
- locate  df row of first experiment start index where: rounddown(df[energy_use_reacno_norm, 2) = energy_reduc, store as: first_exp_start_index
- compute first_exp_end_index = first_exp_start_index + (4 * duration - 1)
- create tuple list of experiment start-end pairs
- construct experiment start window indices list:
exp_spread_days * timestep_day_leng = index_stagger
construct list of exp_start_index for all experiments recursively:
exp_start_index_2 = first_exp_start_index + index_stagger
exp_start_index_3 = exp_start_index_2 + index_stagger
stop when exp_start_index >= len(df)
- construct experiment end window index arrays:
exp_spread_days * timestep_day_leng = index_stagger
construct list of exp_end_index for all experiments recursively:
exp_start_index_2 = first_exp_end_index + index_stagger
exp_start_index_3 = exp_end_index_2 + index_stagger
stop when exp_end_index >= len(df)
tuple pair list: start_end_indices = [(exp_start, exp_end)]
- compute averages columns of column names in average_column_targets within bounds of row indicies stored in start_end_indices
- create dictionary of experiment results by repeating this process for all datasets in target list
dict: target_vessel_dataset_averages_dict: keys = vessel_no, duration, energy_reduc; values = [vesselno_duration_SNH4_inf_nom, vesselno_duration_SNH4_nom_norm, vesselno_duration_SNH4_nomdiff_norm] 
- construct reactor vessel energy-duration-reduction dataframe for all experiments and specified reactor vessels using target_vessel_dataset_averages_dict
example: 
energy-duration-reduction df = reactor3
df ROW 0 = ["duration", "energy_reduc", "avg_SNH4_inf_nom", "avg_SNH4_nom_norm", "avg_SNH4_nomdiff_norm"]
df ROW 1 = [1, 0.95, {Duration = 1, energy_reduc = 0.95}:[avg_SNH4_inf_nom, avg_SNH4_nom_norm, avg_SNH4_nomdiff_norm]]
...
df ROW n = [13, 0.25, {Duration = 13, energy_reduc = 0.25}:[avg_SNH4_inf_nom, avg_SNH4_nom_norm, avg_SNH4_nomdiff_norm]]
energy-duration-reduction df = reactor4
energy-duration-reduction df = reactor5
- save dataframes as outputs in output_location string. Create folder at parent directory if target output_location does not exist in filestrucutre.