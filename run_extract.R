# Run extraction and save output
# Usage: Rscript run_extract.R

source("R/extract_need_index.R")
source("R/get_need_index.R")

# Extract all need index data
ni <- get_need_index("input")

# Create output directory
dir.create("output", showWarnings = FALSE)

# Save as CSV (readr writes full double precision by default)
readr::write_csv(ni, "output/need_index.csv")

# Save as RDS
saveRDS(ni, "output/need_index.rds")

message(sprintf("Saved %d rows to output/need_index.csv and output/need_index.rds", nrow(ni)))

# Print summary
cat("\n--- Summary ---\n")
cat(sprintf("Total rows: %d\n", nrow(ni)))
cat("\nRows by Org_Type and financial_year:\n")
print(table(ni$Org_Type, ni$financial_year))
cat("\nSample rows:\n")
print(head(ni, 10))
