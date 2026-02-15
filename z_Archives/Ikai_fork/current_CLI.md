python naive_vstacker.py \
  --input-dir /Users/ikai/github/WWDR-Databases/Databases/3dayspread_ASM3-KLa5-84 \
  --start-timestamp 2023-01-01T00:00:00 \
  --loglevel INFO

python3 longterm_batch_helper.py \
  --root-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm \
  --baseline-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/ExpLength_0h_startday_0_reductionfactor_1.0pct \
  --influent-csv /Users/ikai/github/WWDR-Databases/Databases/Influent/influent.csv \
  --start-timestamp 2023-01-01T00:00:00 \
  --loglevel INFO

python3 settler_aggregator.py \
  --root-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm \
  --output-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/aggregated_settler_snh4 \
  --loglevel INFO

python3 plot_normalized_nh4.py \
  --input-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/aggregated_settler_snh4 \
  --output-dir /Users/ikai/github/WWDR-Databases/Databases/Longterm/plots_normalized_snh4 \
  --day day0 \
  --value-col SNH4_inf_norm \
  --loglevel INFO