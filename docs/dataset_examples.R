## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE,
  message = FALSE,
  results = 'asis',
  fig.width = 8,
  fig.height = 6
)

# Load required libraries
library(htmltools)
library(kableExtra)

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
# Only generate CSS for HTML output
if (knitr::is_html_output()) {
  # Generate and inject CSS for theme styling
  theme_css <- generate_theme_css()
  cat("<style>\n")
  cat(theme_css)
  cat("\n")
  # Add additional styling for better presentation
  cat("
.theme-showcase {
  margin: 20px 0;
  padding: 15px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  background-color: #fafafa;
}
.theme-title {
  font-size: 16px;
  font-weight: bold;
  color: #2c3e50;
  margin-bottom: 10px;
}
.theme-description {
  font-size: 14px;
  color: #7f8c8d;
  margin-bottom: 15px;
}
.dataset-section {
  margin-top: 30px;
  border-top: 2px solid #3498db;
  padding-top: 20px;
}
")
  cat("\n</style>")
}

## ----helper-functions, include=FALSE------------------------------------------
# Helper function for null coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x

# Helper function to create tables with appropriate format
create_table <- function(formula, data, ...) {
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
  
  # Detect output format and render appropriately
  if (knitr::is_latex_output()) {
    output <- render_latex(bp, theme)
  } else if (knitr::is_html_output()) {
    output <- render_html(bp, theme)
  } else {
    # Default to console for unknown formats
    output <- render_console(bp, theme)
  }
  
  return(knitr::asis_output(paste(output, collapse = "\n")))
}

## ----theme-list, echo=FALSE---------------------------------------------------
available_themes <- list_available_themes()
theme_details <- data.frame(
  Theme = available_themes,
  Description = c(
    "Console - Basic monospace output for development",
    "NEJM - New England Journal of Medicine styling with authentic cream striping",
    "Lancet - Clean minimal formatting matching The Lancet",
    "JAMA - Journal of American Medical Association styling",
    "BMJ - British Medical Journal styling",
    "Simple - Clean general-purpose theme for reports"
  ),
  stringsAsFactors = FALSE
)

knitr::kable(theme_details, 
             caption = "Available Themes in zztable1",
             escape = FALSE, 
             format = if(knitr::is_latex_output()) "latex" else "html") %>%
  kableExtra::kable_styling()

## ----mtcars-prep--------------------------------------------------------------
# Prepare mtcars with meaningful factor variables
data(mtcars)
mtcars$transmission <- factor(
  ifelse(mtcars$am == 1, "Manual", "Automatic"),
  levels = c("Automatic", "Manual")
)
mtcars$engine_shape <- factor(
  ifelse(mtcars$vs == 1, "V-shaped", "Straight"),
  levels = c("Straight", "V-shaped")
)
mtcars$cylinders <- factor(mtcars$cyl)

# Show sample data
knitr::kable(head(mtcars[, c("mpg", "hp", "wt", "transmission", "engine_shape", "cylinders")]), 
             caption = "Sample of prepared mtcars data") %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
                           full_width = FALSE)

## ----theme-console-demo-------------------------------------------------------
create_table(
  formula = transmission ~ mpg + hp + wt + cylinders,
  data = mtcars,
  pvalue = FALSE,
  totals = FALSE,
  missing = FALSE,
  theme = "console"
)

## ----theme-nejm-demo----------------------------------------------------------
# Add some missing values for demonstration
mtcars_missing <- mtcars
mtcars_missing$mpg[c(1,5,10)] <- NA
mtcars_missing$hp[c(3,7,15)] <- NA

create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars_missing,
  strata = "engine_shape",
  pvalue = TRUE,
  totals = TRUE,
  missing = TRUE,
  theme = "nejm"
)

## ----theme-lancet-demo--------------------------------------------------------
create_table(
  formula = transmission ~ mpg + hp + wt + engine_shape,
  data = mtcars,
  strata = "cylinders",
  pvalue = TRUE,
  totals = TRUE,
  missing = FALSE,
  theme = "lancet"
)

## ----theme-jama-demo----------------------------------------------------------
create_table(
  formula = transmission ~ mpg + hp + wt + cylinders,
  data = mtcars_missing,
  pvalue = TRUE,
  totals = TRUE,
  missing = TRUE,
  theme = "jama"
)

## ----theme-simple-demo--------------------------------------------------------
# Create footnotes for the analysis (using proper structure)
analysis_footnotes <- list(
  variables = list(
    mpg = "Miles per gallon measured at highway speeds",
    hp = "Horsepower measured at peak engine performance",
    wt = "Weight includes vehicle and standard equipment"
  ),
  general = "Data from 1974 Motor Trend magazine"
)

create_table(
  formula = transmission ~ mpg + hp + wt + cylinders,
  data = mtcars,
  pvalue = FALSE,
  totals = TRUE,
  missing = FALSE,
  footnotes = analysis_footnotes,
  theme = "simple"
)

## ----iris-prep----------------------------------------------------------------
data(iris)
knitr::kable(head(iris[, c("Species", "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")]), 
             caption = "Sample of iris data - Species comparison") %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
                           full_width = FALSE)

## ----iris-nejm----------------------------------------------------------------
# Demonstrate footnotes with NEJM theme (uses numbered footnotes)
nejm_footnotes <- list(
  general = c(
    "Data from Anderson's iris dataset (1935)",
    "Measurements standardized to nearest 0.1 cm",
    "Statistical significance tested at alpha = 0.05"
  )
)

create_table(
  formula = Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
  data = iris,
  pvalue = TRUE,
  totals = TRUE,
  footnotes = nejm_footnotes,
  theme = "nejm"
)

## ----iris-jama----------------------------------------------------------------
# Demonstrate footnotes with JAMA theme (uses lettered footnotes)
iris_footnotes <- list(
  general = c(
    "Measurements taken from dried specimens",
    "All measurements in centimeters", 
    "P-values from one-way ANOVA across species"
  )
)

create_table(
  formula = Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
  data = iris,
  pvalue = TRUE,
  totals = TRUE,
  footnotes = iris_footnotes,
  theme = "jama"
)

## ----sleep-prep---------------------------------------------------------------
data(sleep)
sleep$group <- factor(sleep$group, labels = c("Drug 1", "Drug 2"))

# Add simulated baseline characteristics for better demonstration
set.seed(456)
sleep$age <- round(rnorm(nrow(sleep), 25, 3))
sleep$sex <- factor(sample(c("Male", "Female"), nrow(sleep), replace = TRUE))

knitr::kable(head(sleep), caption = "Sleep study data with simulated demographics") %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
                           full_width = FALSE)

## ----sleep-lancet-------------------------------------------------------------
create_table(
  formula = group ~ extra + age + sex,
  data = sleep,
  pvalue = TRUE,
  totals = TRUE,
  theme = "lancet"
)

## ----sleep-simple-------------------------------------------------------------
create_table(
  formula = group ~ extra + age + sex,
  data = sleep,
  pvalue = TRUE,
  totals = TRUE,
  theme = "simple"
)

## ----plantgrowth--------------------------------------------------------------
data(PlantGrowth)
knitr::kable(head(PlantGrowth), caption = "Sample of PlantGrowth data")

# Simple treatment comparison
create_table(
  formula = group ~ weight,
  data = PlantGrowth,
  pvalue = TRUE,
  totals = TRUE,
  theme = "console"
)

## ----toothgrowth--------------------------------------------------------------
data(ToothGrowth)
ToothGrowth$dose <- factor(ToothGrowth$dose)
knitr::kable(head(ToothGrowth), caption = "Sample of ToothGrowth data")

# Demonstrate footnotes with clinical research context
clinical_footnotes <- list(
  variables = list(
    supp = "VC = Vitamin C supplement (ascorbic acid); OJ = Orange juice as natural vitamin C source",
    len = "Tooth length measured in microns",
    dose = "Dose levels: 0.5, 1.0, and 2.0 mg/day"
  ),
  general = "Guinea pig tooth growth study (Crampton, 1947)"
)

# Compare by supplement type with footnotes
create_table(
  formula = supp ~ len + dose,
  data = ToothGrowth,
  pvalue = TRUE,
  totals = TRUE,
  footnotes = clinical_footnotes,
  theme = "jama"
)

## ----toothgrowth-dose---------------------------------------------------------
# Analysis with dose as grouping variable
create_table(
  formula = dose ~ len,
  data = ToothGrowth,
  pvalue = TRUE,
  theme = "lancet"
)

## ----chickwts-----------------------------------------------------------------
data(chickwts)
knitr::kable(head(chickwts), caption = "Sample of chickwts data")

create_table(
  formula = feed ~ weight,
  data = chickwts,
  pvalue = TRUE,
  totals = TRUE,
  theme = "console"
)

## ----airquality---------------------------------------------------------------
data(airquality)
airquality$Month <- factor(
  month.name[airquality$Month],
  levels = month.name[5:9]  # May through September
)
knitr::kable(head(airquality), caption = "Sample of airquality data")

# Show how missing values are handled
create_table(
  formula = Month ~ Ozone + Solar.R + Wind + Temp,
  data = airquality,
  pvalue = TRUE,
  totals = TRUE,
  theme = "nejm"
)

## ----theme-console------------------------------------------------------------
create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars,
  pvalue = TRUE,
  totals = TRUE,
  theme = "console"
)

## ----theme-nejm---------------------------------------------------------------
create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars,
  pvalue = TRUE,
  totals = TRUE,
  theme = "nejm"
)

## ----theme-lancet-------------------------------------------------------------
create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars,
  pvalue = TRUE,
  totals = TRUE,
  theme = "lancet"
)

## ----theme-jama---------------------------------------------------------------
create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars,
  pvalue = TRUE,
  totals = TRUE,
  theme = "jama"
)

## ----performance-demo---------------------------------------------------------
# Demonstrate with larger simulated dataset
set.seed(789)
large_data <- data.frame(
  treatment = factor(sample(c("Placebo", "Drug A", "Drug B"), 1000, replace = TRUE)),
  age = round(rnorm(1000, 65, 15)),
  sex = factor(sample(c("Male", "Female"), 1000, replace = TRUE)),
  weight = round(rnorm(1000, 70, 15), 1),
  height = round(rnorm(1000, 170, 10), 1),
  center = factor(sample(paste("Center", 1:5), 1000, replace = TRUE))
)

# Time the table creation  
system.time({
  create_table(
    formula = treatment ~ age + sex + weight + height,
    data = large_data,
    pvalue = TRUE,
    totals = TRUE,
    theme = "nejm"
  )
})

## ----available-themes---------------------------------------------------------
available_themes <- list_available_themes()
print(available_themes)

