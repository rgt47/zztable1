#!/usr/bin/env Rscript

# Test new summary statistics
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

data(ToothGrowth)
ToothGrowth$dose <- factor(ToothGrowth$dose)

cat("=== TESTING NEW SUMMARY STATISTICS ===\n\n")

cat("1. MEDIAN (RANGE):\n")
bp1 <- table1(supp ~ len, data = ToothGrowth, numeric_summary = "median_range")
cat(display_table(bp1, ToothGrowth), "\n\n")

cat("2. MEAN (95% CI):\n")
bp2 <- table1(supp ~ len, data = ToothGrowth, numeric_summary = "mean_ci")
cat(display_table(bp2, ToothGrowth), "\n\n")

cat("3. MEDIAN [IQR]:\n")
bp3 <- table1(supp ~ len, data = ToothGrowth, numeric_summary = "median_iqr")
cat(display_table(bp3, ToothGrowth), "\n")
