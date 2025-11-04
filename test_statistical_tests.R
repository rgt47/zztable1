#!/usr/bin/env Rscript

# Test different statistical tests for p-values
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

# Create data with different types of variables
data(ToothGrowth)
ToothGrowth$dose <- factor(ToothGrowth$dose)

# Create a dataset with clearer group differences  
set.seed(123)
test_data <- data.frame(
  group = factor(rep(c("A", "B", "C"), each = 20)),
  continuous_var = c(rnorm(20, 10, 2), rnorm(20, 15, 2), rnorm(20, 12, 2)),
  binary_var = factor(c(rep("Yes", 15), rep("No", 5), 
                       rep("Yes", 10), rep("No", 10),
                       rep("Yes", 12), rep("No", 8)))
)

cat("=== TESTING CURRENT DEFAULT BEHAVIOR ===\n")
bp_default <- table1(
  group ~ continuous_var + binary_var,
  data = test_data,
  pvalue = TRUE,
  theme = "console"
)

cat("DEFAULT P-VALUES:\n")
output <- display_table(bp_default, test_data, theme = "console")
cat(output, "\n\n")

cat("=== CHECKING AVAILABLE TEST OPTIONS ===\n")
cat("From code analysis, available test types:\n")
cat("- 'fisher': Fisher's exact test for categorical\n")
cat("- 'ttest': t-test for continuous (default)\n")
cat("- 'anova': ANOVA for continuous with multiple groups\n\n")

# Let's check if themes specify different tests
cat("=== CHECKING THEME-BASED TEST SPECIFICATIONS ===\n")
console_theme <- get_theme("console")
nejm_theme <- get_theme("nejm")

if ("statistical_tests" %in% names(console_theme)) {
  cat("Console theme tests:", paste(names(console_theme$statistical_tests), "=", console_theme$statistical_tests, collapse = ", "), "\n")
} else {
  cat("Console theme: No statistical_tests specified\n")
}

if ("statistical_tests" %in% names(nejm_theme)) {
  cat("NEJM theme tests:", paste(names(nejm_theme$statistical_tests), "=", nejm_theme$statistical_tests, collapse = ", "), "\n")
} else {
  cat("NEJM theme: No statistical_tests specified\n")
}
