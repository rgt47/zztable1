#!/usr/bin/env Rscript

# Debug marker number assignments
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

cat("DETAILED MARKER ANALYSIS:\n")
cat("==========================\n")
print(bp$metadata$footnote_markers)
cat("\nFootnote list:\n")
for (i in seq_along(bp$metadata$footnote_list)) {
  cat(i, ". ", bp$metadata$footnote_list[[i]], "\n")
}
