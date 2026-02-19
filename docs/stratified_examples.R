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
create_table <- function(formula, data, strata = NULL, ...) {
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
  
  bp <- table1(formula = formula, data = data, strata = strata, ...)
  
  # Get the rendered output
  output <- switch(format_type,
    "html" = render_html(bp, theme),
    "latex" = render_latex(bp, theme),
    render_console(bp, theme)
  )
  
  if (format_type == "html") {
    return(knitr::asis_output(paste(output, collapse = "\n")))
  } else if (format_type == "latex") {
    return(knitr::asis_output(paste(output, collapse = "\n")))
  } else {
    cat(paste(output, collapse = "\n"))
    cat("\n")
  }
}

## ----clinical-data-setup------------------------------------------------------
# Create a realistic multi-center clinical trial dataset
set.seed(42)
n <- 300

clinical_data <- data.frame(
  # Primary treatment variable
  treatment = factor(
    sample(c("Placebo", "Low Dose", "High Dose"), n, replace = TRUE, 
           prob = c(0.4, 0.3, 0.3)),
    levels = c("Placebo", "Low Dose", "High Dose")
  ),
  
  # Potential stratification variables
  site = factor(sample(paste("Site", LETTERS[1:4]), n, replace = TRUE)),
  sex = factor(sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.55, 0.45))),
  age_group = factor(
    sample(c("18-44", "45-64", "65+"), n, replace = TRUE, prob = c(0.3, 0.4, 0.3)),
    levels = c("18-44", "45-64", "65+")
  ),
  disease_severity = factor(
    sample(c("Mild", "Moderate", "Severe"), n, replace = TRUE, prob = c(0.4, 0.4, 0.2)),
    levels = c("Mild", "Moderate", "Severe")
  ),
  
  # Baseline characteristics
  age = round(rnorm(n, 58, 15)),
  bmi = round(rnorm(n, 26.5, 4.2), 1),
  systolic_bp = round(rnorm(n, 135, 18)),
  
  # Comorbidities
  diabetes = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.75, 0.25))),
  hypertension = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.65, 0.35))),
  
  # Lab values
  hemoglobin = round(rnorm(n, 13.2, 1.8), 1),
  creatinine = round(rnorm(n, 1.1, 0.3), 2)
)

# Add some realistic missing values
clinical_data$bmi[sample(1:n, 8)] <- NA
clinical_data$hemoglobin[sample(1:n, 5)] <- NA
clinical_data$creatinine[sample(1:n, 3)] <- NA

# Show dataset structure
str(clinical_data)
head(clinical_data, 10)

## ----site-stratified, results='asis'------------------------------------------
create_table(
  treatment ~ age + sex + bmi + diabetes + systolic_bp,
  data = clinical_data,
  strata = "site",
  theme = "nejm",
  pvalue = TRUE,
  totals = TRUE
)

## ----sex-stratified, results='asis'-------------------------------------------
create_table(
  treatment ~ age + age_group + bmi + diabetes + hypertension + hemoglobin,
  data = clinical_data,
  strata = "sex", 
  theme = "lancet",
  pvalue = TRUE,
  totals = TRUE
)

## ----severity-stratified, results='asis'--------------------------------------
create_table(
  treatment ~ age + sex + bmi + systolic_bp + diabetes + hypertension + creatinine,
  data = clinical_data,
  strata = "disease_severity",
  theme = "jama",
  pvalue = TRUE,
  totals = TRUE
)

## ----age-group-stratified, results='asis'-------------------------------------
create_table(
  treatment ~ sex + bmi + systolic_bp + diabetes + hypertension + hemoglobin + creatinine,
  data = clinical_data,
  strata = "age_group",
  theme = "nejm",
  pvalue = TRUE,
  totals = TRUE
)

## ----missing-data-stratified, results='asis'----------------------------------
create_table(
  treatment ~ age + bmi + hemoglobin + creatinine + diabetes + hypertension,
  data = clinical_data,
  strata = "sex",
  theme = "lancet", 
  missing = TRUE,  # Show missing value patterns
  pvalue = TRUE,
  totals = TRUE
)

## ----site-sex-overview--------------------------------------------------------
# Create a combined stratification variable for demonstration
clinical_data$site_sex <- interaction(clinical_data$site, clinical_data$sex, sep = " - ")

# Show the distribution
table(clinical_data$site_sex, clinical_data$treatment)

## ----site-sex-stratified, results='asis'--------------------------------------
create_table(
  treatment ~ age + bmi + diabetes + systolic_bp,
  data = clinical_data,
  strata = "site_sex",
  theme = "jama",
  pvalue = TRUE
)

## ----overall-analysis, results='asis'-----------------------------------------
create_table(
  treatment ~ age + sex + bmi + diabetes + hypertension + systolic_bp,
  data = clinical_data,
  theme = "console",
  pvalue = TRUE,
  totals = TRUE
)

## ----comparison-stratified, results='asis'------------------------------------
create_table(
  treatment ~ age + sex + bmi + diabetes + hypertension + systolic_bp,
  data = clinical_data,
  strata = "disease_severity",
  theme = "console", 
  pvalue = TRUE,
  totals = TRUE
)

## ----strata-summary, echo=FALSE-----------------------------------------------
strata_vars <- data.frame(
  Variable = c("site", "sex", "age_group", "disease_severity", "diabetes", "hypertension"),
  Description = c(
    "Study site (A, B, C, D)",
    "Participant sex (Male, Female)", 
    "Age groups (18-44, 45-64, 65+)",
    "Disease severity (Mild, Moderate, Severe)",
    "Diabetes status (No, Yes)",
    "Hypertension status (No, Yes)"
  ),
  `Use Case` = c(
    "Multi-center trial balance",
    "Sex-specific effects",
    "Age-related patterns", 
    "Baseline risk stratification",
    "Comorbidity analysis",
    "Cardiovascular risk factors"
  ),
  check.names = FALSE
)

knitr::kable(strata_vars, caption = "Available Stratification Variables")

