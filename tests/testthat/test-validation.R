# Test Validation System
# ======================

library(testthat)

# Test data setup
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))

test_that("Valid inputs pass validation", {
  expect_silent(
    validate_inputs(
      formula = transmission ~ mpg + hp,
      data = mtcars,
      theme = "nejm"
    )
  )
})

test_that("Invalid formula is caught", {
  expect_error(
    validate_inputs(
      formula = "not a formula",
      data = mtcars
    ),
    "formula"
  )
})

test_that("Missing variables are detected", {
  expect_error(
    validate_inputs(
      formula = nonexistent ~ mpg,
      data = mtcars
    ),
    "not found"
  )
})

test_that("Empty data frame is handled", {
  empty_data <- mtcars[0, ]
  
  expect_error(
    validate_inputs(
      formula = transmission ~ mpg,
      data = empty_data
    ),
    "empty"
  )
})

test_that("Data quality warnings are generated", {
  # Create data with quality issues
  test_data <- mtcars
  test_data$high_missing <- c(rep(NA, 25), rep(1, 7))  # 78% missing
  
  expect_warning(
    validate_inputs(
      formula = transmission ~ high_missing,
      data = test_data
    ),
    regexp = "missing"
  )
})

test_that("Variable type detection works", {
  expect_equal(detect_variable_type(c(1, 2, 3)), "continuous")
  expect_equal(detect_variable_type(factor(c("A", "B"))), "factor")
  expect_equal(detect_variable_type(c("a", "b", "c")), "character")
  expect_equal(detect_variable_type(c(TRUE, FALSE)), "logical")
})

test_that("Formula validation works", {
  result <- validate_formula_structure(transmission ~ mpg + hp, mtcars)
  
  expect_true(result$valid)
  expect_true(result$has_response)
  expect_equal(result$response_vars, "transmission")
  expect_true("mpg" %in% result$predictor_vars)
  expect_true("hp" %in% result$predictor_vars)
})