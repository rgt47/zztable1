#!/usr/bin/env Rscript

# Test with more subtle differences to see test variations
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

# Create data with smaller differences
set.seed(456)  
subtle_data <- data.frame(
  group = factor(rep(c("A", "B", "C"), each = 20)),
  measurement = c(
    rnorm(20, mean = 100, sd = 15),    # Group A
    rnorm(20, mean = 105, sd = 18),    # Group B: slightly higher
    rnorm(20, mean = 108, sd = 12)     # Group C: highest
  ),
  outcome = factor(c(
    sample(c("Success", "Failure"), 20, replace = TRUE, prob = c(0.4, 0.6)),  # Group A: 40% success
    sample(c("Success", "Failure"), 20, replace = TRUE, prob = c(0.5, 0.5)),  # Group B: 50% success  
    sample(c("Success", "Failure"), 20, replace = TRUE, prob = c(0.6, 0.4))   # Group C: 60% success
  ))
)

cat("=== COMPARING STATISTICAL TESTS WITH SUBTLE DIFFERENCES ===\n\n")

cat("1. DEFAULT (ttest + fisher):\n")
bp1 <- table1(group ~ measurement + outcome, data = subtle_data, pvalue = TRUE)
cat(display_table(bp1, subtle_data), "\n\n")

cat("2. ANOVA + CHI-SQUARE:\n")  
bp2 <- table1(group ~ measurement + outcome, data = subtle_data, pvalue = TRUE,
              continuous_test = "anova", categorical_test = "chisq")
cat(display_table(bp2, subtle_data), "\n\n")

cat("3. KRUSKAL-WALLIS (non-parametric):\n")
bp3 <- table1(group ~ measurement, data = subtle_data, pvalue = TRUE,
              continuous_test = "kruskal")
cat(display_table(bp3, subtle_data), "\n\n")

cat("MANUAL VERIFICATION OF P-VALUES:\n")
cat("================================\n")
# Manual calculation to verify
aov_result <- aov(measurement ~ group, data = subtle_data)
lm_result <- lm(measurement ~ group, data = subtle_data)
kw_result <- kruskal.test(measurement ~ group, data = subtle_data)

cat("ANOVA p-value:     ", round(summary(aov_result)[[1]]["group", "Pr(>F)"], 4), "\n")
cat("Linear model p-value:", round(summary(lm_result)$coefficients[2, 4], 4), "\n")
cat("Kruskal-Wallis p-value:", round(kw_result$p.value, 4), "\n\n")

# Categorical test comparison
cont_table <- table(subtle_data$group, subtle_data$outcome)
fisher_p <- fisher.test(cont_table)$p.value
chisq_p <- chisq.test(cont_table)$p.value

cat("Fisher's exact p-value:", round(fisher_p, 4), "\n")
cat("Chi-square p-value:    ", round(chisq_p, 4), "\n")
