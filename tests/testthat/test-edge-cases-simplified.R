# ============================================================================
# Simplified Edge Case Tests for zztable1_nextgen
# ============================================================================
#
# Focused set of edge case tests that cover critical scenarios without 
# performance-intensive operations

library(testthat)

# Test uses package functions via testthat - no need to source files

# ============================================================================
# Critical Edge Case Tests
# ============================================================================

test_that("Single observation tables work correctly", {
  single_obs <- data.frame(
    group = factor("A"),
    numeric_var = 1.5,
    factor_var = factor("level1"),
    stringsAsFactors = FALSE
  )
  
  bp <- table1(group ~ numeric_var, data = single_obs)
  expect_s3_class(bp, "table1_blueprint")
  expect_true(bp$nrows >= 1)
  expect_true(bp$ncols >= 2)
  
  # Should render without error
  expect_no_error(render_console(bp))
})

test_that("Two observation edge cases", {
  two_obs <- data.frame(
    group = factor(c("A", "B")),
    numeric_var = c(1.0, 2.0),
    factor_var = factor(c("level1", "level2")),
    stringsAsFactors = FALSE
  )
  
  bp <- table1(group ~ numeric_var + factor_var, data = two_obs)
  expect_s3_class(bp, "table1_blueprint")
  expect_no_error(render_console(bp))
})

test_that("All missing data handled correctly", {
  missing_data <- data.frame(
    group = factor(rep(c("A", "B"), 5)),
    all_na = rep(NA, 10),
    mostly_na = c(rep(NA, 9), 1),
    stringsAsFactors = FALSE
  )
  
  # Should generate warning for high missing percentage
  expect_warning({
    bp1 <- table1(group ~ all_na, data = missing_data)
  }, "missing")
  expect_s3_class(bp1, "table1_blueprint")
  
  expect_warning({
    bp2 <- table1(group ~ mostly_na, data = missing_data)
  }, "missing")
  expect_s3_class(bp2, "table1_blueprint")
})

test_that("Special factor level names", {
  special_data <- data.frame(
    group = factor(rep(c("A", "B"), 5)),
    empty_string = factor(c(rep("", 5), rep("normal", 5))),
    special_chars = factor(c(rep("level@#$", 5), rep("level_2", 5))),
    numbers_factor = factor(c(rep("123", 5), rep("456", 5))),
    stringsAsFactors = FALSE
  )
  
  bp1 <- table1(group ~ empty_string, data = special_data)
  expect_s3_class(bp1, "table1_blueprint")
  
  bp2 <- table1(group ~ special_chars, data = special_data)
  expect_s3_class(bp2, "table1_blueprint")
  
  bp3 <- table1(group ~ numbers_factor, data = special_data)
  expect_s3_class(bp3, "table1_blueprint")
  
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
  expect_no_error(render_console(bp3))
})

test_that("Numeric extreme values", {
  numeric_extremes <- data.frame(
    group = factor(rep(c("A", "B"), 5)),
    zeros = rep(0, 10),
    large_numbers = c(rep(1e6, 5), rep(1e9, 5)),
    tiny_numbers = c(rep(1e-6, 5), rep(1e-9, 5)),
    negative = c(rep(-100, 5), rep(-0.01, 5)),
    stringsAsFactors = FALSE
  )
  
  bp1 <- table1(group ~ zeros, data = numeric_extremes)
  expect_s3_class(bp1, "table1_blueprint")
  
  bp2 <- table1(group ~ large_numbers, data = numeric_extremes)
  expect_s3_class(bp2, "table1_blueprint")
  
  bp3 <- table1(group ~ tiny_numbers, data = numeric_extremes)
  expect_s3_class(bp3, "table1_blueprint")
  
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
  expect_no_error(render_console(bp3))
})

test_that("Infinite and NaN values handled", {
  extreme_values <- data.frame(
    group = factor(rep(c("A", "B"), 10)),
    with_inf = c(rep(Inf, 5), rep(-Inf, 5), rep(1, 10)),
    with_nan = c(rep(NaN, 3), rep(1, 17)),
    stringsAsFactors = FALSE
  )
  
  bp1 <- table1(group ~ with_inf, data = extreme_values)
  expect_s3_class(bp1, "table1_blueprint")
  
  bp2 <- table1(group ~ with_nan, data = extreme_values)
  expect_s3_class(bp2, "table1_blueprint")
  
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
})

test_that("Many factor levels generates warning", {
  many_levels_data <- data.frame(
    group = factor(rep(c("A", "B"), 25)),
    many_level_factor = factor(paste0("Level_", 1:50)),
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
    group = factor(rep(c("A", "B"), 5)),
    all_true = rep(TRUE, 10),
    all_false = rep(FALSE, 10),
    mixed_logical = c(rep(TRUE, 5), rep(FALSE, 5)),
    logical_with_na = c(rep(TRUE, 3), rep(FALSE, 3), rep(NA, 4)),
    stringsAsFactors = FALSE
  )
  
  bp1 <- table1(group ~ all_true, data = logical_data)
  expect_s3_class(bp1, "table1_blueprint")
  
  bp2 <- table1(group ~ all_false, data = logical_data)
  expect_s3_class(bp2, "table1_blueprint")
  
  bp3 <- table1(group ~ logical_with_na, data = logical_data, missing = TRUE)
  expect_s3_class(bp3, "table1_blueprint")
  
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
  expect_no_error(render_console(bp3))
})

test_that("Multiple variable combinations", {
  multi_data <- mtcars[1:10, ]
  multi_data$group <- factor(rep(c("A", "B"), 5))
  
  # Test with many variables
  bp <- table1(group ~ mpg + cyl + hp + wt, data = multi_data)
  expect_s3_class(bp, "table1_blueprint")
  expect_true(bp$nrows >= 4)  # At least one row per variable
  
  expect_no_error(render_console(bp))
})

test_that("Stratification with edge cases", {
  strata_data <- data.frame(
    group = factor(rep(c("A", "B"), 10)),
    outcome = 1:20,
    strata_var = factor(c(rep("S1", 5), rep("S2", 15))),  # Unbalanced strata
    stringsAsFactors = FALSE
  )
  
  bp <- table1(group ~ outcome, data = strata_data, strata = "strata_var")
  expect_s3_class(bp, "table1_blueprint")
  expect_no_error(render_console(bp))
})

test_that("Multi-format rendering works", {
  test_data <- mtcars[1:6, ]
  test_data$group <- factor(rep(c("A", "B"), 3))
  
  bp <- table1(group ~ mpg + cyl, data = test_data)
  
  console_output <- render_console(bp)
  html_output <- render_html(bp)
  latex_output <- render_latex(bp)
  
  expect_type(console_output, "character")
  expect_type(html_output, "character")
  expect_type(latex_output, "character")
  
  expect_true(nchar(console_output) > 0)
  expect_true(nchar(html_output) > 0)
  expect_true(nchar(latex_output) > 0)
})

test_that("Error recovery with problematic data", {
  problematic_data <- data.frame(
    group = factor(rep(c("A", "B"), 5)),
    zero_variance = rep(1, 10),  # No variance
    extreme_outlier = c(rep(1, 9), 1000000),  # One extreme outlier
    stringsAsFactors = FALSE
  )
  
  bp1 <- table1(group ~ zero_variance, data = problematic_data)
  expect_s3_class(bp1, "table1_blueprint")
  
  bp2 <- table1(group ~ extreme_outlier, data = problematic_data)
  expect_s3_class(bp2, "table1_blueprint")
  
  expect_no_error(render_console(bp1))
  expect_no_error(render_console(bp2))
})

test_that("Unicode character support", {
  unicode_data <- data.frame(
    group = factor(rep(c("Group_α", "Group_β"), 5)),
    var_unicode = factor(c(rep("François", 5), rep("José", 5))),
    var_symbols = factor(c(rep("≤5", 5), rep(">5", 5))),
    stringsAsFactors = FALSE
  )
  
  bp <- table1(group ~ var_unicode + var_symbols, data = unicode_data)
  expect_s3_class(bp, "table1_blueprint")
  
  # Should render (display quality may vary by system)
  expect_no_error(render_console(bp))
})

test_that("Variable names with special characters", {
  special_names_data <- data.frame(
    group = factor(rep(c("A", "B"), 5)),
    "var with spaces" = 1:10,
    "var.with.dots" = 11:20,
    "var_with_underscores" = 21:30,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  
  bp <- table1(group ~ `var with spaces` + var.with.dots + var_with_underscores, 
              data = special_names_data)
  expect_s3_class(bp, "table1_blueprint")
  expect_no_error(render_console(bp))
})

test_that("State isolation between calls", {
  test_data <- mtcars[1:8, ]
  test_data$group <- factor(rep(c("A", "B"), 4))
  
  # Multiple concurrent calls with different themes
  bp1 <- table1(group ~ mpg, data = test_data, theme = "console")
  bp2 <- table1(group ~ hp, data = test_data, theme = "nejm")  
  bp3 <- table1(group ~ cyl, data = test_data, theme = "lancet")
  
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
})