# Test Performance and Memory Efficiency
# =====================================

library(testthat)

# Test uses package functions via testthat - no need to source files

test_that("Sparse storage is memory efficient", {
  skip_if_not(capabilities("long.double"), "Need long.double for memory tests")
  
  # Create large sparse blueprint
  bp_sparse <- Table1Blueprint(500, 20)
  
  # Populate only 5% of cells
  n_cells_to_fill <- round(0.05 * 500 * 20)
  
  for (i in 1:n_cells_to_fill) {
    row <- ((i-1) %% 500) + 1
    col <- ((i-1) %/% 500) + 1
    if (col <= 20 && exists("Cell", mode = "function")) {
      bp_sparse[row, col] <- Cell(type = "content", content = paste("Cell", i))
    }
  }
  
  # Memory should be reasonable for sparse structure
  memory_size <- as.numeric(object.size(bp_sparse))
  expect_lt(memory_size, 1000000)  # Less than 1MB
})

test_that("Cell access is fast", {
  bp <- Table1Blueprint(100, 10)
  
  # Add some cells
  if (exists("Cell", mode = "function")) {
    bp[50, 5] <- Cell(type = "content", content = "Test")
    bp[25, 8] <- Cell(type = "content", content = "Another")
  }
  
  # Time multiple accesses
  start_time <- Sys.time()
  for (i in 1:1000) {
    cell1 <- bp[50, 5]
    cell2 <- bp[25, 8]  
    cell3 <- bp[1, 1]  # Empty cell
  }
  end_time <- Sys.time()
  
  elapsed <- as.numeric(end_time - start_time, units = "secs")
  expect_lt(elapsed, 0.1)  # Should be very fast
})

test_that("Vectorized operations are efficient", {
  data(mtcars)
  vars <- c("mpg", "cyl", "disp", "hp", "drat", "wt")
  
  start_time <- Sys.time()
  
  if (exists("analyze_variables_vectorized", mode = "function")) {
    result <- analyze_variables_vectorized(vars, mtcars, FALSE)
    end_time <- Sys.time()
    
    elapsed <- as.numeric(end_time - start_time, units = "secs")
    expect_lt(elapsed, 0.5)  # Should complete quickly
    
    expect_equal(length(result$variables), length(vars))
  } else {
    skip("analyze_variables_vectorized not available")
  }
})

test_that("Large dataset handling is efficient", {
  skip_if_not(nrow(mtcars) > 0, "Need test data")
  
  # Create larger test dataset
  set.seed(123)
  large_data <- do.call(rbind, replicate(50, mtcars, simplify = FALSE))
  large_data$group <- factor(sample(c("A", "B", "C"), nrow(large_data), replace = TRUE))
  
  start_time <- Sys.time()
  
  # Test dimension analysis
  if (exists("analyze_dimensions", mode = "function")) {
    dims <- analyze_dimensions(
      x_vars = c("mpg", "hp", "wt"),
      grp_var = "group",
      data = large_data,
      strata = NULL,
      missing = FALSE,
      pvalue = TRUE,
      totals = FALSE,
      layout = "console"
    )
    
    end_time <- Sys.time()
    elapsed <- as.numeric(end_time - start_time, units = "secs")
    expect_lt(elapsed, 2.0)  # Should handle large data quickly
    
    expect_true(dims$nrows > 0)
    expect_true(dims$ncols > 0)
  } else {
    skip("analyze_dimensions not available")
  }
})

test_that("Memory usage is reasonable for realistic scenario", {
  # Clinical trial simulation
  set.seed(123)
  n <- 1000
  clinical_data <- data.frame(
    treatment = factor(sample(c("Placebo", "Drug"), n, replace = TRUE)),
    age = round(rnorm(n, 65, 12)),
    sex = factor(sample(c("M", "F"), n, replace = TRUE)),
    bmi = round(rnorm(n, 28, 5), 1)
  )
  
  start_memory <- gc()
  
  if (exists("table1", mode = "function")) {
    bp <- table1(
      treatment ~ age + sex + bmi,
      data = clinical_data,
      theme = "nejm"
    )
    
    # Check memory usage
    bp_size <- as.numeric(object.size(bp))
    expect_lt(bp_size, 1000000)  # Less than 1MB for this size table
    
    # Verify structure
    expect_s3_class(bp, "table1_blueprint")
    expect_true(bp$nrows > 0)
    expect_true(bp$ncols > 0)
  } else {
    skip("table1 not available")
  }
})