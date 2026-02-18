# Combine need index from all Excel files into a single dataset

library(dplyr)

get_need_index <- function(input_dir = "input") {
  # File paths
  files <- c(
    file_2022_23 = file.path(input_dir, "j-overall-weighted-populations-22-23.xlsx"),
    file_2023_24 = file.path(input_dir, "j-overall-weighted-populations-2023-24-v1.xlsx"),
    file_2025_26 = file.path(input_dir, "J--overall-weighted-populations-2025-to-2026.xlsx"),
    file_2026_29 = file.path(input_dir, "j-overall-weighted-populations-2627-to-2829-v3.xlsx")
  )

  # Check files exist
  missing <- files[!file.exists(files)]
  if (length(missing) > 0) {
    stop("Missing input files:\n  ", paste(missing, collapse = "\n  "))
  }

  # Extract from each file
  message("Extracting from 2022-23 file...")
  d1 <- extract_2022_23(files[["file_2022_23"]])

  message("Extracting from 2023-24 file...")
  d2 <- extract_2023_24(files[["file_2023_24"]])

  message("Extracting from 2025-26 file...")
  d3 <- extract_2025_26(files[["file_2025_26"]])

  message("Extracting from 2026-29 file...")
  d4 <- extract_2026_29(files[["file_2026_29"]])

  # Combine, add FY_Start_Date, recode Org_Type, sort
  result <- bind_rows(d1, d2, d3, d4) |>
    mutate(
      FY_Start_Date = paste0(substr(financial_year, 1, 4), "-04-01"),
      Org_Type = case_match(
        Org_Type,
        "gp" ~ "GP",
        "icb" ~ "ICB",
        "region" ~ "Comm Region"
      )
    ) |>
    arrange(Org_Type, FY_Start_Date, Org_Code)

  # Summary
  message(sprintf(
    "Done. %d rows: %d Comm Region, %d ICB, %d GP across %s",
    nrow(result),
    sum(result$Org_Type == "Comm Region"),
    sum(result$Org_Type == "ICB"),
    sum(result$Org_Type == "GP"),
    paste(unique(result$financial_year), collapse = ", ")
  ))

  result
}
