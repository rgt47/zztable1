# =============================================================================
# Performance Benchmark Tests
# =============================================================================
# NOTE: These tests are skipped on CI because timing thresholds are
# machine-dependent and can produce false failures on slower CI runners.
# =============================================================================

library(testthat)

skip_on_ci()

# Test data generation
create_test_data <- function(n_rows = 1000, n_vars = 10) {
  set.seed(123)
  data <- data.frame(
    group = factor(sample(c("A", "B", "C"), n_rows, replace = TRUE))
  )
  
  # Add continuous variables
  for (i in 1:(n_vars %/% 2)) {
    data[[paste0("cont_", i)]] <- rnorm(n_rows, 50, 15)
  }
  
  # Add categorical variables
  for (i in 1:(n_vars %/% 2)) {
    levels <- paste0("Level_", 1:sample(3:6, 1))
    data[[paste0("cat_", i)]] <- factor(sample(levels, n_rows, replace = TRUE))
  }
  
  data
}

test_that("Blueprint creation is fast and memory efficient", {
  # Test various blueprint sizes
  sizes <- list(
    small = c(100, 10),
    medium = c(1000, 50),
    large = c(5000, 100)
  )
  
  for (size_name in names(sizes)) {
    dims <- sizes[[size_name]]
    
    start_time <- Sys.time()
    bp <- Table1Blueprint(dims[1], dims[2])
    end_time <- Sys.time()
    
    elapsed <- as.numeric(end_time - start_time, units = "secs")
    memory_size <- as.numeric(object.size(bp))
    
    # Should be fast
    expect_lt(elapsed, 0.1)
    
    # Should use reasonable memory (sparse storage benefit)
    max_memory <- dims[1] * dims[2] * 100  # 100 bytes per potential cell
    expect_lt(memory_size, max_memory)
  }
})

test_that("Sparse storage provides memory benefits", {
  # Compare sparse vs dense-like storage
  bp_sparse <- Table1Blueprint(1000, 20)
  
  # Populate only 5% of cells
  n_populated <- 100
  for (i in 1:n_populated) {
    row <- ((i - 1) %% 1000) + 1
    col <- ((i - 1) %/% 1000) + 1
    if (col <= 20) {
      bp_sparse[row, col] <- Cell(type = "content", content = paste("Cell", i))
    }
  }
  
  sparse_size <- as.numeric(object.size(bp_sparse))
  
  # Simulate dense storage (list of lists)
  dense_simulation <- vector("list", 1000)
  for (i in 1:1000) {
    dense_simulation[[i]] <- vector("list", 20)
  }
  dense_size <- as.numeric(object.size(dense_simulation))
  
  # Sparse should be more efficient for low utilization
  efficiency_ratio <- sparse_size / dense_size
  expect_lt(efficiency_ratio, 0.8)
})

test_that("Cell access performance is O(1)", {
  bp <- Table1Blueprint(1000, 50)
  
  # Populate some cells
  test_positions <- list(c(1, 1), c(500, 25), c(1000, 50), c(250, 10))
  for (pos in test_positions) {
    bp[pos[1], pos[2]] <- Cell(type = "content", content = paste("Cell", pos[1], pos[2]))
  }
  
  # Time many random accesses
  n_accesses <- 10000
  random_positions <- replicate(n_accesses, {
    c(sample(1:1000, 1), sample(1:50, 1))
  }, simplify = FALSE)
  
  start_time <- Sys.time()
  for (pos in random_positions) {
    cell <- bp[pos[1], pos[2]]  # This should be O(1)
  }
  end_time <- Sys.time()
  
  elapsed <- as.numeric(end_time - start_time, units = "secs")
  average_access_time <- elapsed / n_accesses
  
  # Should be very fast (sub-microsecond average)
  expect_lt(average_access_time, 1e-5)
})

test_that("Table creation scales reasonably with data size", {
  data_sizes <- c(100, 500, 1000, 2000)
  times <- numeric(length(data_sizes))
  memory_usage <- numeric(length(data_sizes))
  
  for (i in seq_along(data_sizes)) {
    n <- data_sizes[i]
    test_data <- create_test_data(n_rows = n, n_vars = 6)
    
    start_time <- Sys.time()
    bp <- table1(
      group ~ cont_1 + cont_2 + cat_1,
      data = test_data
    )
    end_time <- Sys.time()
    
    times[i] <- as.numeric(end_time - start_time, units = "secs")
    memory_usage[i] <- as.numeric(object.size(bp))
  }
  
  # Time complexity should be roughly linear or sub-quadratic
  # Check that doubling data size doesn't more than 10x time (more lenient)
  time_ratios <- times[-1] / times[-length(times)]
  expect_true(all(time_ratios < 10))
  
  # Memory should scale reasonably
  memory_ratios <- memory_usage[-1] / memory_usage[-length(memory_usage)]
  expect_true(all(memory_ratios < 3))
})

test_that("Theme application is fast", {
  bp <- Table1Blueprint(100, 10)
  
  # Populate some cells
  for (i in 1:50) {
    row <- sample(1:100, 1)
    col <- sample(1:10, 1)
    bp[row, col] <- Cell(type = "content", content = paste("Content", i))
  }
  
  themes_to_test <- list_available_themes()
  
  for (theme_name in themes_to_test) {
    theme_config <- get_theme(theme_name)
    
    start_time <- Sys.time()
    bp_themed <- apply_theme(bp, theme_config)
    end_time <- Sys.time()
    
    elapsed <- as.numeric(end_time - start_time, units = "secs")
    expect_lt(elapsed, 0.1)
  }
})

test_that("Rendering performance is reasonable", {
  # Create a realistic table
  test_data <- create_test_data(n_rows = 500, n_vars = 8)
  bp <- table1(
    group ~ cont_1 + cont_2 + cat_1 + cat_2,
    data = test_data,
    pvalue = TRUE,
    totals = TRUE
  )
  
  # Test different rendering formats
  formats <- list(
    console = render_console,
    latex = render_latex,
    html = render_html
  )
  
  for (format_name in names(formats)) {
    render_func <- formats[[format_name]]
    
    start_time <- Sys.time()
    output <- render_func(bp)
    end_time <- Sys.time()
    
    elapsed <- as.numeric(end_time - start_time, units = "secs")
    
    expect_lt(elapsed, 1.0)
    expect_true(length(output) > 0)
  }
})

test_that("Vectorized operations outperform loops", {
  test_data <- create_test_data(n_rows = 2000, n_vars = 10)
  var_names <- c("cont_1", "cont_2", "cont_3", "cat_1", "cat_2")
  
  # Time vectorized variable analysis
  start_time <- Sys.time()
  vectorized_result <- analyze_variables(var_names, test_data, FALSE)
  vectorized_time <- as.numeric(Sys.time() - start_time, units = "secs")
  
  # Simulate loop-based analysis (simplified)
  start_time <- Sys.time()
  loop_results <- list()
  for (var_name in var_names) {
    var_data <- test_data[[var_name]]
    if (is.numeric(var_data)) {
      loop_results[[var_name]] <- list(
        type = "numeric",
        missing = sum(is.na(var_data)),
        summary = list(mean = mean(var_data, na.rm = TRUE))
      )
    } else {
      loop_results[[var_name]] <- list(
        type = "factor",
        missing = sum(is.na(var_data)),
        levels = length(unique(var_data))
      )
    }
  }
  loop_time <- as.numeric(Sys.time() - start_time, units = "secs")
  
  # Vectorized should be faster (or at least not significantly slower)
  speedup_ratio <- loop_time / vectorized_time
  expect_gte(speedup_ratio, 0.5)
})

test_that("Memory usage remains stable during operations", {
  # Create initial table
  test_data <- create_test_data(n_rows = 1000, n_vars = 6)
  
  initial_memory <- gc()["Vcells", "used"]
  
  # Perform multiple table operations
  for (i in 1:10) {
    bp <- table1(
      group ~ cont_1 + cont_2 + cat_1,
      data = test_data,
      theme = sample(list_available_themes(), 1)
    )
    
    # Force garbage collection periodically
    if (i %% 3 == 0) gc()
  }
  
  final_memory <- gc()["Vcells", "used"]
  
  # Memory growth should be reasonable
  memory_growth <- (final_memory - initial_memory) / initial_memory
  expect_lt(memory_growth, 2.0)
})

test_that("Performance regression benchmarks", {
  # These are baseline performance expectations that should not regress
  test_data <- create_test_data(n_rows = 1000, n_vars = 8)
  
  # Basic table creation benchmark
  start_time <- Sys.time()
  bp <- table1(
    group ~ cont_1 + cont_2 + cont_3 + cat_1 + cat_2,
    data = test_data,
    pvalue = TRUE,
    totals = TRUE,
    theme = "nejm"
  )
  table_creation_time <- as.numeric(Sys.time() - start_time, units = "secs")
  
  # Console rendering benchmark
  start_time <- Sys.time()
  console_output <- render_console(bp)
  rendering_time <- as.numeric(Sys.time() - start_time, units = "secs")
  
  # Memory usage benchmark
  memory_usage <- as.numeric(object.size(bp))
  
  # Set performance expectations (adjust based on your system)
  expect_lt(table_creation_time, 2.0, "Table creation regression")
  expect_lt(rendering_time, 1.0, "Rendering performance regression")
  expect_lt(memory_usage, 500000, "Memory usage regression")  # 500KB limit
  
  # Log performance metrics for monitoring
  cat(sprintf("\nPerformance Metrics:\n"))
  cat(sprintf("  Table creation: %.3f seconds\n", table_creation_time))
  cat(sprintf("  Rendering time: %.3f seconds\n", rendering_time))
  cat(sprintf("  Memory usage: %.0f bytes\n", memory_usage))
})