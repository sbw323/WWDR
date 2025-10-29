I have two components:
	•	implementer(): scans experiment directories, selects those matching ExpLength and startday, and calls the stacker on the matching folder(s).
	•	vstack_timeseries_helper() (the “stacker”): vertically stacks time-series files on 15-minute timestamps.

I need you to fix and enhance both so they obey the following contract:

Objective

For each selected (ExpLength, startday) group, stack files only by identical file type, producing six separate outputs:
	•	R1, R2, R3, R4, R5, and Settler (a.k.a. S).
In other words, do not mix reactors and settler data in the same stack; and do not mix different file types within a single output.
If I specify ExpLength=1 and startday=0, the pipeline should create six output CSVs (one per type) that stack all iterations available for R1–R5 and Settler.

Inputs & Directory Parsing
	•	Directory names encode two parameters:
	•	ExpLength (e.g., Exp1d, Exp14d, Exp28d)
	•	startday (e.g., day000, day001, day014)
	•	Accept single values or ranges/lists for both:
	•	Examples:
	•	--ExpLength 1 or --ExpLength 1 14 28
	•	--startday 0 or --startday 0 1 2 3 or --startday-range 0 14
	•	Implement robust parsing via regex (configurable patterns). Default patterns:
	•	ExpLength: r"Exp(\d+)d"
	•	startday: r"day(\d{3})"
	•	Use pathlib to walk subdirectories of --parentdir.

File Typing & Grouping (CRITICAL)
	•	Each data file must be assigned a type key in {R1,R2,R3,R4,R5,S} based on its filename (or a column header if that’s more reliable).
	•	Provide a configurable regex map (fallback defaults shown):

EXPERIMENTS: Mapping[str, str] = {
    "4h": "Results_ExpLength_4h_startday_0",
    # "5h": "Results_ExpLength_5h_startday_0",
    # "6h": "Results_ExpLength_6h_startday_0",
    # "7h": "Results_ExpLength_7h_startday_0",
}

TYPE_MAP = {
    "R1": r"\bR1\b|reactor[_-]?1[_-]iteration[_-]?\d\d\d",
    "R2": r"\bR2\b|reactor[_-]?2[_-]iteration[_-]?\d\d\d",
    "R3": r"\bR3\b|reactor[_-]?3[_-]iteration[_-]?\d\d\d",
    "R4": r"\bR4\b|reactor[_-]?4[_-]iteration[_-]?\d\d\d",
    "R5": r"\bR5\b|reactor[_-]?5[_-]iteration[_-]?\d\d\d",
    "S":  r"\bS\b|settler[_-]iteration[_-]?\d\d\d"
}


	•	The stacker must run once per type key (up to six runs per (ExpLength,startday) group).
	•	If any type key has no files, skip that type with a warning; otherwise, emit exactly one CSV per present type.

Stacker Behavior (no mixing)
	•	For the current (ExpLength, startday, type_key):
	1.	Load all matching files (CSV or DataFrame input).
	2.	Convert timestamp to datetime64[ns].
	3.	Filter to 15-minute grid only (i.e., timestamps where (minute % 15) == 0 → minutes ∈ {00, 15, 30, 45}). Either:
	•	(Preferred) enforce with df = df[df.index.minute.isin([0,15,30,45])] after setting timestamp as index, or
	•	resample to 15 min and align via inner join.
	4.	Ensure identical timestamp index across all files (inner join on intersection of timestamps).
	5.	Vertically stack (row-bind) the aligned frames, add source_id (filename without extension), and keep consistent columns.
	6.	Output one CSV for this type_key.

Implementer Orchestration
	•	For each directory that matches the requested ExpLength and startday:
	•	Discover all candidate files.
	•	Partition files into six buckets by type_key using TYPE_MAP.
	•	Call vstack_timeseries_helper(files=bucket_files, type_key=..., exp_length=..., startday=..., outdir=...) once per non-empty bucket.
	•	Command-line interface (via argparse):
	•	--parentdir PATH (default: ./data/experiments)
	•	--ExpLength (list of ints) and/or --ExpLength-range start end
	•	--startday (list of ints) and/or --startday-range start end
	•	--outdir PATH (default: ./combined)
	•	Optional: --pattern-exp REGEX, --pattern-day REGEX, --dry-run, --verbose

Output Naming
	•	For each (ExpLength, startday, type_key) emit:
	•	Directory: OUTDIR/Exp{ExpLength}d_day{startday:03d}/
	•	File: stack_{type_key}_Exp{ExpLength}d_day{startday:03d}.csv

Validation & Safety Checks
	•	Schema: Verify required columns (at minimum timestamp; allow arbitrary data columns). If columns differ across files of the same type, union the columns and fill missing with NaN, but timestamps must align exactly after filtering.
	•	Timestamp sanity:
	•	Drop rows not on 15-minute marks.
	•	If fewer than 2 files remain for a type bucket, still allow stacking (single source) but log a warning.
	•	Determinism: Sort by timestamp ascending and source_id.
	•	Logging: For each emitted CSV, log count of files stacked, time span, and number of rows.

Edge Cases
	•	Mixed naming (R-1.csv, reactor1.csv, R1_timeseries_iter03.csv) should still match via TYPE_MAP.
	•	Missing types (e.g., no R4 in a run) should not block other outputs.
	•	If a directory matches ExpLength but not startday, skip silently unless --verbose.

Deliverables
	•	Updated implementer.py with:
	•	implementer(...) function + main() using argparse
	•	Directory scanning, regex extraction, range handling, bucketing by type_key, and calls into the stacker
	•	Updated stacker.py with:
	•	vstack_timeseries_helper(files, type_key, exp_length, startday, outdir, ...) implementing the behavior above
	•	Clear docstrings, type hints (Python 3.10+), and unit-style smoke tests (small in-memory DataFrames) proving:
	1.	six independent outputs when all types present;
	2.	strict 15-minute alignment;
	3.	no cross-type mixing;
	4.	robust filename typing via TYPE_MAP.

Please produce production-quality, well-commented code. Keep external deps to pandas, numpy, and stdlib.