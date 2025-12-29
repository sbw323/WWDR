python naive_vstacker.py \
  --input-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm \
  --start-timestamp 2023-01-01T00:00:00 \
  --loglevel INFO

python3 stacked_exp_influent_combiner.py \
  --input-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/naive_stacked_data \
  --output-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/naive_stacked_data/with_influent \
  --influent-csv /Users/ikai/github/WWDR-Databases/Databases/Influent/influent.csv \
  --suffix _influent

python3 SNH4_normalizer.py \
  --input-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/naive_stacked_data/with_influent \
  --nominal-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/ExpLength_0h_startday_0_reductionfactor_1.0pct/Nominal_Stacked/REACTOR5_240\
  --output-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/naive_stacked_data/with_snh4_norm

python3 experiment_extractor.py \
  --input-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/naive_stacked_data/with_snh4_norm \
  --output-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/naive_stacked_data/extracted_experiments_snh4 \
  --suffix _snh4_window

python3 plot_normalized_nh4.py \
  --input-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/naive_stacked_data/extracted_experiments_snh4 \
  --output-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/naive_stacked_data/plots_normalized_snh4 \
  --source settler \
  --day day0 \
  --value-col SNH4_inf_norm