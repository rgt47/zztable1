#!/usr/bin/env Rscript

# Test missing data with factor variables
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

# Create test data with factor variables
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
mtcars$cylinders <- factor(mtcars$cyl)
mtcars$gears <- factor(mtcars$gear)

cat("=== MISSING DATA WITH FACTOR VARIABLES ===\n\n")

# Baseline: No missing data
bp_baseline <- table1(transmission ~ mpg + cylinders + gears, data = mtcars, missing = TRUE)
cat("Baseline (no missing):", dim(bp_baseline)[1], "rows\n")

# Add missing values to different variable types
mtcars_mixed_missing <- mtcars
mtcars_mixed_missing$mpg[1:3] <- NA           # Numeric variable
mtcars_mixed_missing$cylinders[4:6] <- NA     # Factor variable  
mtcars_mixed_missing$gears[7:8] <- NA         # Factor variable

cat("Missing data added:\n")
cat("- mpg (numeric):", sum(is.na(mtcars_mixed_missing$mpg)), "missing\n")
cat("- cylinders (factor):", sum(is.na(mtcars_mixed_missing$cylinders)), "missing\n")
cat("- gears (factor):", sum(is.na(mtcars_mixed_missing$gears)), "missing\n\n")

# Test with missing data
bp_missing <- table1(transmission ~ mpg + cylinders + gears, data = mtcars_mixed_missing, missing = TRUE)
cat("With missing data:", dim(bp_missing)[1], "rows\n")
cat("Additional rows:", dim(bp_missing)[1] - dim(bp_baseline)[1], "\n\n")

# Show the actual output
cat("DISPLAY WITH MIXED MISSING DATA:\n")
cat("================================\n")
output <- display_table(bp_missing, mtcars_mixed_missing, theme = "console")
cat(output, "\n\n")

# Test edge case: Factor with all levels missing
mtcars_extreme <- mtcars
mtcars_extreme$cylinders[] <- NA  # All values missing

cat("EDGE CASE - All factor values missing:\n")
bp_extreme <- table1(transmission ~ cylinders, data = mtcars_extreme, missing = TRUE)
cat("Dimensions:", dim(bp_extreme)[1], "x", dim(bp_extreme)[2], "\n")
output_extreme <- display_table(bp_extreme, mtcars_extreme, theme = "console") 
cat(output_extreme)