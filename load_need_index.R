# Load need index into environment for interactive use
# Usage: source this script, then call join_weighted_pop(your_reg_pop_df, ni)

source("R/extract_need_index.R")
source("R/get_need_index.R")
source("R/join_weighted_pop.R")

# Extract need index into `ni`
ni <- get_need_index("input")

message("Ready. `ni` is in your environment.")
message("Usage: result <- join_weighted_pop(your_reg_pop_df, ni)")
