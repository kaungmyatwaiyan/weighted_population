# Join need index with monthly registered population to calculate monthly weighted population
# Then normalise so totals equal the actual registered population
#
# reg_pop_df columns: Org_Type, Org_Code, ons_code, Number_Of_Patients,
#                     Effective_Snapshot_Date, Effective_Month, FY_Start_Date
#
# need_index_df columns: Org_Type, Org_Code, Org_Name, financial_year,
#                         need_index, FY_Start_Date

library(dplyr)


# Join need index with registered population and calculate weighted population
join_weighted_pop <- function(reg_pop_df, need_index_df) {
    # Select only columns needed for join
    ni_join <- need_index_df |>
        select(Org_Type, Org_Code, FY_Start_Date, need_index)

    # Left join and calculate weighted population
    result <- reg_pop_df |>
        left_join(ni_join, by = c("Org_Type", "Org_Code", "FY_Start_Date")) |>
        mutate(Weighted_Population = Number_Of_Patients * need_index)

    # Report unmatched rows
    n_unmatched <- sum(is.na(result$need_index))
    if (n_unmatched > 0) {
        warning(sprintf(
            "%d rows (%.1f%%) have no matching need index — Weighted_Population is NA for these.",
            n_unmatched, 100 * n_unmatched / nrow(result)
        ))
    }

    message(sprintf(
        "Joined %d rows. %d matched, %d unmatched.",
        nrow(result), nrow(result) - n_unmatched, n_unmatched
    ))

    result
}


# Add Normalised_Weighted_Population column
# Formula: (WP / Total_WP) * Total_Reg_Pop, grouped by Org_Type + Effective_Snapshot_Date
# Result: redistributes actual registered population according to relative need
#         so that sum(Normalised_WP) = sum(Registered_Pop) within each group
calc_normalised_wp <- function(df) {
    if (!all(c(
        "Weighted_Population", "Number_Of_Patients", "Org_Type",
        "Effective_Snapshot_Date"
    ) %in% names(df))) {
        stop("Missing required columns. Run join_weighted_pop() first.")
    }

    result <- df |>
        group_by(Org_Type, Effective_Snapshot_Date) |>
        mutate(
            Normalised_Weighted_Pop = (Weighted_Population / sum(Weighted_Population, na.rm = TRUE)) *
                sum(Number_Of_Patients, na.rm = TRUE)
        ) |>
        ungroup()

    message("Added Normalised_Weighted_Pop column.")
    result
}


# Test: verify that sum(Normalised_WP) == sum(Registered_Pop) within each group
test_normalised_wp <- function(df, tolerance = 0.01) {
    if (!"Normalised_Weighted_Pop" %in% names(df)) {
        stop("Missing Normalised_Weighted_Pop column. Run calc_normalised_wp() first.")
    }

    check <- df |>
        group_by(Org_Type, Effective_Snapshot_Date) |>
        summarise(
            Total_Reg_Pop = sum(Number_Of_Patients, na.rm = TRUE),
            Total_Norm_WP = sum(Normalised_Weighted_Pop, na.rm = TRUE),
            Diff = abs(Total_Reg_Pop - Total_Norm_WP),
            Pass = Diff < tolerance,
            .groups = "drop"
        )

    n_fail <- sum(!check$Pass)

    if (n_fail == 0) {
        message(sprintf(
            "PASS: All %d groups have matching totals (tolerance = %g).",
            nrow(check), tolerance
        ))
    } else {
        warning(sprintf(
            "FAIL: %d of %d groups have mismatched totals.",
            n_fail, nrow(check)
        ))
        print(filter(check, !Pass))
    }

    invisible(check)
}
