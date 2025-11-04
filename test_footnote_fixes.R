#!/usr/bin/env Rscript

# Test footnote fixes: no duplication + superscript format
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

cat("=== TESTING FOOTNOTE FIXES ===\n\n")

# Test with variable footnotes
footnotes_test <- list(
  variables = list(
    mpg = "Miles per gallon highway rating",
    hp = "Gross horsepower at peak performance"
  ),
  general = "Data from Motor Trend magazine"
)

bp <- table1(
  transmission ~ mpg + hp,
  data = mtcars,
  footnotes = footnotes_test,
  theme = "console"
)

cat("CONSOLE OUTPUT (should show superscripts ¹² and footnotes only below):\n")
cat("====================================================================\n")
output <- display_table(bp, mtcars, theme = "console")
cat(output, "\n\n")

# Test with HTML format
cat("HTML OUTPUT (should show <sup> tags):\n")
cat("=====================================\n") 
html_output <- render_html(bp, get_theme("console"))
cat(html_output, "\n\n")

# Test with LaTeX format  
cat("LaTeX OUTPUT (should show $^{n}$ format):\n")
cat("==========================================\n")
latex_output <- render_latex(bp, get_theme("console"))
cat(latex_output)