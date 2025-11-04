#!/usr/bin/env Rscript

# Test general footnotes specifically
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))

cat("=== TESTING GENERAL FOOTNOTES (should have no superscripts in table) ===\n\n")

# Test with ONLY general footnotes (no variable or column footnotes)
footnotes_general_only <- list(
  general = c(
    "Data from Motor Trend magazine",
    "Statistical analysis performed using R",
    "P-values from Welch's t-test"
  )
)

bp <- table1(
  transmission ~ mpg + hp,
  data = mtcars,
  footnotes = footnotes_general_only,
  theme = "console"
)

cat("CONSOLE OUTPUT (should show NO superscripts in table):\n")
cat("====================================================\n")
output <- display_table(bp, mtcars, theme = "console")
cat(output, "\n\n")

# Test with mixed footnotes (variable + general)
footnotes_mixed <- list(
  variables = list(
    mpg = "Miles per gallon highway rating"
  ),
  general = c(
    "Data from Motor Trend magazine",
    "Statistical analysis performed using R"
  )
)

cat("MIXED FOOTNOTES TEST (only 'mpg' should have superscript ¹):\n")
cat("==========================================================\n")

bp2 <- table1(
  transmission ~ mpg + hp,
  data = mtcars,
  footnotes = footnotes_mixed,
  theme = "console"
)

output2 <- display_table(bp2, mtcars, theme = "console")
cat(output2, "\n")
