# =============================================================================
# Integration Tests - End-to-End Workflows
# =============================================================================

library(testthat)

test_that("Complete clinical trial workflow", {
  # Create realistic clinical trial data
  set.seed(42)
  n <- 300
  clinical_data <- data.frame(
    treatment = factor(
      sample(c("Placebo", "Drug A", "Drug B"), n, replace = TRUE, prob = c(0.4, 0.3, 0.3)),
      levels = c("Placebo", "Drug A", "Drug B")
    ),
    age = round(rnorm(n, 65, 12)),
    sex = factor(sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.6, 0.4))),
    race = factor(
      sample(c("White", "Black", "Hispanic", "Asian"), n, replace = TRUE, 
             prob = c(0.7, 0.15, 0.1, 0.05))
    ),
    bmi = round(rnorm(n, 28, 5), 1),
    diabetes = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.7, 0.3))),
    hypertension = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.6, 0.4))),
    center = factor(sample(paste("Center", 1:5), n, replace = TRUE)),
    baseline_score = round(rnorm(n, 50, 15), 1),
    followup_score = round(rnorm(n, 48, 18), 1)
  )
  
  # Add missing values realistically
  clinical_data$bmi[sample(1:n, 15)] <- NA
  clinical_data$baseline_score[sample(1:n, 8)] <- NA
  
  # Create comprehensive Table 1
  bp <- table1(
    treatment ~ age + sex + race + bmi + diabetes + hypertension + baseline_score,
    data = clinical_data,
    strata = "center",
    pvalue = TRUE,
    totals = TRUE,
    missing = TRUE,
    theme = "nejm",
    footnotes = list(
      variables = list(
        age = "Age at enrollment (years)",
        bmi = "Body mass index (kg/m²)",
        baseline_score = "Baseline efficacy score (0-100)"
      ),
      columns = list(
        "p.value" = "P-values from ANOVA for continuous variables, chi-square for categorical"
      ),
      general = list(
        "Data presented as mean ± SD or n (%)",
        "Missing values handled by listwise deletion"
      )
    )
  )
  
  # Verify table structure
  expect_s3_class(bp, "table1_blueprint")
  expect_true(bp$nrows > 20)  # Should have many rows due to stratification
  expect_true(bp$ncols >= 4)  # Treatment groups + totals + p-values
  expect_equal(bp$metadata$optimized, TRUE)
  
  # Test multiple output formats
  console_output <- render_console(bp)
  latex_output <- render_latex(bp)
  html_output <- render_html(bp)
  
  expect_type(console_output, "character")
  expect_type(latex_output, "character")
  expect_type(html_output, "character")
  
  expect_true(length(console_output) > 10)
  expect_true(any(grepl("tabular", latex_output)))
  expect_true(any(grepl("<table", html_output)))
})

test_that("Multi-dataset comparison workflow", {
  # Test with multiple built-in R datasets
  datasets <- list(
    mtcars = {
      data(mtcars)
      mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
      list(data = mtcars, formula = transmission ~ mpg + hp + wt)
    },
    iris = {
      data(iris)
      list(data = iris, formula = Species ~ Sepal.Length + Petal.Width)
    },
    chickwts = {
      data(chickwts)
      list(data = chickwts, formula = feed ~ weight)
    }
  )
  
  results <- list()
  
  for (dataset_name in names(datasets)) {
    dataset_info <- datasets[[dataset_name]]
    
    # Create table with consistent settings
    bp <- table1(
      form = dataset_info$formula,
      data = dataset_info$data,
      pvalue = TRUE,
      totals = TRUE,
      theme = "console"
    )
    
    expect_s3_class(bp, "table1_blueprint")
    expect_true(bp$nrows > 0)
    expect_true(bp$ncols > 0)
    
    results[[dataset_name]] <- bp
  }
  
  # Verify all datasets processed successfully
  expect_equal(length(results), length(datasets))
})

test_that("Theme consistency across complex tables", {
  # Create complex test data
  test_data <- mtcars
  test_data$transmission <- factor(ifelse(test_data$am == 1, "Manual", "Automatic"))
  test_data$engine_shape <- factor(ifelse(test_data$vs == 1, "V-shaped", "Straight"))
  test_data$cylinders <- factor(test_data$cyl)
  
  # Test all themes with the same complex table
  themes_to_test <- list_available_themes()
  theme_results <- list()
  
  for (theme_name in themes_to_test) {
    bp <- table1(
      transmission ~ mpg + hp + wt + cylinders,
      data = test_data,
      strata = "engine_shape",
      pvalue = TRUE,
      totals = TRUE,
      missing = TRUE,
      theme = theme_name,
      footnotes = list(
        variables = list(mpg = "Miles per gallon EPA rating"),
        general = list("Test dataset from mtcars")
      )
    )
    
    expect_s3_class(bp, "table1_blueprint")
    
    # Verify theme was applied
    expect_equal(bp$metadata$theme$theme_name, theme_name)
    
    # Test rendering with theme
    console_output <- render_console(bp)
    expect_type(console_output, "character")
    
    theme_results[[theme_name]] <- bp
  }
  
  # Verify different themes produce different configurations
  theme_configs <- lapply(theme_results, function(bp) bp$metadata$theme)
  
  # Check that decimal places vary across themes
  decimal_places <- sapply(theme_configs, function(tc) tc$decimal_places)
  expect_true(length(unique(decimal_places)) > 1,
             "Themes should have different decimal place settings")
})

test_that("Backward compatibility with original interface", {
  # Test that optimized version works with original parameters
  data(mtcars)
  mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
  
  # Original-style call (if table1 function exists)
  if (exists("table1", mode = "function")) {
    bp_original <- suppressWarnings(table1(transmission ~ mpg, data = mtcars))
    expect_s3_class(bp_original, "table1_blueprint")
  }
  
  # Optimized version with same parameters
  bp_optimized <- table1(transmission ~ mpg, data = mtcars)
  expect_s3_class(bp_optimized, "table1_blueprint")
  
  # Should have similar structure (dimensions might differ due to optimizations)
  if (exists("table1", mode = "function")) {
    bp_original <- suppressWarnings(table1(transmission ~ mpg, data = mtcars))
    expect_equal(class(bp_original), class(bp_optimized))
  }
})

test_that("Error recovery in complex scenarios", {
  # Create problematic data
  problematic_data <- mtcars
  problematic_data$transmission <- factor(ifelse(problematic_data$am == 1, "Manual", "Automatic"))
  
  # Add variables with issues
  problematic_data$all_na <- rep(NA, nrow(problematic_data))
  problematic_data$single_value <- rep("Same", nrow(problematic_data))
  problematic_data$extreme_outliers <- c(rep(1, 30), 1e10, -1e10)
  
  # Should handle gracefully with warnings
  bp <- suppressWarnings(
    table1(
      transmission ~ mpg + all_na + single_value + extreme_outliers,
      data = problematic_data,
      pvalue = TRUE
    )
  )
  
  expect_s3_class(bp, "table1_blueprint")
  expect_true(bp$nrows > 0)
  
  # Should be able to render despite problems
  output <- suppressWarnings(render_console(bp))
  expect_type(output, "character")
  expect_true(length(output) > 0)
})

test_that("Memory management in long-running workflows", {
  # Simulate a long-running analysis session
  initial_memory <- gc()
  
  # Create multiple tables with different configurations
  for (i in 1:20) {
    # Vary the data and settings
    test_data <- mtcars[sample(nrow(mtcars), 25, replace = TRUE), ]
    test_data$group <- factor(sample(c("A", "B"), nrow(test_data), replace = TRUE))
    
    bp <- table1(
      group ~ mpg + hp,
      data = test_data,
      theme = sample(list_available_themes(), 1),
      pvalue = sample(c(TRUE, FALSE), 1),
      totals = sample(c(TRUE, FALSE), 1)
    )
    
    # Occasionally render
    if (i %% 5 == 0) {
      output <- render_console(bp)
    }
    
    # Force garbage collection periodically
    if (i %% 10 == 0) {
      gc()
    }
  }
  
  final_memory <- gc()
  
  # Memory should not have grown excessively
  memory_growth <- (final_memory["Vcells", "used"] - initial_memory["Vcells", "used"]) / 
                   initial_memory["Vcells", "used"]
  
  expect_lt(abs(memory_growth), 3.0,
           "Excessive memory growth in long-running workflow")
})

test_that("Cross-platform consistency", {
  # Test that results are consistent regardless of platform differences
  data(mtcars)
  mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
  
  # Create table with deterministic settings
  bp <- table1(
    transmission ~ mpg + hp,
    data = mtcars,
    theme = "nejm",
    pvalue = TRUE
  )
  
  # Basic structure should be consistent
  expect_s3_class(bp, "table1_blueprint")
  expect_equal(bp$ncols, 4L)  # variables, Manual, Automatic, p-value
  expect_true(bp$nrows >= 2)  # At least mpg and hp rows
  
  # Rendering should work
  console_output <- render_console(bp)
  latex_output <- render_latex(bp)
  
  expect_type(console_output, "character")
  expect_type(latex_output, "character")
  expect_true(all(nchar(console_output) > 0))
  expect_true(any(grepl("\\\\", latex_output)))  # LaTeX commands present
})

test_that("Integration with external data processing", {
  # Test integration with common data processing workflows
  
  # dplyr-style operations (if available)
  test_data <- mtcars
  test_data$transmission <- factor(ifelse(test_data$am == 1, "Manual", "Automatic"))
  test_data$mpg_category <- factor(ifelse(test_data$mpg > median(test_data$mpg), 
                                         "High", "Low"))
  
  # Filter data
  high_hp <- test_data[test_data$hp > 100, ]
  
  # Create table with processed data
  bp <- table1(
    transmission ~ mpg + hp + mpg_category,
    data = high_hp,
    pvalue = TRUE,
    theme = "jama"
  )
  
  expect_s3_class(bp, "table1_blueprint")
  expect_true(nrow(high_hp) < nrow(test_data))  # Verify filtering worked
  
  # Should handle derived variables correctly
  expect_true(bp$nrows > 3)  # At least mpg, hp, mpg_category rows
})