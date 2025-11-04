# ============================================================================
# Comprehensive Edge Case Tests for zztable1_nextgen
# ============================================================================
#
# This file contains challenging edge cases that stress-test the table1 function
# and ensure robust behavior under unusual conditions.

library(testthat)

# Test uses package functions via testthat - no need to source files

# ============================================================================
# Test Data Setup
# ============================================================================

# Create edge case datasets for testing
setup_edge_case_data <- function() {
  list(
    # Single observation data
    single_obs = data.frame(
      group = factor("A"),
      numeric_var = 1.5,
      factor_var = factor("level1"),
      logical_var = TRUE,
      stringsAsFactors = FALSE
    ),
    
    # Two observations data
    two_obs = data.frame(
      group = factor(c("A", "B")),
      numeric_var = c(1.0, 2.0),
      factor_var = factor(c("level1", "level2")),
      logical_var = c(TRUE, FALSE),
      stringsAsFactors = FALSE
    ),
    
    # Extreme missing data
    extreme_missing = {
      df <- mtcars[1:10, ]
      df$group <- factor(rep(c("A", "B"), 5))
      df$all_na <- rep(NA, 10)
      df$mostly_na <- c(rep(NA, 9), 1)
      df$some_na <- c(rep(NA, 5), 1:5)
      df
    },
    
    # Unusual factor levels
    unusual_factors = {
      df <- mtcars[1:20, ]
      df$group <- factor(rep(c("A", "B"), 10))
      df$empty_string <- factor(c(rep("", 10), rep("normal", 10)))
      df$special_chars <- factor(c(rep("level@#$%", 10), rep("level_2", 10)))
      df$numbers_as_factors <- factor(c(rep("123", 10), rep("456", 10)))
      df$very_long_name <- factor(c(rep("This_is_a_very_long_factor_level_name_that_might_cause_formatting_issues", 10), 
                                   rep("short", 10)))
      df
    },
    
    # Numeric extremes
    numeric_extremes = {
      df <- data.frame(
        group = factor(rep(c("A", "B"), 10)),
        zeros = rep(0, 20),
        negative = c(rep(-1e6, 10), rep(-1e-6, 10)),
        large_numbers = c(rep(1e12, 10), rep(1e15, 10)),
        tiny_numbers = c(rep(1e-12, 10), rep(1e-15, 10)),
        mixed_signs = c(-5:4, 1:10),
        stringsAsFactors = FALSE
      )
      # Add some extreme values
      df$infinities <- c(rep(Inf, 5), rep(-Inf, 5), rep(1, 10))
      df$with_nan <- c(rep(NaN, 3), rep(1, 17))
      df
    }
  )
}

# ============================================================================
# Edge Case Tests
# ============================================================================

test_that("Single observation tables work correctly", {
  data_list <- setup_edge_case_data()
  
  # Test with single observation
  expect_s3_class({
    bp <- table1(group ~ numeric_var, data = data_list$single_obs)
    bp
  }, "table1_blueprint")
  
  # Should have minimal rows but valid structure
  bp <- table1(group ~ numeric_var, data = data_list$single_obs)
  expect_true(bp$nrows >= 1)
  expect_true(bp$ncols >= 2)
  
  # Test rendering doesn't crash
  expect_no_error(render_console(bp))
})

test_that("Two observation edge cases", {
  data_list <- setup_edge_case_data()
  
  # Test with exactly two observations (minimal for group comparison)
  bp <- table1(group ~ numeric_var + factor_var, data = data_list$two_obs)
  expect_s3_class(bp, "table1_blueprint")
  
  # Should be able to render
  expect_no_error(render_console(bp))
  expect_no_error(render_html(bp))
})

test_that("Extreme missing data scenarios", {
  data_list <- setup_edge_case_data()
  
  # Test with variable that's completely NA
  expect_warning({
    bp1 <- table1(group ~ all_na, data = data_list$extreme_missing)
  }, "missing")
  expect_s3_class(bp1, "table1_blueprint")
  
  # Test with variable that's 90% NA
  expect_warning({
    bp2 <- table1(group ~ mostly_na, data = data_list$extreme_missing, missing = TRUE)
  }, "missing")
  expect_s3_class(bp2, "table1_blueprint")
  
  # Missing should add extra rows
  bp3_no_missing <- table1(group ~ some_na, data = data_list$extreme_missing, missing = FALSE)
  bp3_with_missing <- table1(group ~ some_na, data = data_list$extreme_missing, missing = TRUE)
  expect_true(bp3_with_missing$nrows > bp3_no_missing$nrows)
})

test_that("Unusual factor level edge cases", {
  data_list <- setup_edge_case_data()
  
  # Test with empty string factor levels
  bp1 <- table1(group ~ empty_string, data = data_list$unusual_factors)
  expect_s3_class(bp1, "table1_blueprint")
  
  # Test with special characters in factor levels
  bp2 <- table1(group ~ special_chars, data = data_list$unusual_factors)
  expect_s3_class(bp2, "table1_blueprint")
  
  # Test with numbers as factor levels
  bp3 <- table1(group ~ numbers_as_factors, data = data_list$unusual_factors)
  expect_s3_class(bp3, "table1_blueprint")
  
  # Test with very long factor level names
  bp4 <- table1(group ~ very_long_name, data = data_list$unusual_factors)
  expect_s3_class(bp4, "table1_blueprint")
  
  # All should render without error
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
  expect_no_error(render_console(bp3))
  expect_no_error(render_console(bp4))
})

test_that("Numeric extreme values are handled correctly", {
  data_list <- setup_edge_case_data()
  
  # Test with zeros
  bp1 <- table1(group ~ zeros, data = data_list$numeric_extremes)
  expect_s3_class(bp1, "table1_blueprint")
  
  # Test with very large numbers
  bp2 <- table1(group ~ large_numbers, data = data_list$numeric_extremes)
  expect_s3_class(bp2, "table1_blueprint")
  
  # Test with very small numbers
  bp3 <- table1(group ~ tiny_numbers, data = data_list$numeric_extremes)
  expect_s3_class(bp3, "table1_blueprint")
  
  # Test with mixed positive/negative
  bp4 <- table1(group ~ mixed_signs, data = data_list$numeric_extremes)
  expect_s3_class(bp4, "table1_blueprint")
  
  # All should render
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
  expect_no_error(render_console(bp3))
  expect_no_error(render_console(bp4))
})

test_that("Infinite and NaN values are handled gracefully", {
  data_list <- setup_edge_case_data()
  
  # Test with infinite values
  bp1 <- table1(group ~ infinities, data = data_list$numeric_extremes)
  expect_s3_class(bp1, "table1_blueprint")
  
  # Test with NaN values
  bp2 <- table1(group ~ with_nan, data = data_list$numeric_extremes)
  expect_s3_class(bp2, "table1_blueprint")
  
  # Should render without crashing
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
})

test_that("Complex formula edge cases", {
  # Test with many variables
  many_vars_data <- mtcars
  many_vars_data$group <- factor(rep(c("A", "B"), 16))
  
  bp1 <- table1(group ~ mpg + cyl + disp + hp + drat + wt, data = many_vars_data)
  expect_s3_class(bp1, "table1_blueprint")
  expect_true(bp1$nrows > 6)  # Should have multiple rows for multiple variables
  
  # Test with interaction-like variable names (though not actual interactions)
  interaction_data <- data.frame(
    group = factor(rep(c("A", "B"), 10)),
    var_with_colon = 1:20,
    var_with_star = 21:40,
    var_with_plus = 41:60,
    stringsAsFactors = FALSE
  )
  
  bp2 <- table1(group ~ var_with_colon + var_with_star, data = interaction_data)
  expect_s3_class(bp2, "table1_blueprint")
})

test_that("Stratification edge cases", {
  # Test with stratification variable that has only one level in some strata
  strata_data <- data.frame(
    group = factor(rep(c("A", "B"), 15)),
    outcome = 1:30,
    strata_var = factor(c(rep("S1", 10), rep("S2", 20))),
    unbalanced_factor = factor(c(rep("level1", 25), rep("level2", 5))),
    stringsAsFactors = FALSE
  )
  
  bp1 <- table1(group ~ outcome, data = strata_data, strata = "strata_var")
  expect_s3_class(bp1, "table1_blueprint")
  
  # Test with strata that has empty levels in some groups
  bp2 <- table1(group ~ unbalanced_factor, data = strata_data, strata = "strata_var")
  expect_s3_class(bp2, "table1_blueprint")
  
  # Should render
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
})

test_that("Multi-format rendering consistency", {
  # Create a standard test case
  test_data <- mtcars[1:20, ]
  test_data$group <- factor(rep(c("A", "B"), 10))
  
  bp <- table1(group ~ mpg + cyl + hp, data = test_data, theme = "console")
  
  # All formats should render without error
  console_output <- render_console(bp)
  html_output <- render_html(bp)
  latex_output <- render_latex(bp)
  
  expect_type(console_output, "character")
  expect_type(html_output, "character")
  expect_type(latex_output, "character")
  
  # Outputs should be non-empty
  expect_true(nchar(console_output) > 0)
  expect_true(nchar(html_output) > 0)
  expect_true(nchar(latex_output) > 0)
})

test_that("Variable names with special characters", {
  # Test variable names that might cause parsing issues
  special_names_data <- data.frame(
    group = factor(rep(c("A", "B"), 10)),
    "var with spaces" = 1:20,
    "var.with.dots" = 21:40,
    "var_with_underscores" = 41:60,
    "var-with-dashes" = 61:80,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  
  # Note: R formula parsing may convert some special characters
  bp <- table1(group ~ `var with spaces` + var.with.dots + var_with_underscores, 
              data = special_names_data)
  expect_s3_class(bp, "table1_blueprint")
  
  expect_no_error(render_console(bp))
})

test_that("Large number of factor levels", {
  # Test with factor that has many levels (should generate warning)
  many_levels_data <- data.frame(
    group = factor(rep(c("A", "B"), 50)),
    many_level_factor = factor(paste0("Level_", 1:100)),
    stringsAsFactors = FALSE
  )
  
  expect_warning({
    bp <- table1(group ~ many_level_factor, data = many_levels_data)
  }, "levels")
  
  expect_s3_class(bp, "table1_blueprint")
  expect_no_error(render_console(bp))
})

test_that("Logical variable edge cases", {
  logical_data <- data.frame(
    group = factor(rep(c("A", "B"), 10)),
    all_true = rep(TRUE, 20),
    all_false = rep(FALSE, 20),
    mixed_logical = c(rep(TRUE, 10), rep(FALSE, 10)),
    logical_with_na = c(rep(TRUE, 5), rep(FALSE, 5), rep(NA, 10)),
    stringsAsFactors = FALSE
  )
  
  # All TRUE values
  bp1 <- table1(group ~ all_true, data = logical_data)
  expect_s3_class(bp1, "table1_blueprint")
  
  # All FALSE values  
  bp2 <- table1(group ~ all_false, data = logical_data)
  expect_s3_class(bp2, "table1_blueprint")
  
  # Mixed with NA values
  bp3 <- table1(group ~ logical_with_na, data = logical_data, missing = TRUE)
  expect_s3_class(bp3, "table1_blueprint")
  
  # Should all render
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
  expect_no_error(render_console(bp3))
})

test_that("Date and time variable edge cases", {
  # Test with date variables (converted to factors/characters for table1)
  date_data <- data.frame(
    group = factor(rep(c("A", "B"), 10)),
    date_var = as.Date("2023-01-01") + 0:19,
    datetime_var = as.POSIXct("2023-01-01 10:00:00") + (0:19) * 3600,
    stringsAsFactors = FALSE
  )
  
  # Convert dates to factors for table1 analysis
  date_data$date_factor <- as.factor(format(date_data$date_var, "%Y-%m"))
  date_data$datetime_factor <- as.factor(format(date_data$datetime_var, "%Y-%m-%d %H:00"))
  
  bp1 <- table1(group ~ date_factor, data = date_data)
  expect_s3_class(bp1, "table1_blueprint")
  
  bp2 <- table1(group ~ datetime_factor, data = date_data) 
  expect_s3_class(bp2, "table1_blueprint")
  
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
})

test_that("Unicode and international character support", {
  # Test with international characters
  unicode_data <- data.frame(
    group = factor(rep(c("Group_α", "Group_β"), 10)),
    var_with_unicode = factor(c(rep("François", 10), rep("José", 10))),
    var_with_symbols = factor(c(rep("≤5", 10), rep(">5", 10))),
    stringsAsFactors = FALSE
  )
  
  bp <- table1(group ~ var_with_unicode + var_with_symbols, data = unicode_data)
  expect_s3_class(bp, "table1_blueprint")
  
  # Should render (though display may vary by system)
  expect_no_error(render_console(bp))
})

test_that("Memory efficiency with large datasets", {
  # Create a moderately large dataset to test memory handling
  large_data <- data.frame(
    group = factor(rep(c("A", "B", "C"), 1000)),
    numeric1 = rnorm(3000),
    numeric2 = runif(3000),
    factor1 = factor(sample(c("Level1", "Level2", "Level3", "Level4"), 3000, replace = TRUE)),
    factor2 = factor(sample(letters[1:5], 3000, replace = TRUE)),
    stringsAsFactors = FALSE
  )
  
  # Should create blueprint efficiently
  start_time <- Sys.time()
  bp <- table1(group ~ numeric1 + numeric2 + factor1 + factor2, data = large_data)
  end_time <- Sys.time()
  
  expect_s3_class(bp, "table1_blueprint")
  expect_true(as.numeric(end_time - start_time) < 5)  # Should complete within 5 seconds
  
  # Should render efficiently
  start_render <- Sys.time()
  output <- render_console(bp)
  end_render <- Sys.time()
  
  expect_type(output, "character")
  expect_true(as.numeric(end_render - start_render) < 10)  # Should render within 10 seconds
})

# ============================================================================
# Performance and Robustness Tests
# ============================================================================

test_that("Error recovery and graceful degradation", {
  # Test with data that might cause computation errors
  problematic_data <- data.frame(
    group = factor(rep(c("A", "B"), 10)),
    zero_variance = rep(1, 20),  # No variance
    negative_values = c(rep(-1, 10), rep(1, 10)),
    extreme_outliers = c(rep(1, 19), 1000000),  # One extreme outlier
    stringsAsFactors = FALSE
  )
  
  # These should still work even with unusual data patterns
  bp1 <- table1(group ~ zero_variance, data = problematic_data)
  expect_s3_class(bp1, "table1_blueprint")
  
  bp2 <- table1(group ~ extreme_outliers, data = problematic_data)
  expect_s3_class(bp2, "table1_blueprint")
  
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
})

test_that("Concurrent operations and state isolation", {
  # Test that multiple table1 calls don't interfere with each other
  test_data <- mtcars[1:20, ]
  test_data$group <- factor(rep(c("A", "B"), 10))
  
  bp1 <- table1(group ~ mpg, data = test_data, theme = "console")
  bp2 <- table1(group ~ hp, data = test_data, theme = "nejm")  
  bp3 <- table1(group ~ cyl, data = test_data, theme = "lancet")
  
  # Each should maintain its own state
  expect_s3_class(bp1, "table1_blueprint")
  expect_s3_class(bp2, "table1_blueprint") 
  expect_s3_class(bp3, "table1_blueprint")
  
  # Should render independently
  out1 <- render_console(bp1)
  out2 <- render_html(bp2)
  out3 <- render_latex(bp3)
  
  expect_type(out1, "character")
  expect_type(out2, "character")
  expect_type(out3, "character")
  
  # Should have different content
  expect_false(identical(out1, out2))
  expect_false(identical(out2, out3))
})