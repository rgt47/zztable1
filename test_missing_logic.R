#!/usr/bin/env Rscript

# Test whether dimension calculation depends on actual missing data or just the flag
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

# Test data with NO missing values
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))

cat("=== MISSING DIMENSION LOGIC TEST ===\n\n")

# Test 1: missing=FALSE (default)
bp1 <- table1(transmission ~ mpg + hp, data = mtcars, missing = FALSE)
cat("1. missing=FALSE, no missing data: ", dim(bp1)[1], "x", dim(bp1)[2], "\n")

# Test 2: missing=TRUE but no actual missing data
bp2 <- table1(transmission ~ mpg + hp, data = mtcars, missing = TRUE)
cat("2. missing=TRUE, no missing data:  ", dim(bp2)[1], "x", dim(bp2)[2], "\n")

# Test 3: Create data with missing values
mtcars_missing <- mtcars
mtcars_missing$mpg[1:3] <- NA  # Add 3 missing values
mtcars_missing$hp[1:2] <- NA   # Add 2 missing values

# Test 4: missing=FALSE with missing data present
bp3 <- table1(transmission ~ mpg + hp, data = mtcars_missing, missing = FALSE)
cat("3. missing=FALSE, missing data:    ", dim(bp3)[1], "x", dim(bp3)[2], "\n")

# Test 5: missing=TRUE with actual missing data
bp4 <- table1(transmission ~ mpg + hp, data = mtcars_missing, missing = TRUE)
cat("4. missing=TRUE, missing data:     ", dim(bp4)[1], "x", dim(bp4)[2], "\n")

cat("\nConclusions:\n")
cat("============\n")
if (dim(bp1)[1] == dim(bp2)[1]) {
  cat("✓ Setting missing=TRUE with no actual missing data does NOT add rows\n")
} else {
  cat("✗ Setting missing=TRUE adds rows even with no missing data\n")
}

if (dim(bp4)[1] > dim(bp3)[1]) {
  cat("✓ Setting missing=TRUE with actual missing data DOES add rows\n")
} else {
  cat("✗ Setting missing=TRUE does not add rows even with missing data\n")
}

additional_rows <- dim(bp4)[1] - dim(bp1)[1]
cat("✓ Total additional rows with missing=TRUE and actual missing data:", additional_rows, "\n")