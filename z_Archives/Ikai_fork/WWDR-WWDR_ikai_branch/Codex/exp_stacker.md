I would like to create a Python script that vertically stacks multiple time series datasets (.csv or pandas.DataFrame) by aligning them on columns. The timeseries fall exactly on 15-minute intervals — i.e., (96 % timestep) == 0.

Requirements:
	1.	Load any number of input time series files (each with at least one timestamp column).
	2.	Vertically stack (vstack) all columns aligned data into one DataFrame with consistent columns, adding a new column indicating the source file name or ID.
	3.	Output the resulting combined dataset as a new CSV.

Implementation details:
	•	Use Python 3.10+ and the pandas library.
	•	Include command-line arguments (via argparse) to specify input folder or list of files and output file path.
	•	Validate timestamps and print helpful messages if files have misaligned or missing timestamps.
	•	Include a main() entry point so the script can be run directly.

Please include well-commented, production-quality code with clear function definitions.