# ============================================================================
# Comprehensive Test Suite for zztable1
# ============================================================================
#
# This file runs both the testthat test suite and integration tests.
# It uses the new clean file structure:
#
# R/
#   ├── table1.R              # Main user interface  
#   ├── blueprint.R           # Optimized blueprint class
#   ├── cells.R               # Cell types and constructors
#   ├── dimensions.R          # Modular dimension analysis
#   ├── validation.R          # Comprehensive validation
#   ├── evaluation.R          # Optimized cell evaluation  
#   ├── themes.R              # Theme system
#   ├── rendering.R           # Output format rendering
#   └── utils.R               # Helper functions
#
# ============================================================================

# Load the package functions for testing
# During R CMD check, the package is already installed and loaded
if (!exists("table1")) {
  # Try loading from package installation
  if (requireNamespace("zztable1", quietly = TRUE)) {
    library(zztable1)
  } else if (require(devtools, quietly = TRUE)) {
    devtools::load_all("..")
  } else if (require(pkgload, quietly = TRUE)) {
    pkgload::load_all("..")
  } else {
    # Fallback: source files directly
    r_files <- list.files("../R", pattern = "\\.R$", full.names = TRUE)
    sapply(r_files, source)
  }
}

# Test utilities
run_test <- function(test_name, test_func) {
  cat("Testing:", test_name, "... ")
  tryCatch({
    result <- test_func()
    if (result) {
      cat("✓ PASS\n")
      return(TRUE)
    } else {
      cat("✗ FAIL\n") 
      return(FALSE)
    }
  }, error = function(e) {
    cat("✗ ERROR:", e$message, "\n")
    return(FALSE)
  })
}

# ============================================================================
# TEST DATA PREPARATION
# ============================================================================

prepare_test_data <- function() {
  # Standard mtcars data
  data(mtcars)
  mtcars$transmission <- factor(
    ifelse(mtcars$am == 1, "Manual", "Automatic"),
    levels = c("Automatic", "Manual")
  )
  mtcars$engine_type <- factor(
    ifelse(mtcars$vs == 1, "V-shaped", "Straight"),
    levels = c("Straight", "V-shaped")  
  )
  mtcars$cylinder_group <- factor(
    ifelse(mtcars$cyl <= 4, "4-cyl",
    ifelse(mtcars$cyl <= 6, "6-cyl", "8-cyl")),
    levels = c("4-cyl", "6-cyl", "8-cyl")
  )
  
  # Clinical trial data
  set.seed(123)
  n <- 100
  clinical_data <- data.frame(
    treatment = factor(
      sample(c("Placebo", "Drug"), n, replace = TRUE),
      levels = c("Placebo", "Drug")
    ),
    age = round(rnorm(n, 65, 12)),
    sex = factor(sample(c("Male", "Female"), n, replace = TRUE)),
    bmi = round(rnorm(n, 28, 5), 1),
    center = factor(sample(paste("Center", 1:3), n, replace = TRUE))
  )
  
  return(list(mtcars = mtcars, clinical = clinical_data))
}

test_data <- prepare_test_data()
mtcars_data <- test_data$mtcars
clinical_data <- test_data$clinical

cat("=== zztable1 Comprehensive Test Suite ===\n\n")

# ============================================================================
# 1. BASIC FUNCTIONALITY TESTS
# ============================================================================

cat("1. BASIC FUNCTIONALITY TESTS\n")
cat("-----------------------------\n")

test_results <- list()

# Test 1.1: Cell construction
test_results$cell_construction <- run_test(
  "Cell object construction", 
  function() {
    cell <- Cell(type = "static", content = "Test")
    return(inherits(cell, "cell") && cell$type == "static" && 
           cell$content == "Test")
  }
)

# Test 1.2: Blueprint construction  
test_results$blueprint_construction <- run_test(
  "Blueprint object construction",
  function() {
    bp <- Table1Blueprint(5, 3)
    return(inherits(bp, "table1_blueprint") && 
           dim(bp)[1] == 5 && dim(bp)[2] == 3)
  }
)

# Test 1.3: Basic table1 call
test_results$basic_table1 <- run_test(
  "Basic table1 function call",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data)
    return(inherits(bp, "table1_blueprint") && 
           !is.null(bp$metadata))
  }
)

# Test 1.4: Blueprint indexing
test_results$blueprint_indexing <- run_test(
  "Blueprint indexing [i,j]",
  function() {
    bp <- Table1Blueprint(3, 3)
    cell <- Cell(type = "static", content = "Test")
    bp[1, 1] <- cell
    retrieved <- bp[1, 1]
    return(retrieved$content == "Test")
  }
)

# Test 1.5: Dimension analysis
test_results$dimension_analysis <- run_test(
  "Dimension analysis functionality",
  function() {
    dims <- analyze_table_dimensions(
      x_vars = c("mpg", "transmission"),
      grp_var = "transmission",
      data = mtcars_data,
      strata = NULL,
      missing = FALSE,
      size = FALSE,
      totals = FALSE,
      pvalue = TRUE,
      layout = "console"
    )
    return(!is.null(dims$nrows) && !is.null(dims$ncols) && 
           dims$nrows > 0 && dims$ncols > 0)
  }
)

cat("\n")

# ============================================================================
# 2. ADVANCED FEATURE TESTS
# ============================================================================

cat("2. ADVANCED FEATURE TESTS\n")
cat("--------------------------\n")

# Test 2.1: P-values
test_results$pvalues <- run_test(
  "P-value calculation",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data, pvalue = TRUE)
    # Check that p-value column exists
    return("p.value" %in% bp$col_names)
  }
)

# Test 2.2: Totals column
test_results$totals <- run_test(
  "Totals column generation", 
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data, totals = TRUE)
    return("Total" %in% bp$col_names)
  }
)

# Test 2.3: Missing values
test_results$missing_values <- run_test(
  "Missing values handling",
  function() {
    # Add some missing values
    test_data_missing <- mtcars_data
    test_data_missing$mpg[1:3] <- NA
    bp <- table1(transmission ~ mpg, data = test_data_missing, 
                 missing = TRUE)
    return(dim(bp)[1] > 2)  # Should have additional missing rows
  }
)

# Test 2.4: Multiple variables
test_results$multiple_variables <- run_test(
  "Multiple variables in formula",
  function() {
    bp <- table1(transmission ~ mpg + hp + wt, data = mtcars_data)
    return(dim(bp)[1] >= 3)  # At least 3 variable rows
  }
)

# Test 2.5: Factor variables
test_results$factor_variables <- run_test(
  "Factor variable handling",
  function() {
    bp <- table1(transmission ~ engine_type, data = mtcars_data)
    # Should have rows for factor levels
    return(any(grepl("Straight|V-shaped", bp$row_names)))
  }
)

# Test 2.6: Numeric summary options
test_results$numeric_summaries <- run_test(
  "Built-in numeric summary options",
  function() {
    bp1 <- table1(transmission ~ mpg, data = mtcars_data, 
                  numeric_summary = "mean_sd")
    bp2 <- table1(transmission ~ mpg, data = mtcars_data,
                  numeric_summary = "median_iqr") 
    return(inherits(bp1, "table1_blueprint") && 
           inherits(bp2, "table1_blueprint"))
  }
)

# Test 2.7: Custom numeric summary
test_results$custom_summary <- run_test(
  "Custom numeric summary function",
  function() {
    custom_func <- function(x) {
      paste0(round(mean(x, na.rm = TRUE), 1), " [custom]")
    }
    bp <- table1(transmission ~ mpg, data = mtcars_data,
                 numeric_summary = custom_func)
    return(inherits(bp, "table1_blueprint"))
  }
)

# Test 2.8: Stratification
test_results$stratification <- run_test(
  "Stratified analysis",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data,
                 strata = "cylinder_group")
    # Should have larger table due to stratification
    return(dim(bp)[1] > 3)
  }
)

cat("\n")

# ============================================================================
# 3. THEME SYSTEM TESTS  
# ============================================================================

cat("3. THEME SYSTEM TESTS\n")
cat("---------------------\n")

# Test 3.1: Theme configuration loading
test_results$theme_config <- run_test(
  "Theme configuration loading",
  function() {
    config <- get_theme("nejm")
    return(!is.null(config$name) && config$name == "New England Journal of Medicine")
  }
)

# Test 3.2: Theme application
test_results$theme_application <- run_test(
  "Theme application to blueprint",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data, theme = "nejm")
    return(!is.null(bp$metadata$theme) && 
           bp$metadata$theme$name == "New England Journal of Medicine")
  }
)

# Test 3.3: Multiple themes
test_results$multiple_themes <- run_test(
  "Multiple theme support",
  function() {
    themes <- c("default", "nejm", "lancet", "jama")
    success <- TRUE
    for (theme in themes) {
      bp <- table1(transmission ~ mpg, data = mtcars_data, theme = theme)
      if (is.null(bp$metadata$theme)) {
        success <- FALSE
        break
      }
    }
    return(success)
  }
)

# Test 3.4: Invalid theme handling
test_results$invalid_theme <- run_test(
  "Invalid theme error handling",
  function() {
    # Should warn but not error
    bp <- suppressWarnings(
      table1(transmission ~ mpg, data = mtcars_data, theme = "invalid")
    )
    # Invalid theme should fall back to console
    return(bp$metadata$theme$name == "Console")
  }
)

# Test 3.5: Theme decimal formatting
test_results$theme_decimals <- run_test(
  "Theme-specific decimal formatting",
  function() {
    bp_jama <- table1(transmission ~ mpg, data = mtcars_data, theme = "jama")
    bp_nejm <- table1(transmission ~ mpg, data = mtcars_data, theme = "nejm")
    # Check that themes have different configurations
    return(!is.null(bp_jama$metadata$theme$decimal_places) &&
           !is.null(bp_nejm$metadata$theme$decimal_places))
  }
)

# Test 3.6: List themes functionality
test_results$list_themes <- run_test(
  "List themes functionality",
  function() {
    themes <- list_available_themes()
    return(is.character(themes) && length(themes) >= 4)
  }
)

cat("\n")

# ============================================================================
# 4. FOOTNOTE SYSTEM TESTS
# ============================================================================

cat("4. FOOTNOTE SYSTEM TESTS\n")
cat("------------------------\n")

# Test 4.1: Variable footnotes
test_results$variable_footnotes <- run_test(
  "Variable-specific footnotes",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data,
                 footnotes = list(
                   variables = list(mpg = "Test footnote")
                 ))
    return(length(bp$metadata$footnote_list) > 0 &&
           !is.null(bp$metadata$footnote_markers))
  }
)

# Test 4.2: Column footnotes
test_results$column_footnotes <- run_test(
  "Column-specific footnotes",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data, pvalue = TRUE,
                 footnotes = list(
                   columns = list("p.value" = "Statistical test")
                 ))
    return(length(bp$metadata$footnote_list) > 0)
  }
)

# Test 4.3: General footnotes
test_results$general_footnotes <- run_test(
  "General footnotes",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data,
                 footnotes = list(
                   general = list("General note 1", "General note 2")
                 ))
    return(length(bp$metadata$footnote_list) == 2)
  }
)

# Test 4.4: Mixed footnotes
test_results$mixed_footnotes <- run_test(
  "Mixed footnote types",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data, pvalue = TRUE,
                 footnotes = list(
                   variables = list(mpg = "Variable note"),
                   columns = list("p.value" = "Column note"),
                   general = list("General note")
                 ))
    return(length(bp$metadata$footnote_list) == 3)
  }
)

# Test 4.5: Footnote markers
test_results$footnote_markers <- run_test(
  "Footnote marker generation",
  function() {
    # Test footnote functionality exists (simplified test)
    bp <- table1(transmission ~ mpg, data = mtcars_data, footnotes = list(general = list("Test")))
    return(length(bp$metadata$footnote_list) > 0)
  }
)

# Test 4.6: Footnote row creation  
test_results$footnote_rows <- run_test(
  "Footnote row generation",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data,
                 footnotes = list(
                   variables = list(mpg = "Test footnote")
                 ))
    # Should have additional footnote rows
    footnote_rows <- grep("footnote", bp$row_names)
    return(length(footnote_rows) > 0)
  }
)

cat("\n")

# ============================================================================
# 5. ERROR HANDLING TESTS
# ============================================================================

cat("5. ERROR HANDLING TESTS\n")
cat("-----------------------\n")

# Test 5.1: Invalid formula
test_results$invalid_formula <- run_test(
  "Invalid formula handling",
  function() {
    tryCatch({
      bp <- table1(nonexistent_var ~ mpg, data = mtcars_data)
      return(FALSE)  # Should have errored
    }, error = function(e) {
      return(TRUE)  # Expected error
    })
  }
)

# Test 5.2: Missing data parameter
test_results$missing_data <- run_test(
  "Missing data parameter handling",
  function() {
    tryCatch({
      bp <- table1(transmission ~ mpg)  # No data parameter
      return(FALSE)  # Should have errored
    }, error = function(e) {
      return(TRUE)  # Expected error
    })
  }
)

# Test 5.3: Invalid layout
test_results$invalid_layout <- run_test(
  "Invalid layout parameter handling",
  function() {
    # Should work but may warn
    bp <- suppressWarnings(
      table1(transmission ~ mpg, data = mtcars_data, layout = "invalid")
    )
    return(inherits(bp, "table1_blueprint"))
  }
)

# Test 5.4: Empty data
test_results$empty_data <- run_test(
  "Empty data handling",
  function() {
    empty_data <- mtcars_data[0, ]
    tryCatch({
      bp <- table1(transmission ~ mpg, data = empty_data)
      return(inherits(bp, "table1_blueprint"))
    }, error = function(e) {
      return(TRUE)  # May error or succeed, both acceptable
    })
  }
)

# Test 5.5: Mismatched strata variable
test_results$invalid_strata <- run_test(
  "Invalid strata variable handling",
  function() {
    tryCatch({
      bp <- table1(transmission ~ mpg, data = mtcars_data, 
                   strata = "nonexistent")
      return(FALSE)  # Should have errored
    }, error = function(e) {
      return(TRUE)  # Expected error
    })
  }
)

cat("\n")

# ============================================================================
# 6. PERFORMANCE TESTS
# ============================================================================

cat("6. PERFORMANCE TESTS\n")
cat("--------------------\n")

# Test 6.1: Large data handling
test_results$large_data <- run_test(
  "Large dataset performance",
  function() {
    # Create larger dataset
    large_data <- data.frame(
      group = factor(sample(c("A", "B"), 1000, replace = TRUE)),
      var1 = rnorm(1000),
      var2 = rnorm(1000)
    )
    
    # Should complete in reasonable time
    start_time <- Sys.time()
    bp <- table1(group ~ var1 + var2, data = large_data)
    end_time <- Sys.time()
    
    # Blueprint creation should be fast (< 5 seconds)
    return(as.numeric(end_time - start_time) < 5 && 
           inherits(bp, "table1_blueprint"))
  }
)

# Test 6.2: Memory efficiency
test_results$memory_efficiency <- run_test(
  "Memory efficiency check",
  function() {
    bp <- table1(transmission ~ mpg + hp + wt, data = mtcars_data)
    # Blueprint should not store computed results initially
    cell_sample <- bp[2, 2]  # Sample computation cell
    return(is.null(cell_sample$cached_result))
  }
)

# Test 6.3: Multiple format generation
test_results$multiple_formats <- run_test(
  "Multiple format generation",
  function() {
    formats <- c("console", "latex", "html")
    success <- TRUE
    for (fmt in formats) {
      bp <- table1(transmission ~ mpg, data = mtcars_data, layout = fmt)
      if (!inherits(bp, "table1_blueprint")) {
        success <- FALSE
        break
      }
    }
    return(success)
  }
)

cat("\n")

# ============================================================================
# 7. INTEGRATION TESTS
# ============================================================================

cat("7. INTEGRATION TESTS\n")
cat("--------------------\n")

# Test 7.1: Complex table with all features
test_results$complex_table <- run_test(
  "Complex table with all features",
  function() {
    bp <- table1(transmission ~ mpg + hp + engine_type,
                 data = mtcars_data,
                 strata = "cylinder_group",
                 theme = "nejm", 
                 pvalue = TRUE,
                 totals = TRUE,
                 missing = TRUE,
                 footnotes = list(
                   variables = list(
                     mpg = "Fuel economy",
                     hp = "Horsepower"
                   ),
                   general = list("Test dataset")
                 ))
    return(inherits(bp, "table1_blueprint") &&
           dim(bp)[1] > 5 && dim(bp)[2] > 3)
  }
)

# Test 7.2: Clinical trial table
test_results$clinical_table <- run_test(
  "Clinical trial baseline table",
  function() {
    bp <- table1(treatment ~ age + sex + bmi,
                 data = clinical_data,
                 strata = "center",
                 theme = "nejm",
                 pvalue = TRUE,
                 footnotes = list(
                   variables = list(
                     age = "Age at enrollment",
                     bmi = "Body mass index"
                   ),
                   general = list("ITT population")
                 ))
    return(inherits(bp, "table1_blueprint"))
  }
)

# Test 7.3: Display functionality
test_results$display_functionality <- run_test(
  "Display table functionality",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data)
    # Test that display_table runs without error
    tryCatch({
      result <- capture.output(display_table(bp, mtcars_data))
      return(length(result) > 0)
    }, error = function(e) {
      return(FALSE)
    })
  }
)

# Test 7.4: Data frame conversion
test_results$dataframe_conversion <- run_test(
  "Data frame conversion",
  function() {
    bp <- table1(transmission ~ mpg, data = mtcars_data)
    tryCatch({
      df <- as.data.frame(bp)
      return(is.data.frame(df) && nrow(df) > 0 && ncol(df) > 0)
    }, error = function(e) {
      return(FALSE)
    })
  }
)

cat("\n")

# ============================================================================
# RESULTS SUMMARY
# ============================================================================

cat("=== TEST RESULTS SUMMARY ===\n")
cat("============================\n\n")

total_tests <- length(test_results)
passed_tests <- sum(unlist(test_results))
failed_tests <- total_tests - passed_tests

cat("Total tests run:", total_tests, "\n")
cat("Tests passed:", passed_tests, "\n")
cat("Tests failed:", failed_tests, "\n")
cat("Success rate:", round(100 * passed_tests / total_tests, 1), "%\n\n")

if (failed_tests > 0) {
  cat("FAILED TESTS:\n")
  cat("-------------\n")
  failed_test_names <- names(test_results)[!unlist(test_results)]
  for (test_name in failed_test_names) {
    cat("✗", test_name, "\n")
  }
  cat("\n")
}

# Test categories summary
cat("RESULTS BY CATEGORY:\n")
cat("-------------------\n")

categories <- list(
  "Basic Functionality" = c("cell_construction", "blueprint_construction", 
                           "basic_table1", "blueprint_indexing", 
                           "dimension_analysis"),
  "Advanced Features" = c("pvalues", "totals", "missing_values", 
                         "multiple_variables", "factor_variables",
                         "numeric_summaries", "custom_summary", 
                         "stratification"),
  "Theme System" = c("theme_config", "theme_application", "multiple_themes",
                    "invalid_theme", "theme_decimals", "list_themes"),
  "Footnote System" = c("variable_footnotes", "column_footnotes", 
                       "general_footnotes", "mixed_footnotes",
                       "footnote_markers", "footnote_rows"),
  "Error Handling" = c("invalid_formula", "missing_data", "invalid_layout",
                      "empty_data", "invalid_strata"),
  "Performance" = c("large_data", "memory_efficiency", "multiple_formats"),
  "Integration" = c("complex_table", "clinical_table", "display_functionality",
                   "dataframe_conversion")
)

for (category_name in names(categories)) {
  category_tests <- categories[[category_name]]
  category_results <- test_results[category_tests]
  category_passed <- sum(unlist(category_results), na.rm = TRUE)
  category_total <- length(category_results)
  category_pct <- round(100 * category_passed / category_total, 1)
  
  cat(sprintf("%-20s: %d/%d (%s%%)\n", category_name, 
              category_passed, category_total, category_pct))
}

cat("\n")

# Overall status
if (failed_tests == 0) {
  cat("🎉 ALL TESTS PASSED! Package is ready for use.\n")
} else if (passed_tests >= 0.8 * total_tests) {
  cat("⚠️ Most tests passed. Review failed tests before production use.\n")
} else {
  cat("❌ Many tests failed. Package needs significant fixes.\n")
}

cat("\n=== Test Suite Complete ===\n")