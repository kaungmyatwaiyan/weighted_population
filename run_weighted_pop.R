# Load need index and weighted population functions into environment
# Usage: source this script, then join with your registered population df
#
# Example:
#   source("run_weighted_pop.R")
#   result <- join_weighted_pop(reg_pop_df, ni)
#   result <- calc_normalised_wp(result)
#   test_normalised_wp(result)

source("R/extract_need_index.R")
source("R/get_need_index.R")
source("R/join_weighted_pop.R")

# Extract need index into `ni`
ni <- get_need_index("input")

message("Ready. `ni` is in your environment.")
message("Usage:")
message("  result <- join_weighted_pop(reg_pop_df, ni)")
message("  result <- calc_normalised_wp(result)")
message("  test_normalised_wp(result)")
