#!/usr/bin/env Rscript

# Test custom statistical test parameters
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

# Create demo data
set.seed(123)
demo_data <- data.frame(
  treatment = factor(rep(c("Control", "Drug A", "Drug B"), each = 25)),
  blood_pressure = c(
    rnorm(25, mean = 140, sd = 10),    # Control: high BP
    rnorm(25, mean = 120, sd = 8),     # Drug A: lower BP  
    rnorm(25, mean = 115, sd = 12)     # Drug B: lowest BP
  ),
  response = factor(c(
    sample(c("Yes", "No"), 25, replace = TRUE, prob = c(0.2, 0.8)),  # Control: 20% response
    sample(c("Yes", "No"), 25, replace = TRUE, prob = c(0.6, 0.4)),  # Drug A: 60% response  
    sample(c("Yes", "No"), 25, replace = TRUE, prob = c(0.8, 0.2))   # Drug B: 80% response
  ))
)

cat("=== TESTING CUSTOM STATISTICAL TEST PARAMETERS ===\n\n")

cat("1. DEFAULT TESTS (ttest + fisher):\n")
cat("===================================\n")
bp_default <- table1(
  treatment ~ blood_pressure + response,
  data = demo_data,
  pvalue = TRUE,
  theme = "console"
)
output1 <- display_table(bp_default, demo_data, theme = "console")
cat(output1, "\n\n")

cat("2. ANOVA + CHI-SQUARE:\n")
cat("======================\n")
bp_anova_chisq <- table1(
  treatment ~ blood_pressure + response,
  data = demo_data,
  pvalue = TRUE,
  continuous_test = "anova",
  categorical_test = "chisq",
  theme = "console"
)
output2 <- display_table(bp_anova_chisq, demo_data, theme = "console")
cat(output2, "\n\n")

cat("3. KRUSKAL-WALLIS (non-parametric) + FISHER:\n")
cat("============================================\n")
bp_kruskal <- table1(
  treatment ~ blood_pressure + response,
  data = demo_data,
  pvalue = TRUE,
  continuous_test = "kruskal",
  categorical_test = "fisher",
  theme = "console"
)
output3 <- display_table(bp_kruskal, demo_data, theme = "console")
cat(output3, "\n\n")

# Test two-group comparison with Welch's t-test
two_group_data <- demo_data[demo_data$treatment %in% c("Control", "Drug A"), ]
two_group_data$treatment <- factor(two_group_data$treatment)

cat("4. WELCH'S T-TEST (two groups, unequal variances):\n")
cat("===================================================\n")
bp_welch <- table1(
  treatment ~ blood_pressure,
  data = two_group_data,
  pvalue = TRUE,
  continuous_test = "welch",
  theme = "console"
)
output4 <- display_table(bp_welch, two_group_data, theme = "console")
cat(output4, "\n")
