
def main():
    """Main automation routine for multiple DR dataset generation"""

    print("=" * 60)
    print("AUTOMATED DR DATASETS GENERATION")
    print("=" * 60)
    print("Generating datasets for experiment lengths: 4, 5, 6, 7 hours")

    # Configuration
    start_length = 4
    end_length = 7
    offset_set = [0, 1, 2]

    lengths = list(range(start_length, end_length + 1))
    total_datasets = len(lengths) * len(offset_set)
    print(f"Total datasets to generate: {total_datasets}")
    print("=" * 60)

    dataset_counter = 0
    for offset_idx, start_day_offset in enumerate(offset_set, 1):
        print(f"\n--- Offset {offset_idx}/{len(offset_set)}: start day {start_day_offset} ---")

        for length_idx, experiment_length in enumerate(lengths, 1):
            dataset_counter += 1
            print(f"\n{'='*50}")
            print(
                f"DATASET {dataset_counter}/{total_datasets}: {experiment_length}-HOUR DR EVENTS (start day {start_day_offset})"
            )
            print(f"{'='*50}")

            try:
                # Step 1: Create experimental KLa input files
                create_experimental_kla_files(
                    experiment_length,
                    start_day_offset=start_day_offset,
                )

                # Step 2: Run MATLAB data generation
                run_ASM3_data_generation()

                # Step 3: Backup results
                backup_results(experiment_length, start_day_offset)

                print(
                    f"\n✓ Dataset {dataset_counter}/{total_datasets} completed successfully"
                )

            except Exception as e:
                print(f"\n✗ Error in dataset {dataset_counter}: {str(e)}")
                print("Stopping automation due to error.")
                return

    print(f"\n{'='*60}")
    print("AUTOMATION COMPLETED")
    print(f"{'='*60}")
    print(
        f"Generated {total_datasets} datasets across offsets {offset_set} and experiment lengths {lengths}"
    )
    print("Results are backed up in separate directories for each experiment length")
    print("Check individual Results_ExpLength_*h directories for outputs")

if __name__ == "__main__":
    main()