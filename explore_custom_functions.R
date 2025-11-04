#!/usr/bin/env Rscript

# Explore custom function generation for numeric summaries
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

cat("=== CUSTOM FUNCTION GENERATION EXPLORATION ===\n\n")

# 1. Basic custom function - mean with range
cat("1. MEAN WITH RANGE:\n")
mean_range <- function(x) {
  if (all(is.na(x))) return("N/A")
  m <- round(mean(x, na.rm = TRUE), 1)
  min_val <- round(min(x, na.rm = TRUE), 1)
  max_val <- round(max(x, na.rm = TRUE), 1)
  paste0(m, " (", min_val, " to ", max_val, ")")
}

bp1 <- table1(transmission ~ mpg + hp, data = mtcars, numeric_summary = mean_range)
cat(display_table(bp1, mtcars, theme = "console"), "\n\n")

# 2. Detailed statistics function
cat("2. DETAILED STATISTICS:\n")
detailed_stats <- function(x) {
  if (all(is.na(x))) return("N/A")
  n <- sum(!is.na(x))
  m <- round(mean(x, na.rm = TRUE), 2)
  s <- round(sd(x, na.rm = TRUE), 2)
  paste0("n=", n, "; ", m, "±", s)
}

bp2 <- table1(transmission ~ mpg + hp, data = mtcars, numeric_summary = detailed_stats)
cat(display_table(bp2, mtcars, theme = "console"), "\n\n")

# 3. Percentile-based summary
cat("3. PERCENTILE SUMMARY:\n")
percentile_summary <- function(x) {
  if (all(is.na(x))) return("N/A")
  p10 <- round(quantile(x, 0.1, na.rm = TRUE), 1)
  p50 <- round(quantile(x, 0.5, na.rm = TRUE), 1)  
  p90 <- round(quantile(x, 0.9, na.rm = TRUE), 1)
  paste0(p50, " (", p10, "-", p90, ")")
}

bp3 <- table1(transmission ~ mpg, data = mtcars, numeric_summary = percentile_summary)
cat(display_table(bp3, mtcars, theme = "console"), "\n\n")

# 4. Scientific notation for large numbers
cat("4. SCIENTIFIC NOTATION:\n")
scientific_summary <- function(x) {
  if (all(is.na(x))) return("N/A")
  m <- mean(x, na.rm = TRUE)
  s <- sd(x, na.rm = TRUE)
  paste0(sprintf("%.2e", m), " (", sprintf("%.2e", s), ")")
}

bp4 <- table1(transmission ~ hp, data = mtcars, numeric_summary = scientific_summary)
cat(display_table(bp4, mtcars, theme = "console"), "\n\n")

# 5. Conditional formatting based on data values
cat("5. CONDITIONAL FORMATTING:\n")
conditional_format <- function(x) {
  if (all(is.na(x))) return("N/A")
  m <- round(mean(x, na.rm = TRUE), 1)
  s <- round(sd(x, na.rm = TRUE), 1)
  
  # Add interpretation based on coefficient of variation
  cv <- s / m
  interpretation <- if (cv < 0.1) {
    " (low variability)"
  } else if (cv > 0.3) {
    " (high variability)" 
  } else {
    " (moderate variability)"
  }
  
  paste0(m, " ± ", s, interpretation)
}

bp5 <- table1(transmission ~ mpg + hp, data = mtcars, numeric_summary = conditional_format)
cat(display_table(bp5, mtcars, theme = "console"), "\n\n")

# 6. Bootstrap confidence interval
cat("6. BOOTSTRAP CONFIDENCE INTERVAL:\n")
bootstrap_ci <- function(x, n_boot = 100) {
  if (all(is.na(x))) return("N/A")
  
  # Simple bootstrap for mean
  valid_x <- x[!is.na(x)]
  if (length(valid_x) < 2) return(paste(round(mean(valid_x), 2), "(insufficient data)"))
  
  boot_means <- replicate(n_boot, {
    sample_x <- sample(valid_x, replace = TRUE)
    mean(sample_x)
  })
  
  m <- round(mean(valid_x), 2)
  ci_lower <- round(quantile(boot_means, 0.025), 2)
  ci_upper <- round(quantile(boot_means, 0.975), 2)
  
  paste0(m, " [", ci_lower, ", ", ci_upper, "]")
}

bp6 <- table1(transmission ~ mpg, data = mtcars, numeric_summary = bootstrap_ci)
cat(display_table(bp6, mtcars, theme = "console"), "\n\n")

# 7. Custom function generator factory
cat("7. FUNCTION GENERATOR FACTORY:\n")

create_custom_summary <- function(primary_stat = "mean", secondary_stat = "sd", 
                                  format = "parentheses", digits = 2) {
  function(x) {
    if (all(is.na(x))) return("N/A")
    
    # Calculate primary statistic
    primary_val <- switch(primary_stat,
      "mean" = mean(x, na.rm = TRUE),
      "median" = median(x, na.rm = TRUE),
      "geometric_mean" = exp(mean(log(x[x > 0]), na.rm = TRUE))
    )
    
    # Calculate secondary statistic  
    secondary_val <- switch(secondary_stat,
      "sd" = sd(x, na.rm = TRUE),
      "iqr" = IQR(x, na.rm = TRUE),
      "mad" = mad(x, na.rm = TRUE),
      "range" = diff(range(x, na.rm = TRUE))
    )
    
    # Format output
    p_rounded <- round(primary_val, digits)
    s_rounded <- round(secondary_val, digits)
    
    switch(format,
      "parentheses" = paste0(p_rounded, " (", s_rounded, ")"),
      "plus_minus" = paste0(p_rounded, " ± ", s_rounded),
      "brackets" = paste0(p_rounded, " [", s_rounded, "]"),
      "colon" = paste0(p_rounded, ": ", s_rounded)
    )
  }
}

# Use the factory to create different summary functions
geometric_mean_mad <- create_custom_summary("geometric_mean", "mad", "brackets", 3)
median_iqr_custom <- create_custom_summary("median", "iqr", "colon", 1)

bp7 <- table1(transmission ~ mpg, data = mtcars, numeric_summary = geometric_mean_mad)
cat("Geometric mean with MAD:\n")
cat(display_table(bp7, mtcars, theme = "console"), "\n")

bp8 <- table1(transmission ~ mpg, data = mtcars, numeric_summary = median_iqr_custom)
cat("Median with IQR (custom format):\n")
cat(display_table(bp8, mtcars, theme = "console"), "\n\n")

cat("KEY INSIGHTS:\n")
cat("=============\n")
cat("• Custom functions receive vector x and must return a character string\n")
cat("• Functions should handle NA values gracefully\n")
cat("• You can include any R calculations: quantiles, bootstrap, transformations\n")
cat("• Function factories allow creating parameterized summary generators\n")
cat("• The same function applies to ALL numeric variables in the table\n")
cat("• Complex statistical methods (bootstrap, robust estimators) are supported\n")