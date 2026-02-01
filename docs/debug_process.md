 Step 1: Reproduce the Issue

  First, let's create a test case to reproduce the strata issue:

  # Load the package in development mode
  devtools::load_all()

  # Create test data with stratification variable
  set.seed(123)
  test_data <- data.frame(
    arm = factor(rep(c("Treatment", "Placebo"), each = 50)),
    age = rnorm(100, mean = 45, sd = 15),
    sex = factor(sample(c("Male", "Female"), 100, replace = TRUE)),
    site = factor(sample(c("Site1", "Site2", "Site3"), 100, replace = TRUE))
  )

  # Try to reproduce the strata issue
  result <- table1(form = arm ~ age + sex, data = test_data, strata = "site")
  print(result)

  Step 2: Set Up Debugging Environment

  # Load package with debugging capabilities
  devtools::load_all()

  # Set up debugging on the main function
  debugonce(table1.formula)

  # Or debug specific internal functions if needed
  debugonce(stratify)
  debugonce(build)

  Step 3: Identify the Root Cause

  Run the problematic code in debug mode:

  # This will trigger the debugger
  result <- table1(form = arm ~ age + sex, data = test_data, strata = "site")

  # In the debugger, examine variables:
  # - Check if strata variable exists in data
  # - Verify strata_logic is set correctly
  # - Check dat0 construction
  # - Examine stratify function inputs

  Key areas to check in table1.formula():
  - Line 459: dat0 <- data[c(x_vars, grp, strata)] - ensure strata is included
  - Line 481-485: stratify() call - verify parameters are correct
  - Line 483: data[[grp]] vs dat0[[grp]] - potential data source mismatch

  Step 4: Fix the Issue

  Based on the code analysis, the likely issue is in table1.formula() around lines 483-484:

  # Current problematic code (lines 483-484):
  tab0 <- stratify(
    x = dat0[x_vars], grp = data[[grp]],  # <-- Issue: mixed data sources
    strat = data[[strata]], size = size, totals = totals, missing = missing, ...
  )

  # Fix: Use consistent data source
  tab0 <- stratify(
    x = dat0[x_vars], grp = dat0[[grp]],  # <-- Fix: use dat0 consistently
    strat = dat0[[strata]], size = size, totals = totals, missing = missing, ...
  )

  Step 5: Write/Update Tests

  Create comprehensive tests for strata functionality:

  # Add to tests/testthat/test-zztable1.R

  test_that("strata functionality works correctly", {
    # Test data
    test_data <- data.frame(
      arm = factor(rep(c("Treatment", "Placebo"), each = 20)),
      age = rnorm(40, mean = 45, sd = 10),
      sex = factor(sample(c("Male", "Female"), 40, replace = TRUE)),
      site = factor(sample(c("Site1", "Site2"), 40, replace = TRUE))
    )

    # Test basic stratification
    result <- table1(form = arm ~ age + sex, data = test_data, strata = "site")

    # Verify result structure
    expect_true(is.data.frame(result))
    expect_true("variables" %in% names(result))
    expect_true("code" %in% names(result))

    # Check for strata headers (code = 5)
    expect_true(any(result$code == 5))

    # Test with missing values
    test_data$age[1:5] <- NA
    result_missing <- table1(form = arm ~ age + sex, data = test_data,
                            strata = "site", missing = TRUE)
    expect_true(is.data.frame(result_missing))

    # Test with totals
    result_totals <- table1(form = arm ~ age + sex, data = test_data,
                           strata = "site", totals = TRUE)
    expect_true(is.data.frame(result_totals))
  })

  Step 6: Testing Commands

  # Run specific tests
  Rscript -e "devtools::test()"

  # Run tests with verbose output
  Rscript -e "testthat::test_dir('tests/testthat', reporter = 'progress')"

  # Test the fix interactively
  Rscript -e "devtools::load_all(); source('test_strata_fix.R')"

  # Run R CMD check
  R CMD check --as-cran .

  Step 7: Document and Build

  # Update documentation
  Rscript -e "devtools::document()"

  # Build package
  Rscript -e "devtools::build()"

  # Install locally to test
  Rscript -e "devtools::install()"

  Step 8: Git Workflow

  # Check current status
  git status

  # Add changes
  git add R/zztable1.R tests/testthat/test-zztable1.R

  # Create detailed commit
  git commit -m "Fix strata functionality in table1.formula

  - Fixed inconsistent data source usage in stratify() call
  - Changed data[[grp]] and data[[strata]] to dat0[[grp]] and dat0[[strata]]
  - Ensures processed data (with factor conversions) is used consistently
  - Added comprehensive tests for strata functionality
  - Tests cover basic stratification, missing values, and totals options

  🤖 Generated with Claude Code

  Co-Authored-By: Claude <noreply@anthropic.com>"

  # Push to remote
  git push origin bugfix-digits

  Step 9: Verification

  # Pull and test on fresh environment
  git pull
  Rscript -e "devtools::load_all(); devtools::test()"

  # Test the fixed functionality
  Rscript -e "
  devtools::load_all()
  test_data <- data.frame(
    arm = factor(rep(c('Treatment', 'Placebo'), each = 50)),
    age = rnorm(100, mean = 45, sd = 15),
    sex = factor(sample(c('Male', 'Female'), 100, replace = TRUE)),
    site = factor(sample(c('Site1', 'Site2'), 100, replace = TRUE))
  )
  result <- table1(form = arm ~ age + sex, data = test_data, strata = 'site')
  print(result)
  "

  Common Debugging Tips

  1. Use browser() in code to set breakpoints
  2. Check variable types with class() and str()
  3. Verify data dimensions with dim() and nrow()
  4. Test with minimal examples first
  5. Check for NA/missing values that might cause issues
  6. Use traceback() after errors to see call stack

  This systematic approach will help you identify, fix, test, and deploy the strata functionality issue effectively.
