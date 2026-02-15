You are updating a Python toolchain composed of three scripts:

    1. naive_vstacker.py
    2. stacked_exp_influent_combiner.py
    3. SNH4_normalizer.py

A new dataset batch lives at:
    /Users/ikai/github/WWDR-Databases/Databases/Nov25

Refactor-Safe Requirements:
------------------------------------
Your changes must preserve all existing interfaces, assumptions, and file formats unless explicitly modified below. 
Do not rename existing functions, arguments, or output fields unless required by the task. 
All new functionality must be added in a backward-compatible way.

Task:
1. Create a new shared utility function that generates the name of the final column added to each dataset:
       - Base name: "energy_use"
       - Append the reactor suffix (e.g., "_R1", "_R2", etc.) derived from the dataset’s metadata.
   This function must be:
       - Pure (no side effects)
       - Independently testable
       - Imported and used by all three scripts
       - Added without modifying existing function signatures

2. Update naive_vstacker.py and stacked_exp_influent_combiner.py so that:
       - When constructing the final column for a dataset, they call the new naming function.
       - The new energy-use column is appended in the same positional schema currently used for other added variables.
       - No existing column names or ordering behavior is changed except for the new column addition.

3. Update SNH4_normalizer.py so that:
       - It also normalizes all energy-use columns created by the other two scripts.
       - Normalization uses nominal reference values from:
            Reac1_to_Reac5_nominal_energy.md
       - Implement a robust, maintainable loader for these nominal values:
            * YAML-like block, Markdown table, or simple key-value text parsing
            * Select the least intrusive option that requires no changes to the markdown file
       - The normalization logic must:
            * Detect energy-use columns based on their prefix ("energy_use")
            * Match the correct reactor suffix automatically
            * Apply normalization independently of other variables
       - Do NOT modify any existing normalization steps.

4. Ensure that:
       - The updated workflow processes datasets in the Nov25 directory end-to-end with no manual edits.
       - All new code includes docstrings explaining purpose and usage.
       - The refactoring introduces NO breaking changes for existing users or scripts.

Deliverables:
------------------------------------
- Updated versions of all three scripts.
- The new shared utility function (in a new or existing utilities module).
- Clear imports and integration points showing how each script incorporates the new function.
- Full, clean, runnable Python 3.11 code.

Produce code that is maintainable, readable, and stable under future refactoring.