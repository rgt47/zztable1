#!/usr/bin/env Rscript

# Advanced custom function generation patterns
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

cat("=== ADVANCED CUSTOM FUNCTION PATTERNS ===\n\n")

# 1. Variable-specific custom functions using closures
cat("1. VARIABLE-AWARE CUSTOM FUNCTIONS:\n")
create_variable_aware_summary <- function() {
  # This uses R's lexical scoping to access the variable name during evaluation
  function(x) {
    if (all(is.na(x))) return("N/A")
    
    # Get the variable name from the calling environment
    var_name <- deparse(substitute(x))
    
    m <- round(mean(x, na.rm = TRUE), 2)
    s <- round(sd(x, na.rm = TRUE), 2)
    n <- sum(!is.na(x))
    
    # Customize format based on variable characteristics
    if (m > 100) {
      # For large values (like HP), use scientific notation
      paste0(sprintf("%.1e", m), " (±", sprintf("%.1e", s), ", n=", n, ")")
    } else {
      # For smaller values (like MPG), use regular notation
      paste0(m, " ± ", s, " (n=", n, ")")
    }
  }
}

bp1 <- table1(transmission ~ mpg + hp, data = mtcars, numeric_summary = create_variable_aware_summary())
cat(display_table(bp1, mtcars, theme = "console"), "\n\n")

# 2. Bayesian credible intervals
cat("2. BAYESIAN CREDIBLE INTERVALS:\n")
bayesian_summary <- function(x, prior_mean = 0, prior_precision = 0.001) {
  if (all(is.na(x))) return("N/A")
  
  valid_x <- x[!is.na(x)]
  n <- length(valid_x)
  
  if (n == 0) return("N/A")
  if (n == 1) return(paste(round(valid_x[1], 2), "(single observation)"))
  
  # Simple conjugate normal-normal Bayesian update
  sample_mean <- mean(valid_x)
  sample_var <- var(valid_x)
  
  # Posterior parameters (assuming known variance for simplicity)
  posterior_precision <- prior_precision + n / sample_var
  posterior_mean <- (prior_precision * prior_mean + n * sample_mean / sample_var) / posterior_precision
  posterior_var <- 1 / posterior_precision
  
  # 95% credible interval
  ci_lower <- round(posterior_mean - 1.96 * sqrt(posterior_var), 2)
  ci_upper <- round(posterior_mean + 1.96 * sqrt(posterior_var), 2)
  
  paste0(round(posterior_mean, 2), " [", ci_lower, ", ", ci_upper, "] (Bayesian)")
}

bp2 <- table1(transmission ~ mpg, data = mtcars, numeric_summary = bayesian_summary)
cat(display_table(bp2, mtcars, theme = "console"), "\n\n")

# 3. Robust statistics with outlier detection
cat("3. ROBUST STATISTICS WITH OUTLIER DETECTION:\n")
robust_summary <- function(x) {
  if (all(is.na(x))) return("N/A")
  
  valid_x <- x[!is.na(x)]
  n <- length(valid_x)
  
  if (n < 3) return(paste(round(mean(valid_x), 2), "(insufficient data)"))
  
  # Detect outliers using IQR method
  Q1 <- quantile(valid_x, 0.25)
  Q3 <- quantile(valid_x, 0.75)
  IQR <- Q3 - Q1
  outlier_bounds <- c(Q1 - 1.5 * IQR, Q3 + 1.5 * IQR)
  outliers <- sum(valid_x < outlier_bounds[1] | valid_x > outlier_bounds[2])
  
  # Use robust statistics
  med <- round(median(valid_x), 2)
  mad <- round(mad(valid_x), 2)
  
  if (outliers > 0) {
    paste0(med, " ± ", mad, " (", outliers, " outlier", if(outliers > 1) "s" else "", ")")
  } else {
    paste0(med, " ± ", mad, " (robust)")
  }
}

bp3 <- table1(transmission ~ mpg + hp, data = mtcars, numeric_summary = robust_summary)
cat(display_table(bp3, mtcars, theme = "console"), "\n\n")

# 4. Distribution shape indicators
cat("4. DISTRIBUTION SHAPE INDICATORS:\n")
shape_summary <- function(x) {
  if (all(is.na(x))) return("N/A")
  
  valid_x <- x[!is.na(x)]
  if (length(valid_x) < 4) return(paste(round(mean(valid_x), 2), "(insufficient data)"))
  
  # Basic statistics
  m <- round(mean(valid_x), 2)
  s <- round(sd(valid_x), 2)
  
  # Shape indicators
  skewness <- mean(((valid_x - m) / s)^3)
  kurtosis <- mean(((valid_x - m) / s)^4) - 3
  
  # Shape interpretation
  shape_desc <- ""
  if (abs(skewness) > 0.5) {
    shape_desc <- if (skewness > 0) " (right-skewed)" else " (left-skewed)"
  }
  if (abs(kurtosis) > 0.5) {
    shape_desc <- paste0(shape_desc, if (kurtosis > 0) " (heavy-tailed)" else " (light-tailed)")
  }
  if (shape_desc == "") shape_desc <- " (symmetric)"
  
  paste0(m, " ± ", s, shape_desc)
}

bp4 <- table1(transmission ~ mpg + hp, data = mtcars, numeric_summary = shape_summary)
cat(display_table(bp4, mtcars, theme = "console"), "\n\n")

# 5. Effect size calculations
cat("5. EFFECT SIZE CALCULATIONS:\n")
create_effect_size_summary <- function(reference_group = "Automatic") {
  function(x) {
    if (all(is.na(x))) return("N/A")
    
    # This is a simplified example - in reality, you'd need group information
    # For demonstration, we'll calculate basic statistics with effect size context
    m <- round(mean(x, na.rm = TRUE), 2)
    s <- round(sd(x, na.rm = TRUE), 2)
    
    # Calculate coefficient of variation as a standardized measure
    cv <- round(s / m * 100, 1)
    
    paste0(m, " ± ", s, " (CV=", cv, "%)")
  }
}

bp5 <- table1(transmission ~ mpg + hp, data = mtcars, numeric_summary = create_effect_size_summary())
cat(display_table(bp5, mtcars, theme = "console"), "\n\n")

# 6. Multi-level summary with progressive detail
cat("6. PROGRESSIVE DETAIL SUMMARY:\n")
progressive_summary <- function(x, detail_level = "medium") {
  if (all(is.na(x))) return("N/A")
  
  valid_x <- x[!is.na(x)]
  n <- length(valid_x)
  
  # Always include basic stats
  m <- round(mean(valid_x), 2)
  s <- round(sd(valid_x), 2)
  
  switch(detail_level,
    "minimal" = paste0(m, " (", s, ")"),
    "medium" = {
      med <- round(median(valid_x), 2)
      paste0(m, " ± ", s, "; median=", med)
    },
    "full" = {
      med <- round(median(valid_x), 2)
      q1 <- round(quantile(valid_x, 0.25), 2)
      q3 <- round(quantile(valid_x, 0.75), 2)
      paste0(m, "±", s, " [", q1, ",", med, ",", q3, "] n=", n)
    }
  )
}

# Create different detail levels
minimal_summary <- function(x) progressive_summary(x, "minimal")
full_summary <- function(x) progressive_summary(x, "full")

bp6 <- table1(transmission ~ mpg, data = mtcars, numeric_summary = minimal_summary)
cat("Minimal detail:\n")
cat(display_table(bp6, mtcars, theme = "console"), "\n")

bp7 <- table1(transmission ~ mpg, data = mtcars, numeric_summary = full_summary)
cat("Full detail:\n")
cat(display_table(bp7, mtcars, theme = "console"), "\n\n")

cat("ADVANCED PATTERNS SUMMARY:\n")
cat("==========================\n")
cat("• Variable-aware functions can adapt based on data characteristics\n")
cat("• Bayesian methods provide credible intervals with prior information\n")
cat("• Robust statistics handle outliers and non-normal distributions\n")
cat("• Distribution shape can be automatically detected and reported\n")
cat("• Progressive detail allows different levels of statistical reporting\n")
cat("• Custom functions can implement sophisticated statistical methods\n")
cat("• Closures and function factories enable parameterized generation\n")