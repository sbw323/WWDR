I would like to create a new Python function called stacker_helper_implementer() that acts as a controller for my existing time-series stacking helper function (for example, vstack_timeseries_helper()).

The goal of implementer() is to:
	1.	Parse directory names in a specified parent folder (e.g., ./data/experiments/). Each directory name contains two key parameters encoded in the string:
	•	ExpLength (e.g., “Exp14d”, “Exp28d”)
	•	startday (e.g., “day001”, “day014”)
	2.	Filter and select directories that match the ExpLength and startday arguments provided to implementer().
	•	Both ExpLength and startday should accept either a single value or a range/list of values.
	•	Example usage:

implementer(ExpLength=[14, 28], startday=range(1, 15))

should select all folders whose names indicate experiment lengths of 14 d or 28 d and starting days between 1 and 14.

	3.	For each matching directory, call the helper function (e.g., vstack_timeseries_helper(directory_path)).
	4.	Optionally, aggregate or log all outputs into a summary file or list.

Implementation details:
	•	Use os or pathlib to iterate over subdirectories.
	•	Use regular expressions or string parsing to extract ExpLength and startday from folder names.
	•	Validate the ranges and handle type conversions robustly.
	•	Add argparse integration so users can call this from the command line with flags such as:

python implementer.py --ExpLength 14 28 --startday 1 14 --parentdir ./data/experiments/


	•	Include a main() entry point and logging output to the console.
	•	Assume the helper function vstack_timeseries_helper() already exists and just needs to be called correctly.

Please produce clean, well-documented Python 3.10+ code that can serve as a top-level orchestrator for batch processing of experiment directories.