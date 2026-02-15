Extend pipeline to paired settler datasets

Use the attached reference code vessel_experiment_results_max.md as the baseline for modifications.
Your task is to write new code sections AND refactor existing functions to support a companion Settler dataset aligned by timestep to the vessel experiment windows.

Reference:  ￼

⸻

Goals
	1.	Use experiment windows already detected for reactor vessels
✔ Do not re-detect windows from scratch
✔ Settler windows = identical row spans
	2.	Settler datasets have no energy reduction column
→ Instead, match on timestamp index positions
	3.	Compute maximum values (not averages) for a list of settler target columns
	4.	Generate output files parallel to vessel output format

⸻

Required Modifications for Codex to Implement

⸻

1. Create settler dataset loader + window extractor

Add new function:

def extract_settler_windows(settler_df, windows, target_columns):
    """
    Input:
        settler_df → dataframe aligned 1:1 in timestep with reactor dataset
        windows → list of (start_row, end_row) index pairs from vessel detection
        target_columns → columns to compute values for (settler-specific)
    Output:
        rows → list of computed max values for each window
    """

The results should mirror reactor output rows:

{
   "reactor": vessel_no,
   "duration_hr": duration,
   "energy_reduc": reduc,
   "window_index": experiment_index,
   "window_start": start,
   "window_end": end,
   "max_<settler_col_1>": ...,
   "max_<settler_col_2>": ...,
   ...
}


⸻

2. Add parallel processing loop for settler files

Create new function:

def process_settler_companion_data(settler_folder, reactor_results):

Where:

Input	Description
settler_folder	Directory of aligned settler CSV files
reactor_results	Dict mapping (reactor,duration,reduction) → window index ranges

Inside:
	1.	Parse filenames using the SAME metadata structure as vessels
	2.	Load corresponding settler dataframe
	3.	Lookup experiment windows from reactor_results
	4.	Run extract_settler_windows()
	5.	Append results into a new master dataframe
	6.	Save to /output/settler_experiment_results_max.csv

⸻

3. Add CLI hooks + user-variable block

Append to bottom of script:

if __name__ == "__main__":
    VESSEL_RESULTS_FILE = "vessel_experiment_results_MAX.csv"
    SETTLER_FOLDER = "/path/to/settler/data"
    SETTLER_TARGET_COLS = ["TSS", "NH4", "COD", ...]    # <== EDIT HERE

    vessel_windows = load_vessel_results_lookup(VESSEL_RESULTS_FILE)
    settler_results = process_settler_companion_data(SETTLER_FOLDER, vessel_windows)


⸻

4. Deliverables Codex should output

Codex final code must produce all three:

Output	File
Reactor Max Summary (existing)	vessel_experiment_results_MAX.csv
Settler Max Summary (new)	settler_experiment_results_MAX.csv
Optional Combined Export	combined_reactor_settler_MAX.csv

Combined dataset step is optional but recommended.