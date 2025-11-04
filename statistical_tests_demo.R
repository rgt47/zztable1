#!/usr/bin/env Rscript

# Comprehensive demonstration of statistical test options
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

cat("=== STATISTICAL TESTS IN ZZTABLE1_NEXTGEN ===\n\n")

# Create demo data with clear differences
set.seed(123)
demo_data <- data.frame(
  treatment = factor(rep(c("Control", "Drug A", "Drug B"), each = 25)),
  
  # Continuous variable with clear differences
  blood_pressure = c(
    rnorm(25, mean = 140, sd = 10),    # Control: high BP
    rnorm(25, mean = 120, sd = 8),     # Drug A: lower BP  
    rnorm(25, mean = 115, sd = 12)     # Drug B: lowest BP
  ),
  
  # Binary outcome with different response rates
  response = factor(c(
    sample(c("Yes", "No"), 25, replace = TRUE, prob = c(0.2, 0.8)),  # Control: 20% response
    sample(c("Yes", "No"), 25, replace = TRUE, prob = c(0.6, 0.4)),  # Drug A: 60% response  
    sample(c("Yes", "No"), 25, replace = TRUE, prob = c(0.8, 0.2))   # Drug B: 80% response
  ))
)

cat("CURRENT DEFAULT STATISTICAL TESTS:\n")
cat("==================================\n")
bp_default <- table1(
  treatment ~ blood_pressure + response,
  data = demo_data,
  pvalue = TRUE,
  theme = "console"
)

output <- display_table(bp_default, demo_data, theme = "console")
cat(output, "\n\n")

cat("EXPLANATION OF CURRENT TESTS:\n")
cat("=============================\n")
cat("• Continuous variables (blood_pressure): Uses linear model t-test\n")
cat("  - Equivalent to ANOVA for multiple groups\n") 
cat("  - Tests: H0: no difference in means between groups\n")
cat("  - P-value from: summary(lm(y ~ group))$coefficients[2,4]\n\n")

cat("• Categorical variables (response): Uses Fisher's exact test\n")
cat("  - Exact test for small sample sizes\n")
cat("  - Tests: H0: no association between treatment and response\n") 
cat("  - P-value from: fisher.test(table(x, y))$p.value\n\n")

cat("AVAILABLE TEST TYPES IN CODEBASE:\n")
cat("==================================\n")
cat("1. 'ttest' - Linear model t-test (default for continuous)\n")
cat("2. 'anova' - ANOVA F-test (alternative for continuous with >2 groups)\n")
cat("3. 'fisher' - Fisher's exact test (default for categorical)\n\n")

cat("COMPARING DIFFERENT TESTS FOR CONTINUOUS VARIABLES:\n")
cat("===================================================\n")

# Manual calculation to show different test approaches
cat("Manual test calculations for blood_pressure:\n\n")

# ANOVA approach
aov_result <- aov(blood_pressure ~ treatment, data = demo_data)
anova_p <- summary(aov_result)[[1]]["treatment", "Pr(>F)"]
cat("ANOVA F-test p-value:", round(anova_p, 6), "\n")

# Linear model approach (what package uses)
lm_result <- lm(blood_pressure ~ treatment, data = demo_data)
lm_p <- summary(lm_result)$coefficients[2, 4]  # First contrast p-value
cat("Linear model p-value:", round(lm_p, 6), "\n")

# Welch's t-test (if only 2 groups)
if (length(unique(demo_data$treatment)) == 2) {
  t_test <- t.test(blood_pressure ~ treatment, data = demo_data)
  cat("Welch's t-test p-value:", round(t_test$p.value, 6), "\n")
}

cat("\nFor categorical variables (response):\n")
contingency_table <- table(demo_data$treatment, demo_data$response)
print(contingency_table)
fisher_result <- fisher.test(contingency_table)
cat("Fisher's exact test p-value:", round(fisher_result$p.value, 6), "\n")

# Alternative: Chi-square test
chisq_result <- chisq.test(contingency_table)
cat("Chi-square test p-value:", round(chisq_result$p.value, 6), "\n")
