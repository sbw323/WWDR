## Key Changes Required

**1. Update Window Duration Calculation**
- **Current**: Window size is calculated from `duration_hours` using `duration_to_timesteps()`
- **Change**: Replace with fixed 192-row windows
- **Location**: `detect_experiment_windows()` function

**2. Modify Window Detection Logic**
```python
# Current (line ~118):
duration_steps = duration_to_timesteps(meta.duration_hours)
end = start + duration_steps - 1

# Change to:
FIXED_WINDOW_SIZE = 192
end = start + FIXED_WINDOW_SIZE - 1
```

**3. Rename and Refactor the Aggregation Function**
- **Current**: `compute_window_means()` (line ~132)
- **Change to**: `compute_window_maxima()` or similar
- **Update logic**: Replace `.mean()` with `.max()` for each column

```python
# Current (line ~155):
row[f"avg_{col}"] = window_df[col].mean()

# Change to:
row[f"max_{col}"] = window_df[col].max()
```

**4. Update Column Name Prefix**
- All output columns currently use `avg_` prefix
- Change to `max_` prefix throughout

**5. Update Settler Processing**
- **Location**: Line ~208 in settler extraction section
- Apply same fixed 192-row window:
```python
# Current:
duration_steps = duration_to_timesteps(meta.duration_hours)

# Change to:
duration_steps = FIXED_WINDOW_SIZE
```

**6. Update Documentation**
- Module docstring (line ~4): Change "mean values" to "maximum values"
- Function docstrings: Update `compute_window_means` description
- Variable names: Consider renaming `AVERAGE_COLUMNS` to `TARGET_COLUMNS` or `MAX_COLUMNS`

**7. Optional: Remove Unused Duration Logic**
Since you're using a fixed window size, the `duration` field in output records becomes less meaningful. You could either:
- Keep it for reference (shows original experiment duration)
- Remove it since window size is now constant
- Add a new field `window_size = 192` for clarity

## Summary of Function Changes
- `detect_experiment_windows()`: Use fixed 192-row windows
- `compute_window_means()` → `compute_window_maxima()`: Change aggregation from mean to max
- Update all `avg_` prefixes to `max_` in column names
- Apply changes to both reactor and settler processing sections