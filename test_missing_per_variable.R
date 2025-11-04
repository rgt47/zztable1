#!/usr/bin/env Rscript

# Test missing data handling per variable
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

# Create test scenarios with different missing patterns
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))

cat("=== VARIABLE-LEVEL MISSING DATA ANALYSIS ===\n\n")

# Scenario 1: Only MPG has missing values
mtcars_mpg_missing <- mtcars
mtcars_mpg_missing$mpg[1:3] <- NA
cat("Scenario 1: Only MPG missing (3 values)\n")

bp1 <- table1(transmission ~ mpg + hp + wt, data = mtcars_mpg_missing, missing = TRUE)
cat("Table dimensions:", dim(bp1)[1], "x", dim(bp1)[2], "\n")
output1 <- display_table(bp1, mtcars_mpg_missing, theme = "console")
cat("Missing rows added: Only for MPG\n\n")

# Scenario 2: Only HP has missing values  
mtcars_hp_missing <- mtcars
mtcars_hp_missing$hp[1:2] <- NA
cat("Scenario 2: Only HP missing (2 values)\n")

bp2 <- table1(transmission ~ mpg + hp + wt, data = mtcars_hp_missing, missing = TRUE)
cat("Table dimensions:", dim(bp2)[1], "x", dim(bp2)[2], "\n")
cat("Missing rows added: Only for HP\n\n")

# Scenario 3: All variables have missing values
mtcars_all_missing <- mtcars
mtcars_all_missing$mpg[1:3] <- NA
mtcars_all_missing$hp[4:5] <- NA  
mtcars_all_missing$wt[6:8] <- NA
cat("Scenario 3: All variables missing (different amounts)\n")
cat("- MPG missing:", sum(is.na(mtcars_all_missing$mpg)), "\n")
cat("- HP missing:", sum(is.na(mtcars_all_missing$hp)), "\n")
cat("- WT missing:", sum(is.na(mtcars_all_missing$wt)), "\n")

bp3 <- table1(transmission ~ mpg + hp + wt, data = mtcars_all_missing, missing = TRUE)
cat("Table dimensions:", dim(bp3)[1], "x", dim(bp3)[2], "\n")
cat("Missing rows added: One for each variable with missing data\n\n")

# Compare dimensions
cat("DIMENSION COMPARISON:\n")
cat("=====================\n")
cat("No missing data (missing=TRUE):      ", dim(table1(transmission ~ mpg + hp + wt, data = mtcars, missing = TRUE))[1], "rows\n")
cat("1 variable with missing (MPG):       ", dim(bp1)[1], "rows (+", dim(bp1)[1] - 3, ")\n")
cat("1 variable with missing (HP):        ", dim(bp2)[1], "rows (+", dim(bp2)[1] - 3, ")\n") 
cat("3 variables with missing:            ", dim(bp3)[1], "rows (+", dim(bp3)[1] - 3, ")\n\n")

# Show actual missing data display
cat("ACTUAL MISSING DATA DISPLAY (Console format):\n")
cat("==============================================\n")
output3 <- display_table(bp3, mtcars_all_missing, theme = "console")
cat(output3)