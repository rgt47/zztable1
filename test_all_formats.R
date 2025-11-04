#!/usr/bin/env Rscript

# Test all output formats with footnote fixes
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
  variables = list(
    len = "Tooth length measured in microns"
  ),
  columns = list(
    VC = "Ascorbic acid supplement", 
    OJ = "Fresh orange juice"
  ),
  general = c(
    "Guinea pig study by Crampton (1947)",
    "Statistical analysis using Welch's t-test"
  )
)

bp <- table1(
  supp ~ len,
  data = ToothGrowth,
  footnotes = clinical_footnotes,
  theme = "console"
)

cat("=== CONSOLE OUTPUT ===\n")
console_output <- display_table(bp, ToothGrowth, theme = "console")
cat(console_output, "\n\n")

cat("=== HTML OUTPUT (first 500 chars) ===\n")
html_output <- render_html(bp, get_theme("console"))
cat(substr(html_output, 1, 500), "\n...\n\n")

cat("=== LATEX OUTPUT (first 400 chars) ===\n")
latex_output <- render_latex(bp, get_theme("console"))
cat(substr(latex_output, 1, 400), "\n...\n\n")

# Test other themes too
cat("=== NEJM THEME ===\n")
bp_nejm <- table1(
  supp ~ len,
  data = ToothGrowth,
  footnotes = clinical_footnotes,
  theme = "nejm"
)
nejm_output <- display_table(bp_nejm, ToothGrowth, theme = "nejm")
cat(substr(nejm_output, 1, 300), "\n...\n")
