#!/usr/bin/env Rscript

# Debug table structure to see where column headers are
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
  )
)

bp <- table1(
  supp ~ len + dose,
  data = ToothGrowth,
  footnotes = clinical_footnotes,
  theme = "console"
)

cat("BLUEPRINT STRUCTURE:\n")
cat("====================\n")
cat("Column names:", paste(bp$col_names, collapse = ", "), "\n")
cat("Dimensions:", bp$nrows, "x", bp$ncols, "\n\n")

cat("CELL KEYS (first 10):\n")
cat("=====================\n")
cell_keys <- ls(bp$cells, all.names = TRUE)
cat(paste(head(cell_keys, 10), collapse = ", "), "\n\n")

cat("TESTING HTML OUTPUT:\n")
cat("====================\n")
html_output <- render_html(bp, get_theme("console"))
# Look for column headers in HTML
cat(substr(html_output, 1, 400), "\n...\n\n")

# Test if the issue is just in console display vs HTML
cat("TESTING COLUMN MARKER APPLICATION:\n")
cat("===================================\n")
test_header <- apply_footnote_marker("VC", "col_VC", bp$metadata$footnote_markers, "console")
cat("VC with marker:", test_header, "\n")
test_header2 <- apply_footnote_marker("OJ", "col_OJ", bp$metadata$footnote_markers, "console")
cat("OJ with marker:", test_header2, "\n")
