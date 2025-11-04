#!/usr/bin/env Rscript

# Test the fixed vignette footnote structures
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

cat("=== TESTING VIGNETTE FOOTNOTE FIXES ===\n\n")

# Test 1: Variable-specific footnotes (like in Simple theme section)
cat("1. VARIABLE-SPECIFIC FOOTNOTES:\n")
analysis_footnotes <- list(
  variables = list(
    mpg = "Miles per gallon measured at highway speeds",
    hp = "Horsepower measured at peak engine performance",
    wt = "Weight includes vehicle and standard equipment"
  ),
  general = "Data from 1974 Motor Trend magazine"
)

bp1 <- table1(
  transmission ~ mpg + hp + wt,
  data = mtcars,
  footnotes = analysis_footnotes,
  theme = "simple"
)

output1 <- display_table(bp1, mtcars, theme = "simple")
cat(output1, "\n\n")

# Test 2: General footnotes (like in NEJM section)  
cat("2. GENERAL FOOTNOTES:\n")
nejm_footnotes <- list(
  general = c(
    "Data from Anderson's iris dataset (1935)",
    "Measurements standardized to nearest 0.1 cm",
    "Statistical significance tested at alpha = 0.05"
  )
)

data(iris)
bp2 <- table1(
  Species ~ Sepal.Length + Sepal.Width,
  data = iris,
  footnotes = nejm_footnotes,
  theme = "nejm"
)

output2 <- display_table(bp2, iris, theme = "nejm")  
cat(output2, "\n\n")

cat("✓ Footnote structures fixed in vignette!\n")
cat("✓ Variable footnotes now use: footnotes = list(variables = list(...))\n")
cat("✓ General footnotes now use: footnotes = list(general = c(...))\n")