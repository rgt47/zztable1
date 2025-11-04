#!/usr/bin/env Rscript

# Test LaTeX threeparttable output
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

# Create test data
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))

# Create table with footnotes
bp <- table1(
  transmission ~ mpg + hp,
  data = mtcars,
  theme = "nejm",
  footnotes = list(
    variables = list(
      mpg = "Miles per gallon EPA highway rating",
      hp = "Gross horsepower"
    ),
    general = "Data from 1974 Motor Trend magazine"
  )
)

# Generate LaTeX output
cat("LaTeX output with threeparttable:\n")
cat("=====================================\n")
latex_output <- render_latex(bp, get_theme("nejm"))

# Display the LaTeX code to verify threeparttable structure
cat(latex_output, sep = "\n")