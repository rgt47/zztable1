# Documentation Validation Script
# Tests all examples from updated documentation to ensure accuracy

# Load package functions
source("tests/testthat/helper-setup.R")

cat("=== ZZTABLE1_NEXTGEN DOCUMENTATION VALIDATION ===\n\n")

# Test 1: Cell type validation
cat("1. Testing Cell Types (should be 3 types: content, computation, separator)\n")
tryCatch({
  # Valid cell types
  cell1 <- Cell(type = "content", content = "Test")
  cell2 <- Cell(type = "computation", 
               data_subset = expression(mtcars$mpg), 
               computation = expression(mean(x)))
  cell3 <- Cell(type = "separator", content = "---")
  cat("   ✓ All 3 valid cell types work correctly\n")
  
  # Invalid cell type (should fail)
  tryCatch({
    Cell(type = "static", content = "Test")
    cat("   ❌ ERROR: 'static' type should be rejected but was accepted\n")
  }, error = function(e) {
    if (grepl("must be one of: content, computation, separator", e$message)) {
      cat("   ✓ Invalid 'static' type correctly rejected\n")
    } else {
      cat("   ❌ Wrong error message for invalid type\n")
    }
  })
}, error = function(e) {
  cat("   ❌ Cell type validation failed:", e$message, "\n")
})

# Test 2: table1 function signature
cat("\n2. Testing table1() function signature\n")
tryCatch({
  mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
  bp <- table1(transmission ~ mpg + hp, data = mtcars, theme = "console", pvalue = TRUE)
  cat("   ✓ table1() function works with documented parameters\n")
  cat("   ✓ Function returns:", class(bp)[1], "object\n")
}, error = function(e) {
  cat("   ❌ table1() function failed:", e$message, "\n")
})

# Test 3: Theme system
cat("\n3. Testing theme system\n")
tryCatch({
  themes <- list_available_themes()
  cat("   ✓ list_available_themes() works, found", length(themes), "themes\n")
  cat("   ✓ Available themes:", paste(themes, collapse = ", "), "\n")
  
  # Test if we have at least 5 themes as expected by tests
  if (length(themes) >= 5) {
    cat("   ✓ Theme count meets test requirements (≥5)\n")
  } else {
    cat("   ❌ Only", length(themes), "themes found, tests expect ≥5\n")
  }
}, error = function(e) {
  cat("   ❌ Theme system test failed:", e$message, "\n")
})

# Test 4: Rendering system
cat("\n4. Testing rendering system\n")
tryCatch({
  bp <- table1(transmission ~ mpg, data = mtcars)
  console_out <- render_console(bp)
  cat("   ✓ Console rendering works\n")
  
  latex_out <- render_latex(bp)
  cat("   ✓ LaTeX rendering works\n")
  
  html_out <- render_html(bp)
  cat("   ✓ HTML rendering works\n")
}, error = function(e) {
  cat("   ❌ Rendering system test failed:", e$message, "\n")
})

# Test 5: Documentation examples from README
cat("\n5. Testing README examples\n")
tryCatch({
  # Basic example
  bp <- table1(transmission ~ mpg + hp + wt, data = mtcars)
  cat("   ✓ Basic README example works\n")
  
  # Themed example  
  bp_nejm <- table1(transmission ~ mpg + hp + wt, 
                   data = mtcars,
                   theme = "nejm",
                   pvalue = TRUE)
  cat("   ✓ Themed README example works\n")
}, error = function(e) {
  cat("   ❌ README example failed:", e$message, "\n")
})

cat("\n=== VALIDATION COMPLETE ===\n")
cat("If all tests show ✓, the documentation is accurate and functional.\n")