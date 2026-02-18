# Join need index with monthly registered population to calculate monthly weighted population
#
# reg_pop_df columns: Org_Type, Org_Code, ons_code, Number_Of_Patients,
#                     Effective_Snapshot_Date, Effective_Month, FY_Start_Date
#
# need_index_df columns: Org_Type, Org_Code, Org_Name, financial_year,
#                         need_index, FY_Start_Date

library(dplyr)

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
