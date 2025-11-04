#!/usr/bin/env Rscript

# Debug HTML table output
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

cat("=== DEBUGGING HTML TABLE OUTPUT ===\n\n")

# Create simple table
bp <- table1(
  supp ~ len + dose,
  data = ToothGrowth,
  theme = "nejm",
  pvalue = TRUE,
  totals = TRUE
)

cat("Blueprint created successfully\n")
cat("Dimensions:", dim(bp)[1], "x", dim(bp)[2], "\n\n")

# Test HTML rendering
cat("HTML OUTPUT:\n")
cat("============\n")
html_output <- render_html(bp, get_theme("nejm"))
cat("HTML Length:", nchar(html_output), "characters\n")
cat("First 500 characters:\n")
cat(substr(html_output, 1, 500), "\n\n")

# Test console rendering
cat("CONSOLE OUTPUT:\n")
cat("===============\n")
console_output <- display_table(bp, ToothGrowth, theme = "nejm")
cat(console_output)