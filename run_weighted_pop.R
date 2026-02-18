# Weighted population pipeline
# Sources functions, extracts need index, joins with registered population,
# calculates normalised weighted population, and runs validation.

source("R/extract_need_index.R")
source("R/get_need_index.R")
source("R/join_weighted_pop.R")

# Extract need index
ni <- get_need_index("input")

# Join with registered population and normalise
result <- join_weighted_pop(reg_pop_df, ni)
result <- calc_normalised_wp(result)

# Validate totals
test_normalised_wp(result)
