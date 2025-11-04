# =============================================================================
# Core Functionality Tests
# =============================================================================

library(testthat)

# Load test data
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))

test_that("Table1Blueprint creation works correctly", {
  bp <- Table1Blueprint(10, 5)
  
  expect_s3_class(bp, "table1_blueprint")
  expect_equal(bp$nrows, 10L)
  expect_equal(bp$ncols, 5L)
  expect_true(inherits(bp$cells, "environment"))
})

test_that("Cell creation and validation works", {
  # Static cell
  static_cell <- Cell(type = "content", content = "Test Value")
  expect_s3_class(static_cell, c("cell", "cell_static"))
  expect_equal(static_cell$content, "Test Value")
  
  # Computation cell
  comp_cell <- Cell(
    type = "computation",
    data_subset = expression(data$mpg[data$am == 1]),
    computation = expression(mean(x, na.rm = TRUE)),
    dependencies = c("data", "mpg", "am")
  )
  expect_s3_class(comp_cell, c("cell", "cell_computation"))
  expect_true(is.expression(comp_cell$data_subset))
})

test_that("Cell assignment and retrieval works", {
  bp <- Table1Blueprint(5, 3)
  test_cell <- Cell(type = "content", content = "Test Value")
  
  # Assign cell
  bp[2, 1] <- test_cell
  
  # Retrieve cell
  retrieved <- bp[2, 1]
  expect_equal(retrieved$content, "Test Value")
  
  # Empty cell returns NULL
  empty_cell <- bp[1, 1]
  expect_null(empty_cell)
})

test_that("Blueprint bounds checking works", {
  bp <- Table1Blueprint(3, 3)
  
  expect_error(bp[5, 1], "out of bounds")
  expect_error(bp[1, 5], "out of bounds")
  expect_error(bp[0, 1], "out of bounds")
  expect_error(bp[1, 0], "out of bounds")
})

test_that("Basic table1 call works", {
  bp <- table1(transmission ~ mpg + hp, data = mtcars)
  
  expect_s3_class(bp, "table1_blueprint")
  expect_true(bp$nrows > 0)
  expect_true(bp$ncols > 0)
  expect_equal(bp$metadata$optimized, TRUE)
})

test_that("Theme system works correctly", {
  # Test available themes
  themes <- list_available_themes()
  expect_type(themes, "character")
  expect_true(length(themes) >= 5)
  expect_true("nejm" %in% themes)
  
  # Test theme configuration
  nejm_theme <- get_theme("nejm")
  expect_type(nejm_theme, "list")
  expect_equal(nejm_theme$name, "New England Journal of Medicine")
  expect_type(nejm_theme$decimal_places, "double")
})

test_that("Input validation catches common errors", {
  # Invalid formula
  expect_error(
    table1("not a formula", data = mtcars),
    "First argument must be a formula"
  )
  
  # Missing data
  expect_error(
    table1(transmission ~ mpg),
    "data"
  )
  
  # Nonexistent variable
  expect_error(
    table1(nonexistent ~ mpg, data = mtcars),
    "not found"
  )
  
  # Empty data
  empty_data <- mtcars[0, ]
  expect_error(
    table1(transmission ~ mpg, data = empty_data),
    "Data frame is empty"
  )
})

test_that("Different variable types handled correctly", {
  # Continuous variables
  bp1 <- table1(transmission ~ mpg + hp, data = mtcars)
  expect_s3_class(bp1, "table1_blueprint")
  
  # Factor variables  
  mtcars$cyl_factor <- factor(mtcars$cyl)
  bp2 <- table1(transmission ~ cyl_factor, data = mtcars)
  expect_s3_class(bp2, "table1_blueprint")
  
  # Mixed variables
  bp3 <- table1(transmission ~ mpg + cyl_factor, data = mtcars)
  expect_s3_class(bp3, "table1_blueprint")
})