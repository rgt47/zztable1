#!/usr/bin/env Rscript

# Test missing data with stratified analysis
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
mtcars$cylinders <- factor(mtcars$cyl)

# Add missing data
mtcars_missing <- mtcars
mtcars_missing$mpg[1:3] <- NA
mtcars_missing$hp[4:5] <- NA

cat("=== MISSING DATA WITH STRATIFICATION ===\n\n")

# Test without stratification
bp_no_strata <- table1(transmission ~ mpg + hp, data = mtcars_missing, missing = TRUE)
cat("No stratification:", dim(bp_no_strata)[1], "x", dim(bp_no_strata)[2], "\n")

# Test with stratification by cylinders
bp_strata <- table1(transmission ~ mpg + hp, data = mtcars_missing, strata = "cylinders", missing = TRUE)
cat("With stratification:", dim(bp_strata)[1], "x", dim(bp_strata)[2], "\n")

cat("Stratification multiplier effect on missing rows:\n")
cat("- Base table rows: 4 (2 variables × 2 rows each including missing)\n") 
cat("- Strata levels:", length(unique(mtcars_missing$cylinders[!is.na(mtcars_missing$cylinders)])), "\n")
cat("- Expected: 4 × 3 = 12 variable rows + 3 strata headers = 15 total\n")
cat("- Actual:", dim(bp_strata)[1], "rows\n\n")

# Show a small sample of the output
cat("SAMPLE OUTPUT (stratified with missing):\n")
cat("========================================\n")
output <- display_table(bp_strata, mtcars_missing, theme = "console")
# Just show first 10 lines to avoid too much output
lines <- strsplit(output, "\n")[[1]]
cat(paste(lines[1:min(10, length(lines))], collapse = "\n"))
cat("\n... (truncated)\n")