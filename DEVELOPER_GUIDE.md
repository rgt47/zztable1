# zztable1_nextgen Developer's Quick Reference

**Last Updated:** December 5, 2025
**For Phases:** 5 and beyond
**Target Audience:** Developers extending the package

---

## Quick Navigation

- **Getting Started:** Architecture, setup, running tests
- **Common Tasks:** Adding features, fixing bugs, optimizing performance
- **Code Patterns:** S3 dispatch, optional dependencies, parallel processing
- **Testing:** Test structure, writing tests, running test suite
- **Documentation:** Docstring format, vignette structure, updating guides

---

## Part 1: Project Architecture

### Core Components Overview

```
zztable1_nextgen/
├── R/
│   ├── table1.R                    # Main user-facing function
│   ├── blueprint.R                 # Blueprint object creation & management
│   ├── cells.R                     # Cell evaluation with S3 dispatch
│   ├── rendering.R                # Multi-format output rendering
│   ├── themes.R                    # Theme system (consolidated)
│   ├── dimensions.R                # Dynamic dimension calculation
│   ├── validation_consolidated.R   # Input validation
│   ├── error_handling.R            # Optional rlang error handling
│   ├── parallel_processing.R       # Optional parallel framework
│   ├── theme_registry.R            # User theme registration system
│   ├── zzz.R                       # Package initialization hook
│   ├── utils.R                     # Utilities (data transformation, etc.)
│   └── ...                         # Other utility modules
│
├── tests/testthat/
│   ├── test-table1.R               # Core functionality
│   ├── test-theme-integration.R    # Theme system (171 tests)
│   ├── test-rendering.R            # Output formats
│   └── ...                         # Other tests
│
├── vignettes/
│   ├── zztable1_nextgen_guide.Rmd             # Package guide
│   ├── theming_system.Rmd                     # Theme documentation
│   ├── extending_themes.Rmd                   # Custom theme creation
│   ├── stratified_examples.Rmd                # Multi-stratum analysis
│   ├── toothgrowth_example.Rmd                # Detailed example
│   ├── customizing_statistics.Rmd             # Statistical options
│   └── dataset_examples.Rmd                   # Built-in dataset showcase
│
├── man/                            # Auto-generated documentation
├── DESCRIPTION                     # Package metadata
├── NAMESPACE                       # Exported functions
└── Documentation/
    ├── FINAL_COMPLETION_SUMMARY.txt
    ├── PHASE*_IMPROVEMENTS.md      # 1-4 phase documentation
    ├── IMPLEMENTATION_SUMMARY.md
    ├── TROUBLESHOOTING.md
    ├── PERFORMANCE_ANALYSIS.md
    ├── PHASE5_ROADMAP.md           # This roadmap
    └── Blueprint_Construction_Guide.md
```

### Data Flow Architecture

```
User Formula Input
        ↓
   table1() [R/table1.R]
        ↓
   Input Validation [R/validation_consolidated.R]
        ↓
   Parse Formula → Analyze Dimensions [R/dimensions.R]
        ↓
   Create Blueprint Object [R/blueprint.R]
        ↓
   Populate Cells with Computation Metadata [R/table1.R]
        ↓
   Sparse Storage in Environments (hash tables)
        ↓
   Cell Evaluation via S3 Dispatch [R/cells.R]
        ├─ evaluate_cell.cell_content()
        ├─ evaluate_cell.cell_computation()
        ├─ evaluate_cell.cell_statistic()
        └─ evaluate_cell.cell_pvalue()
        ↓
   Result Rendering [R/rendering.R]
        ├─ render_console()
        ├─ render_html()
        ├─ render_latex()
        └─ render_pipeline() [unified format-agnostic flow]
        ↓
   Theme Application [R/themes.R + R/rendering.R]
        ├─ Theme lookup
        ├─ CSS property mapping
        ├─ Format-specific styling
        └─ Result output
```

### Key Design Patterns

#### 1. Blueprint Object Structure

```r
blueprint <- list(
  # Metadata
  formula = formula_obj,
  data = data_frame,
  strata = strata_spec,
  metadata = list(
    nrows = 42,
    ncols = 5,
    theme = "nejm",
    test_specifications = list(...)
  ),

  # Sparse cell storage (environment as hash table)
  cells = new.env(),  # Contains cell_r1_c1, cell_r1_c2, etc.

  # Cell is list:
  # list(type = "content", content = "text")
  # OR
  # list(type = "computation", func = function(data) {...})
)
class(blueprint) <- "table1_blueprint"
```

#### 2. S3 Method Dispatch Pattern

**For adding new cell types in Phase 5+:**

```r
# Define new S3 class
new_cell_type <- list(
  type = "new_type",
  data_specification = ...,
  computation_function = function(data, ...) { ... },
  formatting_rules = list(...)
)
class(new_cell_type) <- c("cell_new_type", "cell", "list")

# Add S3 method for evaluation
evaluate_cell.cell_new_type <- function(cell, data, env, force_recalc) {
  # Implementation specific to this cell type
  result <- cell$computation_function(data)
  list(
    content = format_result(result, cell$formatting_rules),
    cached = FALSE
  )
}

# Automatic dispatch via:
evaluate_cell(cell, data, env)  # Automatically routes to .cell_new_type()
```

#### 3. Optional Dependency Pattern

**Used for rlang and parallel packages:**

```r
# Check availability
if (requireNamespace("package", quietly = TRUE)) {
  # Use enhanced feature
  package::function(...)
} else {
  # Fall back to base R
  fallback_function(...)
}
```

**Benefits:**
- Package works without optional deps
- Enhanced features when deps available
- No installation failures
- Clean, explicit code

#### 4. Rendering Pipeline Pattern

**Used in Phase 3 to unify output formats:**

```r
render_pipeline <- function(blueprint, theme, format, theme_name) {
  # 1. Setup phase (format-specific)
  setup_lines <- get_format_setup(format, theme)

  # 2. Header rendering (unified, with format dispatch)
  header_lines <- render_table_headers(blueprint, theme, format)

  # 3. Body rendering (unified)
  body_lines <- render_table_body(blueprint, theme, format)

  # 4. Cleanup (format-specific)
  cleanup_lines <- get_format_cleanup(format, theme)

  # 5. Combine all
  c(setup_lines, header_lines, body_lines, cleanup_lines)
}
```

---

## Part 2: Common Development Tasks

### Adding a New Output Format (Phase 6+)

**Example: Adding Markdown output**

**Step 1: Create render function**
```r
# In R/rendering.R
render_markdown <- function(blueprint, theme = "console", ...) {
  render_pipeline(
    blueprint = blueprint,
    theme = theme,
    format = "markdown",
    ...
  )
}

#' @export
render_markdown
```

**Step 2: Add format dispatch functions**
```r
# In R/rendering.R
get_format_setup.markdown <- function(theme) {
  list()  # No setup needed
}

get_table_headers.markdown <- function(blueprint, theme) {
  # Return markdown table header
  c(
    "| Variable | Value |",
    "|----------|-------|"
  )
}

get_format_cleanup.markdown <- function(theme) {
  list()  # No cleanup needed
}
```

**Step 3: Add to NAMESPACE**
```r
export(render_markdown)
```

**Step 4: Write tests**
```r
# In tests/testthat/test-rendering.R
test_that("markdown rendering works", {
  bp <- table1(~mpg + hp, data = mtcars, theme = "console")
  output <- render_markdown(bp)
  expect_true(length(output) > 0)
  expect_true(any(grepl("|", output, fixed = TRUE)))
})
```

### Adding a New Statistical Test (Phase 5+)

**Example: Adding Mann-Whitney U test**

**Step 1: Add test specification to validation/options**
```r
# In R/validation_consolidated.R
validate_inputs <- function(...) {
  # ...existing code...

  # Add to test validation
  valid_continuous_tests <- c(
    "ttest", "anova", "welch", "kruskal",
    "mann_whitney",  # NEW
    "moods_median"
  )

  if (!is.null(continuous_test)) {
    if (!continuous_test %in% valid_continuous_tests) {
      abort_or_stop(
        sprintf("Unknown test: %s", continuous_test),
        class = "unknown_test"
      )
    }
  }
}
```

**Step 2: Create test computation function**
```r
# In R/utils.R or new R/statistics.R
compute_mann_whitney_pvalue <- function(x, groups) {
  tryCatch(
    {
      result <- wilcox.test(x ~ groups)
      result$p.value
    },
    error = function(e) NA_real_
  )
}
```

**Step 3: Add to statistical dispatcher**
```r
# In R/cells.R (where cell computation happens)
compute_test_pvalue <- function(cell, data, test_type, formula_context) {
  switch(test_type,
    "mann_whitney" = compute_mann_whitney_pvalue(...),
    "moods_median" = compute_moods_median_test(...),
    # ... existing tests ...
  )
}
```

**Step 4: Add to user documentation**
```r
#' @param continuous_test Type of test for continuous variables
#'   \describe{
#'     \item{ttest}{Student's t-test (default)}
#'     \item{anova}{One-way ANOVA}
#'     \item{welch}{Welch's t-test}
#'     \item{kruskal}{Kruskal-Wallis test}
#'     \item{mann_whitney}{Mann-Whitney U test}
#'   }
```

### Implementing Parallel Processing Integration (Phase 5.1)

**Example: Parallel statistical calculations**

**Step 1: Create smart dispatcher**
```r
# In R/parallel_processing.R (extend existing)
compute_statistics_smart <- function(variables, data, strata) {
  num_calcs <- length(variables) * length(strata)

  if (can_use_parallel(num_calcs)) {
    compute_statistics_parallel(variables, data, strata)
  } else {
    compute_statistics_serial(variables, data, strata)
  }
}
```

**Step 2: Implement parallel variant**
```r
compute_statistics_parallel <- function(variables, data, strata) {
  num_cores <- detect_cores()

  if (.Platform$OS.type == "windows") {
    # Windows: parLapply
    cluster <- parallel::makeCluster(num_cores)
    on.exit(parallel::stopCluster(cluster))

    results <- parallel::parLapply(
      cluster,
      variables,
      function(var) {
        # Compute stats for each variable across all strata
        lapply(strata, function(s) {
          compute_var_stats(var, data, s)
        })
      }
    )
  } else {
    # Unix/Linux/Mac: mclapply
    results <- parallel::mclapply(
      variables,
      function(var) {
        lapply(strata, function(s) {
          compute_var_stats(var, data, s)
        })
      },
      mc.cores = num_cores
    )
  }

  # Restructure results for further processing
  restructure_stat_results(results)
}
```

**Step 3: Verify correctness**
```r
# Test that parallel and serial produce identical results
test_parallel_correctness <- function() {
  result_serial <- compute_statistics_serial(vars, data, strata)
  result_parallel <- compute_statistics_parallel(vars, data, strata)

  # Check equivalence
  all.equal(result_serial, result_parallel)
}
```

### Creating Custom Theme Distribution Package (Phase 5+)

**Structure of a theme package:**

```r
# Package: mythemepkg
# File: R/zzz.R

.onLoad <- function(libname, pkgname) {
  # Create custom themes
  corporate_theme <- list(
    name = "Corporate Blue",
    theme_name = "corporate_blue",
    author = "Your Company",
    version = "1.0.0",
    decimal_places = 2,
    css_properties = list(
      font_family = "Arial, sans-serif",
      header_background = "#003366",
      header_color = "#FFFFFF",
      row_striping = "#E8F0F8",
      border_color = "#CCCCCC"
    )
  )

  # Register in zztable1nextgen
  if (requireNamespace("zztable1nextgen", quietly = TRUE)) {
    zztable1nextgen::register_theme(corporate_theme)
  }
}
```

**Usage:**
```r
# Users just do:
library(mythemepkg)
# Theme automatically registered

# Then use:
table1(~age + sex, data = df, theme = "corporate_blue")
```

---

## Part 3: Testing Guidelines

### Test Structure

**All tests use testthat framework:**

```r
# File: tests/testthat/test-myfeature.R

test_that("descriptive test name", {
  # Setup
  data <- mtcars
  formula <- ~cyl + mpg

  # Execute
  result <- table1(formula, data = data)

  # Verify
  expect_true(inherits(result, "table1_blueprint"))
  expect_equal(result$metadata$nrows, expected_rows)
})
```

### Running Tests

```bash
# Run all tests
Rscript -e "devtools::test()"

# Run specific test file
Rscript -e "testthat::test_file('tests/testthat/test-myfeature.R')"

# Run with coverage
Rscript -e "covr::report(covr::package_coverage())"
```

### Writing Effective Tests

**Good test patterns:**

1. **Single responsibility**
   ```r
   test_that("numeric summary respects decimal_places", {
     # Only tests one thing
     result <- numeric_summary(data$age, 2)
     expect_equal(nchar(strsplit(result, " ")[[1]][1]), 4)
   })
   ```

2. **Clear assertions**
   ```r
   # GOOD:
   expect_equal(bp$metadata$nrows, 10)

   # BAD:
   expect_true(bp$metadata$nrows > 0)  # Too vague
   ```

3. **Isolated test data**
   ```r
   test_that("handles missing data", {
     # Create specific test data
     test_data <- data.frame(
       x = c(1, 2, NA, 4),
       g = c("A", "A", "B", "B")
     )

     # Test specific behavior
     result <- table1(~x, data = test_data)
     # Verify missing is handled
   })
   ```

### Testing Optional Dependencies

```r
test_that("rlang error handling works with and without rlang", {
  # Test works whether rlang installed or not
  expect_error(
    table1(bad_formula, data = mtcars),
    "formula"  # Check error message contains key term
  )
})
```

---

## Part 4: Code Style Guide

### Function Documentation (roxygen2)

```r
#' Brief description (one line)
#'
#' Longer description of what function does, providing context
#' and explaining the approach.
#'
#' @param param1 Description of param1
#' @param param2 Description of param2, default: `default_value`
#'
#' @return Description of what is returned
#'
#' @details
#' Additional details about implementation, assumptions, or
#' important behaviors.
#'
#' @examples
#' \dontrun{
#' # Example that shows typical usage
#' result <- my_function(data, param1 = TRUE)
#' }
#'
#' @keywords internal
#'
#' @export
my_function <- function(param1, param2 = default_value) {
  # Implementation
}
```

### Variable Naming Conventions

```r
# Functions: snake_case, descriptive
evaluate_cell()
render_pipeline()
create_theme_bundle()

# Variables: snake_case
num_rows
col_index
is_numeric_var

# Constants: UPPER_SNAKE_CASE
BUILTIN_THEMES <- c("console", "nejm", "lancet", "jama", "bmj")
DEFAULT_DECIMAL_PLACES <- 2

# Internal functions: .leading_dot
.create_builtin_themes()
.restructure_stat_results()

# S3 methods: function.class
evaluate_cell.cell_content()
print.theme_bundle()
```

### Error Handling Pattern

```r
# Use graceful fallback for optional dependencies
helper_function <- function(data, use_enhancement = TRUE) {
  if (use_enhancement && requireNamespace("optional_pkg", quietly = TRUE)) {
    # Use enhanced version with optional package
    result <- optional_pkg::fancy_function(data)
  } else {
    # Fallback to base R version
    result <- base_function(data)
  }
  result
}

# Use structured error classes
if (!is.data.frame(data)) {
  stop(
    "Expected data.frame, got ", class(data)[1],
    call. = FALSE
  )
}
```

---

## Part 5: Performance Optimization Checklist

Before submitting Phase 5+ work:

- [ ] Profile code with `profvis::profvis()` on realistic data
- [ ] Check for unnecessary loops (can they vectorize?)
- [ ] Look for redundant calculations (caching opportunity?)
- [ ] Verify memory efficiency (sparse storage maintained?)
- [ ] Benchmark against baseline (regression testing)
- [ ] Document performance characteristics
- [ ] Check for unnecessary dependencies in hot paths
- [ ] Verify parallel processing doesn't regress small tables

**Example profiling:**
```r
library(profvis)
profvis({
  data(mtcars)
  mtcars$g <- factor(rep(c("A", "B"), 16))
  for (i in 1:100) {
    bp <- table1(g ~ mpg + hp, data = mtcars)
    render_console(bp)
  }
})
```

---

## Part 6: Debugging Tips

### Inspecting Blueprint Objects

```r
# Create a blueprint
bp <- table1(~cyl + mpg, data = mtcars)

# Inspect structure
str(bp, max.level = 2)

# View metadata
bp$metadata

# List all cells (first 10)
cell_names <- ls(bp$cells, all.names = TRUE)
head(cell_names, 10)

# Inspect specific cell
cell <- bp$cells$cell_r2_c1
str(cell)

# Check if cell is computed
if (is.null(cell$cached_result)) {
  cat("Cell not yet evaluated\n")
} else {
  cat("Cached result:", cell$cached_result, "\n")
}
```

### Tracing Function Calls

```r
# Enable debugging for specific function
debug(table1)

# Run function (will enter debugger)
bp <- table1(~mpg + hp, data = mtcars)

# Or set trace points
trace(evaluate_cell, tracer = quote(cat("Evaluating cell\n")))

# Remove trace
untrace(evaluate_cell)
```

### Common Issues & Solutions

**Issue: "Cell not found" error**
```r
# Debug: Check cell naming convention
key <- sprintf("cell_r%d_c%d", row, col)
if (key %in% ls(bp$cells)) {
  cat("Cell exists\n")
} else {
  cat("Cell missing, available:", ls(bp$cells), "\n")
}
```

**Issue: Theme not applied**
```r
# Check theme lookup
theme_obj <- get_theme("mytheme")
if (is.null(theme_obj)) {
  cat("Theme not found, using default\n")
} else {
  cat("Theme loaded:", theme_obj$name, "\n")
}
```

**Issue: Parallel processing slower than serial**
```r
# Debug parallel threshold
small_table <- table1(~mpg, data = mtcars[1:10,])
can_use_parallel(10)  # FALSE (below threshold)

large_table <- table1(~mpg, data = mtcars[1:1000,])
can_use_parallel(1000)  # TRUE (above threshold)
```

---

## Part 7: Recommended Tools

### Development Tools
- **RStudio**: IDE with debugging support
- **devtools**: Package development utilities
- **roxygen2**: Documentation generation
- **testthat**: Testing framework

### Performance Tools
- **profvis**: Visual profiling
- **bench**: Benchmarking
- **memuse**: Memory profiling

### Code Quality
- **styler**: Code formatting
- **lintr**: Code linting
- **covr**: Code coverage

### Install All
```bash
Rscript -e "
install.packages(c('devtools', 'roxygen2', 'testthat', 'profvis', 'bench'))
"
```

---

## Part 8: Release Checklist for Phase 5+

Before submitting new phase:

- [ ] All new code follows style guide
- [ ] Documentation complete (roxygen + vignette)
- [ ] Tests written and passing (171+ tests expected)
- [ ] No regressions (all existing tests still pass)
- [ ] Performance verified (profiling done)
- [ ] CHANGELOG updated
- [ ] NAMESPACE updated if new exports
- [ ] DESCRIPTION updated if new dependencies
- [ ] README.md updated with new features
- [ ] Code reviewed (self-review at minimum)
- [ ] Version number bumped
- [ ] Backwards compatibility maintained

**Version bumping:**
```
Current: 1.0.0 (Phase 4 complete)
Phase 5: 1.1.0 (new features, backward compatible)
Phase 6: 1.2.0 (new features, backward compatible)
```

---

## Quick Reference: File Locations

| Task | File |
|------|------|
| Add S3 method | R/cells.R or appropriate module |
| Add optional dependency | R/error_handling.R or new module |
| Add rendering format | R/rendering.R |
| Add statistical test | R/utils.R or R/statistics.R |
| Theme system changes | R/themes.R or R/theme_registry.R |
| Add function documentation | Respective R/*.R file |
| Write tests | tests/testthat/test-*.R |
| Create vignette | vignettes/*.Rmd |
| Update guide | PHASE5_ROADMAP.md |

---

## Getting Help

- **Architecture questions:** Read IMPLEMENTATION_SUMMARY.md
- **Blueprint construction:** See Blueprint_Construction_Guide.md
- **Troubleshooting issues:** TROUBLESHOOTING.md
- **Performance questions:** PERFORMANCE_ANALYSIS.md
- **Phase progress:** PHASE*_IMPROVEMENTS.md files
- **Code examples:** vignettes/ directory

---

**Happy coding! Ready to build Phase 5!**
