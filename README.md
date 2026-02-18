# Weighted Population Need Index

Extract the **overall need index** from the [NHS England Allocations](https://www.england.nhs.uk/allocations/) weighted population spreadsheets and join with monthly registered population data to calculate monthly weighted populations at GP practice, ICB, and Commissioning Region level.

## Background

NHS England publishes allocation formulae that distribute funding based on relative need. The **weighted population** adjusts raw registered populations by a **need index** that reflects differences in healthcare need across areas. This need index combines components for general & acute, community services, mental health, maternity, prescribing, and health inequalities.

This project extracts the overall need index from the **"J – Overall weighted populations"** supporting spreadsheets, available on the [NHS England Allocations page](https://www.england.nhs.uk/allocations/).

## Input Files

Download the **"J – Overall weighted populations by ICB and GP practice"** spreadsheets from the allocations page for each period and place them in the `input/` directory:

| File | Source |
|------|--------|
| `j-overall-weighted-populations-22-23.xlsx` | 2022-23 allocations |
| `j-overall-weighted-populations-2023-24-v1.xlsx` | 2023-24 to 2024-25 allocations |
| `J--overall-weighted-populations-2025-to-2026.xlsx` | 2025-26 allocations |
| `j-overall-weighted-populations-2627-to-2829-v3.xlsx` | 2026-27 to 2028-29 allocations |

## Method

**Monthly Weighted Population = Monthly Registered Population × Need Index**

The need index is published annually per financial year. This project joins it with monthly registered population snapshots so that each month's weighted population reflects both the latest list size and the annual need adjustment.

## Files

```
R/
  extract_need_index.R   # Hardcoded extraction functions (one per Excel file)
  get_need_index.R       # Combines all extractions into one dataset
  join_weighted_pop.R    # Join, normalise, and test weighted population
run_extract.R            # Extracts and exports to output/
run_weighted_pop.R       # Loads need index into environment for interactive use
input/                   # Excel files (not tracked in git)
output/                  # CSV/RDS exports (not tracked in git)
```

## Usage

### Extract and export

```r
source("run_extract.R")
```

### Interactive: load, join, and normalise

```r
source("run_weighted_pop.R")
result <- join_weighted_pop(reg_pop_df, ni)
result <- calc_normalised_wp(result)
test_normalised_wp(result)
```

### Normalised Weighted Population

```
Normalised_Weighted_Pop = (Weighted_Pop / Total_Weighted_Pop) × Total_Registered_Pop
```

Grouped by `Org_Type` + `Effective_Snapshot_Date`. This redistributes the actual registered population according to relative need, so that the total normalised weighted population equals the total registered population within each group.

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
