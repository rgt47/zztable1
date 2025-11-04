#!/usr/bin/env Rscript

# Debug console header rendering
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

clinical_footnotes <- list(
  columns = list(
    VC = "Ascorbic acid supplement", 
    OJ = "Fresh orange juice"
  )
)

bp <- table1(
  supp ~ len,
  data = ToothGrowth,
  footnotes = clinical_footnotes,
  theme = "console"
)

cat("CONSOLE OUTPUT:\n")
cat("===============\n")
output <- display_table(bp, ToothGrowth, theme = "console")
cat(output, "\n\n")

cat("HTML OUTPUT (should show column headers with superscripts):\n")
cat("==========================================================\n")
html_output <- render_html(bp, get_theme("console"))
cat(substr(html_output, 1, 300), "\n")
