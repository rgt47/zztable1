#!/usr/bin/env Rscript

# Comprehensive test of all footnote types
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

# Complex footnotes with all types
comprehensive_footnotes <- list(
  variables = list(
    len = "Primary endpoint measurement",
    dose = "Treatment dosing schedule"
  ),
  columns = list(
    VC = "Synthetic vitamin C treatment arm", 
    OJ = "Natural orange juice treatment arm"
  ),
  general = c(
    "Randomized controlled trial design",
    "Statistical analysis performed using R",
    "All measurements blinded and standardized"
  )
)

bp <- table1(
  supp ~ len + dose,
  data = ToothGrowth,
  footnotes = comprehensive_footnotes,
  theme = "nejm",
  pvalue = TRUE,
  totals = TRUE
)

cat("=== COMPREHENSIVE FOOTNOTE TEST ===\n")
cat("Expected: len¹, dose², OJ³, VC⁴ in table\n")
cat("Expected: 1-4 numbered, then • bullets\n\n")

output <- display_table(bp, ToothGrowth, theme = "nejm")
cat(output, "\n")
