## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE,
  message = FALSE,
  results = 'asis'
)

# Load required libraries
library(htmltools)

# Source all required files
source("../R/table1.R")
source("../R/blueprint.R")
source("../R/validation_consolidated.R") 
source("../R/dimensions.R")
source("../R/cells.R")
source("../R/themes.R")
source("../R/rendering.R")
source("../R/utils.R")

## ----theme-css, results='asis', echo=FALSE------------------------------------
# Generate and inject CSS for theme styling
theme_css <- generate_theme_css()
cat("<style>\n")
cat(theme_css)
cat("\n</style>")

## ----helper-functions, include=FALSE------------------------------------------
# Helper function for null coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x

# Helper function to create tables with appropriate format
create_table <- function(formula, data, ...) {
  # Determine output format
  if (knitr::is_latex_output()) {
    layout <- "latex"
    format_type <- "latex"
  } else {
    layout <- "html"
    format_type <- "html"
  }
  
  # Extract theme from arguments
  args <- list(...)
  theme_arg <- args$theme %||% "console"
  
  # Handle both theme names and custom theme objects
  if (is.character(theme_arg)) {
    theme <- get_theme(theme_arg)
  } else if (is.list(theme_arg)) {
    theme <- theme_arg
  } else {
    theme <- get_theme("console")
  }
  
  bp <- table1(formula = formula, data = data, ...)
  
  # Get the rendered output without cat() printing
  output <- switch(format_type,
    "html" = render_html(bp, theme),
    "latex" = render_latex(bp, theme),
    render_console(bp, theme)
  )
  
  if (format_type == "html") {
    # For HTML output in R Markdown, use knitr::asis_output to properly inject HTML
    return(knitr::asis_output(paste(output, collapse = "\n")))
  } else if (format_type == "latex") {
    # For LaTeX output, use knitr::asis_output for raw LaTeX
    return(knitr::asis_output(paste(output, collapse = "\n")))
  } else {
    # For console output
    cat(paste(output, collapse = "\n"))
    cat("\n")
  }
}

## ----data-setup---------------------------------------------------------------
# Create a realistic clinical trial dataset
set.seed(123)
n <- 200

clinical_data <- data.frame(
  treatment = factor(
    sample(c("Placebo", "Drug A", "Drug B"), n, replace = TRUE, prob = c(0.4, 0.3, 0.3)),
    levels = c("Placebo", "Drug A", "Drug B")
  ),
  age = round(rnorm(n, 65, 12)),
  sex = factor(sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.6, 0.4))),
  bmi = round(rnorm(n, 28, 5), 1),
  diabetes = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.7, 0.3)))
)

# Add some missing values to make it realistic
clinical_data$bmi[sample(1:n, 10)] <- NA

head(clinical_data)

## ----nejm-theme, results='asis'-----------------------------------------------
create_table(
  treatment ~ age + sex + bmi + diabetes,
  data = clinical_data,
  theme = "nejm",
  pvalue = TRUE,
  totals = TRUE
)

## ----lancet-theme, results='asis'---------------------------------------------
create_table(
  treatment ~ age + sex + bmi + diabetes,
  data = clinical_data,
  theme = "lancet",
  pvalue = TRUE,
  totals = TRUE
)

## ----jama-theme, results='asis'-----------------------------------------------
create_table(
  treatment ~ age + sex + bmi + diabetes,
  data = clinical_data,
  theme = "jama",
  pvalue = TRUE,
  totals = TRUE
)

## ----theme-summary, echo=FALSE------------------------------------------------
theme_comparison <- data.frame(
  Theme = c("NEJM", "Lancet", "JAMA"),
  `Continuous Variables` = c("Mean ± SD", "Mean (SD)", "Mean (SD)"),
  `Border Style` = c("Top/Mid/Bottom rules + striping", "Horizontal rules only", "Horizontal rules only"),
  `Font` = c("Arial, sans-serif", "Arial, sans-serif", "Arial, sans-serif"),
  `Decimal Places` = c("1", "1", "1"),
  `Best For` = c(
    "NEJM submissions",
    "Lancet submissions", 
    "JAMA & American journals"
  ),
  check.names = FALSE
)

knitr::kable(theme_comparison, caption = "Theme Comparison Summary")

## ----available-themes---------------------------------------------------------
available_themes <- list_available_themes()
print(available_themes)

