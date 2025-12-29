Create a new Python 3.10+ script named experiment_extractor.py that extracts day-based experimental time windows from a stacked time-series CSV and writes separate outputs per checkpoint day and iteration.

Inputs & Assumptions
	•	Stacked dataset (CSV) where:
	•	There is a timestamp column (default name: timestamp) parsable to datetime64[ns].
	•	The final column encodes the iteration ID (e.g., iter, iteration, or numeric). Treat “final column” as authoritative if the column name is unknown.
	•	Other columns are numeric or string; the user chooses a target column to extract (by name or by 0/1-based index).
	•	Time stamps are at 15-minute cadence (but script must not assume perfect regularity; it should filter to the requested windows robustly).

Required CLI (use argparse)
	•	--input (path): path to stacked CSV (e.g., stack_S_Exp1d_day000.csv).
	•	--startday (int): experimental start day (e.g., 0).
	•	--offset (int): step between day checkpoints in days (e.g., 3).
	•	--target-col (str or int): column to extract; accept either the column name or a 0- or 1-based index (detect automatically).
	•	--exp-length (int, optional): total experiment length in days. If provided, generate checkpoints from startday to exp-length inclusive using offset.
	•	--extra-days (int…, optional): explicit extra checkpoint day(s) to include (e.g., --extra-days 11 14) to support non-uniform schedules.
	•	--timestamp-col (str, default=timestamp)
	•	--window-days (float, default=1.0): length of each extraction window in days (default 24h).
	•	--outdir (path, default=./extracted)
	•	--tz (str, optional): timezone name (e.g., America/New_York). If given, localize timestamps; otherwise treat as naive UTC.
	•	--verbose (flag)

Behavior
	1.	Load the CSV with pandas; coerce timestamp-col to datetime. If --tz is given and the timestamps are naive, localize to that timezone; if timestamps are already tz-aware, convert to --tz.
	2.	Identify the iteration column: use the final column in the DataFrame (after loading), call it iteration_id. If the final column is named, keep its name; else, rename internally to iteration_id for processing.
	3.	Resolve the target column:
	•	If --target-col is an int, allow both 0-based and 1-based indices (auto-detect; if both valid, prefer name match).
	•	If a string, match by exact column name.
	•	Validate and error clearly if not found.
	4.	Build checkpoint days:
	•	Initialize with [startday].
	•	If --exp-length is provided, extend by adding startday + n*offset while <= exp-length.
	•	If --extra-days provided, union them into the set.
	•	Sort and deduplicate.
	•	Example: startday=0, offset=3, exp-length=14, extra-days=[11,14] → checkpoints: 0,3,6,9,11,14.
	5.	Window extraction per checkpoint day:
	•	For each day_k in checkpoints, define window
t_start = experiment_t0 + day_k days
t_end   = t_start + window-days
where experiment_t0 is the minimum timestamp date normalized to midnight (or, if you prefer, the earliest timestamp floored to midnight). Provide a CLI flag in code to switch anchoring to the minimum timestamp vs. a user-provided absolute start timestamp (future-proof; default to min date at 00:00).
	•	Filter the DataFrame to [t_start, t_end).
	•	(Optional but helpful) If the cadence is finer than 15 minutes, allow it; do not resample. If user needs 15-min enforcement, add a commented snippet showing how to filter to minutes ∈ {00,15,30,45}.
	6.	Group by iteration:
	•	Within the filtered window for a given day_k, group by iteration_id.
	•	For each iteration, emit a dataset with:
	•	timestamp
	•	iteration_id
	•	the target column (renamed to a clean snake_case if needed)
	•	(Optional) keep a small set of metadata columns if present (e.g., source_id).
	•	Allow --keep-all-cols (flag) to keep all columns instead of just the target + iteration + timestamp.
	7.	Output structure & naming:
	•	Directory: OUTDIR/day{day_k:03d}/
	•	File per iteration:
extract_day{day_k:03d}_iter{ITER}.csv
(If combining all iterations into one file per day is preferred, also provide --per-day-single-file which writes extract_day{day_k:03d}.csv sorted by iteration_id, timestamp.)
	•	Provide a manifest per day: manifest_day{day_k:03d}.json listing iterations found, row counts, time span.
	8.	Validation & Logging:
	•	Log: checkpoint day, window bounds (ISO), number of iterations found, and rows per iteration.
	•	If no rows found for a checkpoint, write an empty CSV with headers and log a warning.
	•	If timestamps are outside expected range or target-col missing values, log counts of NaNs.
	•	Always sort outputs by timestamp ascending.

Example CLI

# Example that matches the narrative:
python experiment_extractor.py \
  --input ./combined/stack_S_Exp1d_day000.csv \
  --startday 0 \
  --offset 3 \
  --exp-length 14 \
  --extra-days 11 14 \
  --target-col 15 \
  --outdir ./extracted_S_Exp1d_day000 \
  --verbose

This should produce separate datasets for day 000, 003, 006, 009, 011, 014, each grouped by iteration (i.e., one CSV per iteration per day, or a single per-day file if --per-day-single-file is set).

Implementation Notes
	•	Use only stdlib + pandas (and numpy if needed).
	•	Provide a main() with argparse.
	•	Provide small unit-style smoke tests in a if __name__ == "__main__": guard or a separate tests block that:
	1.	synthesize a tiny stacked DataFrame with two iterations and 15-min cadence over 2 days;
	2.	write to a temp CSV;
	3.	run extraction for startday=0, offset=1, exp-length=1;
	4.	assert expected output files and row counts.
	•	Add clear docstrings and type hints.
	•	Be strict but friendly in error messages (missing columns, bad indices, empty windows).

Nice-to-have (include as small helper functions)
	•	resolve_target_column(df, target_spec) -> str
	•	infer_iteration_column(df) -> str  (final column logic)
	•	build_checkpoints(startday, offset, exp_length=None, extra_days=None) -> list[int]
	•	compute_window_bounds(t0: pd.Timestamp, day: int, window_days: float) -> tuple[pd.Timestamp, pd.Timestamp]