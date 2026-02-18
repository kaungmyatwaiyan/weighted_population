# Weighted Population Need Index

Extract annual need index from NHS weighted population Excel files and join with monthly registered population data to calculate monthly weighted populations.

## Method

1. **Annual Need Index** = Weighted Population ÷ Registered Population (from Excel files)
2. **Monthly Weighted Population** = Monthly Registered Population × Annual Need Index

## Data Coverage

| | 2022-23 | 2023-24 | 2024-25 | 2025-26 | 2026-27 | 2027-28 | 2028-29 |
|---|---|---|---|---|---|---|---|
| Comm Region | 7 | 7 | 7 | 7 | 7 | 7 | 7 |
| ICB | 42 | 42 | 42 | 42 | 36 | 36 | 36 |
| GP | 6,554 | 6,553 | 6,553 | 6,348 | 6,281 | 6,281 | 6,281 |

## Files

```
R/
  extract_need_index.R   # Hardcoded extraction functions (one per Excel file)
  get_need_index.R       # Combines all extractions into one dataset
  join_weighted_pop.R    # Joins need index with monthly registered population
run_extract.R            # Extracts and exports to output/
load_need_index.R        # Loads need index into environment for interactive use
input/                   # Excel files (not tracked in git)
output/                  # CSV/RDS exports (not tracked in git)
```

## Usage

### Extract and export

```r
source("run_extract.R")
```

### Interactive: load and join

```r
source("load_need_index.R")
result <- join_weighted_pop(reg_pop_df, ni)
```

## Output Schema

| Column | Example |
|---|---|
| `Org_Type` | `Comm Region`, `ICB`, `GP` |
| `Org_Code` | `Y63`, `QHM`, `A81001` |
| `Org_Name` | `North East and Yorkshire` |
| `financial_year` | `2022-23` |
| `need_index` | `1.1182282401324888` |
| `FY_Start_Date` | `2022-04-01` |

## Dependencies

- `readxl`, `dplyr`, `purrr`, `readr`
