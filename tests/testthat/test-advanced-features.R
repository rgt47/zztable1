# =============================================================================
# Advanced Features Tests  
# =============================================================================

library(testthat)

# Test data setup
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
mtcars$engine_shape <- factor(ifelse(mtcars$vs == 1, "V-shaped", "Straight"))

test_that("P-values are calculated correctly", {
  bp <- table1(
    transmission ~ mpg + hp, 
    data = mtcars, 
    pvalue = TRUE
  )
  
  expect_s3_class(bp, "table1_blueprint")
  expect_true("p.value" %in% bp$col_names)
  expect_true(bp$ncols >= 3)  # At least 2 groups + p-value
})

test_that("Totals column works", {
  bp <- table1(
    transmission ~ mpg + hp,
    data = mtcars,
    totals = TRUE
  )
  
  expect_s3_class(bp, "table1_blueprint")
  expect_true("Total" %in% bp$col_names)
})

test_that("Missing values handling works", {
  # Create data with missing values
  test_data <- mtcars
  test_data$mpg[1:5] <- NA
  test_data$transmission <- factor(ifelse(test_data$am == 1, "Manual", "Automatic"))
  
  bp_no_missing <- table1(
    transmission ~ mpg,
    data = test_data,
    missing = FALSE
  )
  
  bp_with_missing <- table1(
    transmission ~ mpg,
    data = test_data,
    missing = TRUE
  )
  
  expect_s3_class(bp_with_missing, "table1_blueprint")
  expect_true(bp_with_missing$nrows > bp_no_missing$nrows)  # Should have additional missing row
  expect_equal(bp_with_missing$nrows - bp_no_missing$nrows, 1)  # Exactly one more row
})

test_that("Stratification works correctly", {
  bp <- table1(
    transmission ~ mpg + hp,
    data = mtcars,
    strata = "engine_shape"
  )
  
  expect_s3_class(bp, "table1_blueprint")
  expect_true(bp$nrows > 5)  # Should have more rows due to stratification
})

test_that("Different themes produce different output", {
  bp_console <- table1(
    transmission ~ mpg,
    data = mtcars,
    theme = "console"
  )
  
  bp_nejm <- table1(
    transmission ~ mpg,
    data = mtcars,
    theme = "nejm"
  )
  
  expect_s3_class(bp_console, "table1_blueprint")
  expect_s3_class(bp_nejm, "table1_blueprint")
  expect_false(identical(bp_console$metadata$theme, bp_nejm$metadata$theme))
})

test_that("Multiple output formats work", {
  bp <- table1(transmission ~ mpg, data = mtcars)
  
  # Console output
  console_output <- render_console(bp)
  expect_type(console_output, "character")
  expect_true(length(console_output) > 0)
  
  # LaTeX output
  latex_output <- render_latex(bp)
  expect_type(latex_output, "character")
  expect_true(any(grepl("tabular", latex_output)))
  
  # HTML output
  html_output <- render_html(bp)
  expect_type(html_output, "character")
  expect_true(any(grepl("<table", html_output)))
})

test_that("Custom numeric summaries work", {
  # Built-in summary
  bp1 <- table1(
    transmission ~ mpg,
    data = mtcars,
    numeric_summary = "median_iqr"
  )
  expect_s3_class(bp1, "table1_blueprint")
  
  # Custom function
  custom_func <- function(x) {
    paste0(round(mean(x, na.rm = TRUE), 1), " [custom]")
  }
  
  bp2 <- table1(
    transmission ~ mpg,
    data = mtcars,
    numeric_summary = custom_func
  )
  expect_s3_class(bp2, "table1_blueprint")
})

test_that("Footnotes system works", {
  bp <- table1(
    transmission ~ mpg + hp,
    data = mtcars,
    pvalue = TRUE,
    footnotes = list(
      variables = list(
        mpg = "Miles per gallon EPA rating",
        hp = "Gross horsepower"
      ),
      columns = list(
        "p.value" = "P-value from t-test"
      ),
      general = list(
        "Data from 1974 Motor Trend magazine"
      )
    )
  )
  
  expect_s3_class(bp, "table1_blueprint")
  expect_true(length(bp$metadata$footnote_list) >= 3)
})

test_that("Large dataset performance", {
  # Create larger dataset
  large_data <- do.call(rbind, replicate(10, mtcars, simplify = FALSE))
  large_data$transmission <- factor(ifelse(large_data$am == 1, "Manual", "Automatic"))
  
  # Should complete quickly
  start_time <- Sys.time()
  bp <- table1(
    transmission ~ mpg + hp + wt,
    data = large_data
  )
  end_time <- Sys.time()
  
  elapsed <- as.numeric(end_time - start_time, units = "secs")
  
  expect_s3_class(bp, "table1_blueprint")
  expect_lt(elapsed, 2.0)  # Should complete in under 2 seconds
})

test_that("Memory efficiency with sparse tables", {
  bp <- Table1Blueprint(1000, 50)  # Large sparse table
  
  # Populate only 1% of cells
  n_cells <- 50
  for (i in 1:n_cells) {
    row <- ((i - 1) %% 1000) + 1
    col <- ((i - 1) %/% 1000) + 1
    if (col <= 50) {
      bp[row, col] <- Cell(type = "content", content = paste("Cell", i))
    }
  }
  
  # Memory should be reasonable
  memory_size <- as.numeric(object.size(bp))
  expect_lt(memory_size, 1000000)  # Less than 1MB
})

test_that("Complex formula structures work", {
  # One-sided formula (requires totals = TRUE and pvalue = FALSE)
  bp1 <- table1(~ mpg + hp, data = mtcars, totals = TRUE, pvalue = FALSE)
  expect_s3_class(bp1, "table1_blueprint")
  
  # Multiple variables
  bp2 <- table1(
    transmission ~ mpg + hp + wt + qsec + gear,
    data = mtcars
  )
  expect_s3_class(bp2, "table1_blueprint")
  expect_true(bp2$nrows >= 5)
})