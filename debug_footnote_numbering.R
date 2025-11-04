#!/usr/bin/env Rscript

# Debug footnote numbering issue
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

cat("=== DEBUGGING FOOTNOTE NUMBERING ===\n\n")

# Test the clinical footnotes structure
clinical_footnotes <- list(
  variables = list(
    len = "Tooth length measured in microns using standardized odontometric techniques",
    dose = "Daily vitamin C dose administered orally over 60-day treatment period"
  ),
  columns = list(
    VC = "Ascorbic acid (pharmaceutical grade vitamin C supplement)", 
    OJ = "Fresh orange juice as natural source of vitamin C"
  ),
  general = c(
    "Guinea pig tooth growth study conducted by Crampton (1947)",
    "Statistical significance tested using Welch's t-test (alpha = 0.05)",
    "All measurements performed by blinded assessors"
  )
)

bp <- table1(
  supp ~ len + dose,
  data = ToothGrowth,
  footnotes = clinical_footnotes,
  theme = "console"
)

cat("EXPECTED BEHAVIOR:\n")
cat("- len should have superscript ¹ (variable footnote #1)\n")
cat("- dose should have superscript ² (variable footnote #2)\n") 
cat("- VC column should have superscript ³ (column footnote #3)\n")
cat("- OJ column should have superscript ⁴ (column footnote #4)\n")
cat("- General footnotes (#5-7) should have NO superscripts in table\n\n")

# Check the blueprint metadata
cat("BLUEPRINT FOOTNOTE MARKERS:\n")
cat("===========================\n")
print(bp$metadata$footnote_markers)
cat("\n")

cat("BLUEPRINT FOOTNOTE LIST:\n")
cat("========================\n")
for (i in seq_along(bp$metadata$footnote_list)) {
  cat(i, ". ", bp$metadata$footnote_list[[i]], "\n")
}
cat("\n")

cat("ACTUAL TABLE OUTPUT:\n")
cat("====================\n")
output <- display_table(bp, ToothGrowth, theme = "console")
cat(output)
