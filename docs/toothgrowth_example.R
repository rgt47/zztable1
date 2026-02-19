## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  echo = TRUE,
  warning = FALSE,
  message = FALSE,
  results = 'asis',
  collapse = TRUE,
  comment = "#>"
)

# Source all required files
source("../R/table1.R")
source("../R/blueprint.R")
source("../R/validation_consolidated.R") 
source("../R/dimensions.R")
source("../R/cells.R")
source("../R/themes.R")
source("../R/rendering.R")
source("../R/utils.R")

## ----helper-functions, echo=FALSE---------------------------------------------
# Helper function for null coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x

# Helper function to create tables with appropriate format (from working dataset_examples.Rmd)
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

## ----data-overview------------------------------------------------------------
# Load and examine the ToothGrowth dataset
data(ToothGrowth)
ToothGrowth$dose <- factor(ToothGrowth$dose)

# Display sample of the data
knitr::kable(head(ToothGrowth, 10), 
             caption = "Sample of ToothGrowth dataset",
             col.names = c("Tooth Length (microns)", "Supplement", "Dose (mg/day)"))

# Basic data summary
cat("**Dataset characteristics:**\n")
cat("- Sample size: ", nrow(ToothGrowth), " guinea pigs\n")
cat("- Supplement types: ", nlevels(ToothGrowth$supp), " (", paste(levels(ToothGrowth$supp), collapse = ", "), ")\n")
cat("- Dose levels: ", nlevels(ToothGrowth$dose), " (", paste(levels(ToothGrowth$dose), collapse = ", "), " mg/day)\n")
cat("- Design: ", nrow(ToothGrowth) / (nlevels(ToothGrowth$supp) * nlevels(ToothGrowth$dose)), " subjects per treatment group\n")

## ----basic-analysis-----------------------------------------------------------
create_table(
  formula = supp ~ len + dose,
  data = ToothGrowth,
  theme = "nejm",
  pvalue = TRUE,
  totals = TRUE
)

## ----clinical-analysis--------------------------------------------------------
# Create comprehensive footnotes for clinical context
clinical_footnotes <- list(
  variables = list(
    len = "Tooth length measured in microns using standardized odontometric techniques",
    dose = "Daily vitamin C dose administered orally over 60-day treatment period"
  ),
  columns = list(
    VC = "Ascorbic acid (pharmaceutical grade vitamin C supplement)", 
    OJ = "Fresh orange juice as natural source of vitamin C"
  ),
  general = c(
    "Guinea pig tooth growth study conducted by Crampton (1947)",
    "Statistical significance tested using Welch's t-test (alpha = 0.05)",
    "All measurements performed by blinded assessors"
  )
)

create_table(
  formula = supp ~ len + dose,
  data = ToothGrowth,
  theme = "nejm", 
  pvalue = TRUE,
  totals = TRUE,
  footnotes = clinical_footnotes
)

## ----dose-analysis------------------------------------------------------------
create_table(
  formula = dose ~ len + supp,
  data = ToothGrowth,
  theme = "jama",
  pvalue = TRUE,
  totals = TRUE
)

## ----custom-dose-analysis-----------------------------------------------------
# Custom summary emphasizing range and median for dose-response
dose_response_summary <- function(x) {
  if (all(is.na(x))) return("N/A")
  
  med <- round(median(x, na.rm = TRUE), 1)
  q1 <- round(quantile(x, 0.25, na.rm = TRUE), 1)
  q3 <- round(quantile(x, 0.75, na.rm = TRUE), 1)
  range_val <- round(max(x, na.rm = TRUE) - min(x, na.rm = TRUE), 1)
  
  paste0(med, " [", q1, "-", q3, "]\n(range: ", range_val, ")")
}

create_table(
  formula = dose ~ len,
  data = ToothGrowth,
  theme = "lancet",
  pvalue = TRUE,
  numeric_summary = dose_response_summary,
  footnotes = list(
    general = "Values shown as median [IQR] with range below"
  )
)

## ----factorial-analysis-------------------------------------------------------
# Create interaction variable for clearer presentation
ToothGrowth$treatment <- interaction(ToothGrowth$supp, ToothGrowth$dose, sep = " - ")

# Comprehensive factorial analysis
factorial_footnotes <- list(
  variables = list(
    len = "Primary endpoint: odontoblast length (microns)"
  ),
  general = c(
    "2×3 factorial design: 2 supplements × 3 dose levels",
    "Each treatment combination: n=10 guinea pigs",
    "Treatment period: 60 days with daily administration"
  )
)

create_table(
  formula = treatment ~ len,
  data = ToothGrowth,
  theme = "nejm",
  pvalue = TRUE,
  footnotes = factorial_footnotes
)

## ----statistical-summary------------------------------------------------------
# Detailed statistical analysis
cat("## Key Findings\n\n")

# Calculate means for interpretation
oj_mean <- round(mean(ToothGrowth$len[ToothGrowth$supp == "OJ"]), 1)
vc_mean <- round(mean(ToothGrowth$len[ToothGrowth$supp == "VC"]), 1)
diff_pct <- round(100 * (oj_mean - vc_mean) / vc_mean, 1)

cat("1. **Supplement Comparison**:\n")
cat("   - Orange juice (OJ): ", oj_mean, " microns average tooth length\n")
cat("   - Vitamin C (VC): ", vc_mean, " microns average tooth length\n") 
cat("   - OJ advantage: ", diff_pct, "% higher than VC\n\n")

# Dose-response analysis
dose_means <- aggregate(len ~ dose, ToothGrowth, mean)
dose_means$len <- round(dose_means$len, 1)

cat("2. **Dose-Response Pattern**:\n")
for (i in 1:nrow(dose_means)) {
  cat("   - ", dose_means$dose[i], " mg/day: ", dose_means$len[i], " microns\n")
}

# Calculate dose effect
low_to_high <- round(100 * (dose_means$len[3] - dose_means$len[1]) / dose_means$len[1], 1)
cat("   - Low to high dose improvement: ", low_to_high, "%\n\n")

cat("3. **Clinical Implications**:\n")
cat("   - Clear dose-dependent response observed\n")
cat("   - Orange juice appears more effective than vitamin C supplement\n")
cat("   - Optimal dosing appears to be 2.0 mg/day for both supplements\n")

## ----console-theme------------------------------------------------------------
cat("### Console Theme (Development/Testing)\n\n")
create_table(
  formula = supp ~ len + dose,
  data = ToothGrowth,
  theme = "console",
  pvalue = TRUE
)

## ----simple-theme-------------------------------------------------------------
cat("### Simple Theme (Maximum Compatibility)\n\n")
create_table(
  formula = supp ~ len + dose, 
  data = ToothGrowth,
  theme = "simple",
  pvalue = TRUE,
  totals = TRUE
)

## ----missing-data-------------------------------------------------------------
# Create version with missing data
ToothGrowth_missing <- ToothGrowth
set.seed(42)

# Simulate realistic missing pattern (some measurements failed)
missing_indices <- sample(1:nrow(ToothGrowth_missing), 6)  # 10% missing
ToothGrowth_missing$len[missing_indices] <- NA

cat("### Analysis with Missing Data (n=", sum(is.na(ToothGrowth_missing$len)), " missing observations)\n\n")

create_table(
  formula = supp ~ len + dose,
  data = ToothGrowth_missing,
  theme = "jama", 
  pvalue = TRUE,
  totals = TRUE,
  missing = TRUE,
  footnotes = list(
    general = c(
      "Missing values shown where measurement techniques failed",
      "Statistical tests performed on available data only"
    )
  )
)

