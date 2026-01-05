# =============================================================================
# Error Conditions and Edge Cases Tests
# =============================================================================

library(testthat)

# Test data setup
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))

test_that("Input validation errors are informative", {
  # Non-formula input
  expect_error(
    table1("not a formula", data = mtcars),
    "First argument must be a formula",
    fixed = TRUE
  )
  
  # Missing data parameter
  expect_error(
    table1(transmission ~ mpg),
    "data",
    fixed = FALSE
  )
  
  # Non-data.frame data
  expect_error(
    table1(transmission ~ mpg, data = list(a = 1)),
    "data.frame"
  )
  
  # Empty data
  empty_data <- mtcars[0, ]
  expect_error(
    table1(transmission ~ mpg, data = empty_data),
    "Data frame is empty"
  )
})

test_that("Variable existence validation works", {
  # Nonexistent grouping variable
  expect_error(
    table1(nonexistent_var ~ mpg, data = mtcars),
    "not found"
  )
  
  # Nonexistent predictor variable
  expect_error(
    table1(transmission ~ nonexistent_var, data = mtcars),
    "not found"  
  )
  
  # Nonexistent strata variable
  expect_error(
    table1(transmission ~ mpg, data = mtcars, strata = "nonexistent"),
    "not found"
  )
})

test_that("Invalid parameter combinations are caught", {
  # P-values without grouping variable
  expect_error(
    table1(~ mpg, data = mtcars, pvalue = TRUE),
    regex = "(grouping|totals)"
  )
  
  # Invalid theme
  expect_warning(
    table1(transmission ~ mpg, data = mtcars, theme = "invalid_theme"),
    "Unknown theme"
  )
  
  # Invalid layout
  bp <- suppressWarnings(
    table1(transmission ~ mpg, data = mtcars, layout = "invalid")
  )
  expect_s3_class(bp, "table1_blueprint")  # Should work but warn
})

test_that("Blueprint construction errors are handled", {
  # Invalid dimensions
  expect_error(Table1Blueprint(-1, 5), "positive")
  expect_error(Table1Blueprint(5, -1), "positive") 
  expect_error(Table1Blueprint(0, 5), "positive")
  expect_error(Table1Blueprint(5, 0), "positive")
  
  # Very large dimensions (should work but be reasonable)
  expect_error(Table1Blueprint(1e6, 1e6), "too large|memory")
})

test_that("Cell assignment errors are informative", {
  bp <- Table1Blueprint(3, 3)
  
  # Out of bounds assignment
  expect_error(bp[5, 1] <- Cell(type = "content", content = "test"), "out of bounds")
  expect_error(bp[1, 5] <- Cell(type = "content", content = "test"), "out of bounds")
  
  # Invalid cell object
  expect_error(bp[1, 1] <- "not a cell", "Cell object")
  expect_error(bp[1, 1] <- list(content = "test"), "Cell object")
})

test_that("Cell type validation works", {
  # Invalid cell type
  expect_error(Cell(type = "invalid_type", content = "test"), "must be one of")
  
  # Missing required parameters
  expect_error(Cell(type = "computation"), "data_subset")
  expect_error(
    Cell(type = "computation", data_subset = expression(data$x)),
    "computation"
  )
})

test_that("Data quality warnings are generated", {
  # High missing data
  test_data <- mtcars
  test_data$high_missing <- c(rep(NA, 25), rep(1, 7))  # 78% missing
  
  expect_warning(
    table1(transmission ~ high_missing, data = test_data),
    "missing"
  )
  
  # Many factor levels
  test_data$many_levels <- paste0("Level_", 1:nrow(test_data))
  expect_warning(
    table1(transmission ~ many_levels, data = test_data),
    "levels"
  )
})

test_that("Cell evaluation error recovery works", {
  # Create cell with invalid computation that will throw an error
  cell <- Cell(
    type = "computation", 
    data_subset = expression(data$mpg),  # valid data subset
    computation = expression(mean(x) + undefined_function()),  # invalid computation
    dependencies = c("data", "mpg")
  )
  
  # Should return error marker, not crash
  result <- suppressWarnings(evaluate_cell(cell, mtcars))
  expect_equal(result, "[Error]")
})

test_that("Large dataset edge cases", {
  # Very wide dataset
  wide_data <- mtcars
  for (i in 1:20) {
    wide_data[[paste0("var_", i)]] <- rnorm(nrow(wide_data))
  }
  wide_data$group <- factor(rep(c("A", "B"), length.out = nrow(wide_data)))
  
  # Should handle gracefully
  bp <- table1(
    group ~ var_1 + var_2 + var_3,
    data = wide_data
  )
  expect_s3_class(bp, "table1_blueprint")
  
  # Dataset with extreme values
  extreme_data <- mtcars
  extreme_data$extreme_var <- c(rep(1e6, 10), rep(-1e6, 10), rep(0, nrow(extreme_data) - 20))
  
  bp2 <- table1(transmission ~ extreme_var, data = extreme_data)
  expect_s3_class(bp2, "table1_blueprint")
})

test_that("Memory allocation edge cases", {
  # Test with NULL checks
  expect_error(Table1Blueprint(NULL, 5), "single numeric values")
  expect_error(Table1Blueprint(5, NULL), "single numeric values")
  
  # Test with non-integer dimensions
  bp <- Table1Blueprint(5.0, 3.0)  # Should coerce to integer
  expect_equal(bp$nrows, 5L)
  expect_equal(bp$ncols, 3L)
})

test_that("Footnote edge cases", {
  # Empty footnotes
  bp1 <- table1(
    transmission ~ mpg,
    data = mtcars,
    footnotes = list()
  )
  expect_s3_class(bp1, "table1_blueprint")
  
  # Malformed footnotes
  expect_error(
    table1(
      transmission ~ mpg,
      data = mtcars,
      footnotes = "not a list"
    ),
    "must be a list"
  )
  
  # Footnotes for nonexistent variables
  bp2 <- suppressWarnings(
    table1(
      transmission ~ mpg,
      data = mtcars,
      footnotes = list(variables = list(nonexistent = "note"))
    )
  )
  expect_s3_class(bp2, "table1_blueprint")
})

test_that("Theme edge cases", {
  # NULL theme
  bp1 <- table1(transmission ~ mpg, data = mtcars, theme = NULL)
  expect_s3_class(bp1, "table1_blueprint")
  
  # Theme with missing configuration (plain list, not a theme object)
  custom_theme <- list(name = "Incomplete")
  expect_error(
    apply_theme(Table1Blueprint(3, 3), custom_theme),
    "character string or theme object"
  )
})