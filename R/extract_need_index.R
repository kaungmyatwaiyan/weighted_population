# Extract need index from NHS weighted population Excel files
# Each function is hardcoded to a specific file's layout

library(readxl)
library(dplyr)

# Helper: read excel with no headers, suppressing name repair messages
read_xl <- function(path, sheet) {
    suppressMessages(
        read_excel(path, sheet = sheet, col_names = FALSE, .name_repair = "unique")
    )
}

# ==============================================================================
# 1. Extract from j-overall-weighted-populations-22-23.xlsx (FY 2022-23)
# ==============================================================================
extract_2022_23 <- function(file_path) {
    d <- read_xl(file_path, "ICB weighted population")

    # --- ICB level (rows 7-54, col 1 not NA = actual ICB rows) ---
    icb_data <- d[7:54, ] |>
        filter(!is.na(`...1`)) |>
        transmute(
            Org_Type       = "icb",
            Org_Code       = as.character(`...2`),
            Org_Name       = as.character(`...3`),
            financial_year = "2022-23",
            need_index     = as.numeric(`...21`)
        )

    # --- Region level (rows 57-63 at the bottom) ---
    region_data <- d[57:63, ] |>
        transmute(
            Org_Type       = "region",
            Org_Code       = as.character(`...2`),
            Org_Name       = as.character(`...3`),
            financial_year = "2022-23",
            need_index     = as.numeric(`...21`)
        )

    # --- GP level ---
    g <- read_xl(file_path, "GP weighted population")

    gp_data <- g[4:nrow(g), ] |>
        filter(!is.na(`...1`)) |>
        transmute(
            Org_Type       = "gp",
            Org_Code       = as.character(`...1`),
            Org_Name       = as.character(`...2`),
            financial_year = "2022-23",
            need_index     = as.numeric(`...25`)
        )

    bind_rows(region_data, icb_data, gp_data)
}


# ==============================================================================
# 2. Extract from j-overall-weighted-populations-2023-24-v1.xlsx
#    (FY 2023-24 and 2024-25; skip "2022 base" rows)
# ==============================================================================
extract_2023_24 <- function(file_path) {
    exclude_vals <- c("2022 base", "Year", "Total")

    # --- Region level ---
    d <- read_xl(file_path, "Region_index")

    region_data <- d[4:nrow(d), ] |>
        filter(!is.na(`...2`), !(`...1` %in% exclude_vals)) |>
        transmute(
            Org_Type       = "region",
            Org_Code       = as.character(`...2`),
            Org_Name       = as.character(`...3`),
            financial_year = as.character(`...1`),
            need_index     = as.numeric(`...21`)
        )

    # --- ICB level ---
    d <- read_xl(file_path, "ICB_need_index")

    icb_data <- d[4:nrow(d), ] |>
        filter(!is.na(`...5`), !(`...1` %in% exclude_vals)) |>
        transmute(
            Org_Type       = "icb",
            Org_Code       = as.character(`...5`),
            Org_Name       = as.character(`...6`),
            financial_year = as.character(`...1`),
            need_index     = as.numeric(`...24`)
        )

    # --- GP level ---
    g <- read_xl(file_path, "GP_need_index")

    gp_data <- g[4:nrow(g), ] |>
        filter(!is.na(`...2`), !(`...1` %in% exclude_vals)) |>
        transmute(
            Org_Type       = "gp",
            Org_Code       = as.character(`...2`),
            Org_Name       = as.character(`...3`),
            financial_year = as.character(`...1`),
            need_index     = as.numeric(`...26`)
        )

    bind_rows(region_data, icb_data, gp_data)
}


# ==============================================================================
# 3. Extract from J--overall-weighted-populations-2025-to-2026.xlsx (FY 2025-26)
# ==============================================================================
extract_2025_26 <- function(file_path) {
    d <- read_xl(file_path, "icb_index_2526")

    # --- ICB level (rows 3-44) ---
    icb_data <- d[3:44, ] |>
        filter(!is.na(`...4`)) |>
        transmute(
            Org_Type       = "icb",
            Org_Code       = as.character(`...4`),
            Org_Name       = as.character(`...5`),
            financial_year = "2025-26",
            need_index     = as.numeric(`...22`)
        )

    # --- Region level (rows 47-53) ---
    region_data <- d[47:53, ] |>
        transmute(
            Org_Type       = "region",
            Org_Code       = as.character(`...4`),
            Org_Name       = as.character(`...5`),
            financial_year = "2025-26",
            need_index     = as.numeric(`...22`)
        )

    # --- GP level ---
    g <- read_xl(file_path, "gp_index_2526")

    gp_data <- g[3:nrow(g), ] |>
        filter(!is.na(`...1`)) |>
        transmute(
            Org_Type       = "gp",
            Org_Code       = as.character(`...1`),
            Org_Name       = as.character(`...2`),
            financial_year = "2025-26",
            need_index     = as.numeric(`...22`)
        )

    bind_rows(region_data, icb_data, gp_data)
}


# ==============================================================================
# 4. Extract from j-overall-weighted-populations-2627-to-2829-v3.xlsx
#    (FY 2026-27, 2027-28, 2028-29 — 3 year-specific sheet pairs)
# ==============================================================================
extract_2026_29 <- function(file_path) {
    years <- list(
        list(fy = "2026-27", icb_sheet = "icb_index_2627", gp_sheet = "gp_index_2627"),
        list(fy = "2027-28", icb_sheet = "icb_index_2728", gp_sheet = "gp_index_2728"),
        list(fy = "2028-29", icb_sheet = "icb_index_2829", gp_sheet = "gp_index_2829")
    )

    purrr::map_dfr(years, function(yr) {
        d <- read_xl(file_path, yr$icb_sheet)

        # ICB data rows 3-38
        icb_data <- d[3:38, ] |>
            filter(!is.na(`...4`)) |>
            transmute(
                Org_Type       = "icb",
                Org_Code       = as.character(`...4`),
                Org_Name       = as.character(`...5`),
                financial_year = yr$fy,
                need_index     = as.numeric(`...22`)
            )

        # Region rows 41-47
        region_data <- d[41:47, ] |>
            transmute(
                Org_Type       = "region",
                Org_Code       = as.character(`...4`),
                Org_Name       = as.character(`...5`),
                financial_year = yr$fy,
                need_index     = as.numeric(`...22`)
            )

        # GP level
        g <- read_xl(file_path, yr$gp_sheet)

        gp_data <- g[3:nrow(g), ] |>
            filter(!is.na(`...1`)) |>
            transmute(
                Org_Type       = "gp",
                Org_Code       = as.character(`...1`),
                Org_Name       = as.character(`...2`),
                financial_year = yr$fy,
                need_index     = as.numeric(`...24`)
            )

        bind_rows(region_data, icb_data, gp_data)
    })
}
