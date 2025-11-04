# API Reference: zztable1_nextgen

## Abstract

This document provides comprehensive reference documentation for the `zztable1_nextgen` package API, including function specifications, parameter descriptions, and methodological details for statistical table generation in biomedical research applications.

## Core Interface Functions

### table1()

**Primary interface function for generating publication-ready summary tables**

#### Syntax
```r
table1(formula, data, strata = NULL, block = NULL, missing = FALSE,
       pvalue = TRUE, size = FALSE, totals = FALSE, fname = "table1",
       layout = "console", numeric_summary = "mean_sd", footnotes = NULL,
       theme = "console", continuous_test = "ttest",
       categorical_test = "fisher", ...)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `formula` | Formula | Required | Formula specifying table structure using syntax `group ~ vars` or `~ vars` for ungrouped tables |
| `data` | data.frame | Required | Data frame containing all variables referenced in formula |
| `strata` | character | NULL | Optional stratification variable name for subgroup analysis |
| `block` | character | NULL | Deprecated parameter maintained for backward compatibility |
| `missing` | logical | FALSE | Include missing value counts in table output |
| `pvalue` | logical | TRUE | Include statistical significance testing results |
| `size` | logical | FALSE | Include group size information in headers |
| `totals` | logical | FALSE | Include totals column in table output |
| `fname` | character | "table1" | Output filename for export functions |
| `layout` | character | "console" | Output format specification: "console", "latex", "html" |
| `numeric_summary` | character/function | "mean_sd" | Summary statistic method for continuous variables |
| `footnotes` | list | NULL | Footnote specifications with hierarchical structure |
| `theme` | character | "console" | Journal theme selection: "console", "nejm", "lancet", "jama" |
| `continuous_test` | character | "ttest" | Statistical test for continuous variables: "ttest", "anova", "welch", "kruskal" |
| `categorical_test` | character | "fisher" | Statistical test for categorical variables: "fisher", "chisq" |

#### Return Value
Returns a `table1_blueprint` object with sparse storage optimization containing:
- Cell computation metadata
- Table structure information
- Formatting specifications
- Statistical test configurations

#### Methodological Details

**Formula Interpretation**
The formula interface follows standard R conventions with extensions for table-specific requirements:

- **Simple Formula**: `~ var1 + var2 + var3` creates ungrouped summary table
- **Grouped Formula**: `group ~ var1 + var2 + var3` creates table stratified by group variable
- **Variable Types**: Automatic detection of continuous vs. categorical variables with appropriate statistical treatment

**Statistical Method Selection**
Default statistical methods are selected based on variable characteristics and research conventions:

- **Continuous Variables**: Two-sample t-test for two groups, ANOVA for multiple groups
- **Categorical Variables**: Fisher exact test with automatic fallback to chi-square for large samples
- **Custom Methods**: User-defined functions accepted through `continuous_test` and `categorical_test` parameters

#### Examples

```r
# Basic ungrouped table
table1(~ age + sex + treatment, data = clinical_data)

# Grouped table with statistical testing
table1(treatment ~ age + sex + biomarker, data = clinical_data,
       pvalue = TRUE, theme = "nejm")

# Stratified analysis with custom statistics
table1(treatment ~ age + sex, data = clinical_data,
       strata = "site", numeric_summary = "median_iqr",
       continuous_test = "kruskal")
```

### Table1Blueprint()

**Constructor function for blueprint objects with sparse storage optimization**

#### Syntax
```r
Table1Blueprint(nrows, ncols)
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `nrows` | integer | Number of rows in table structure |
| `ncols` | integer | Number of columns in table structure |

#### Implementation Details

The blueprint object utilizes R environment objects as hash tables for sparse storage:

```r
structure(list(
  cells = new.env(hash = TRUE, parent = emptyenv()),
  nrows = nrows,
  ncols = ncols,
  row_names = character(nrows),
  col_names = character(ncols),
  metadata = list()
), class = "table1_blueprint")
```

This architecture provides:
- **Memory Efficiency**: O(k) space complexity where k = populated cells
- **Access Performance**: O(1) hash table lookup for cell operations
- **Scalability**: Support for very large sparse table structures

### Cell()

**Constructor for individual table cells with computation metadata**

#### Syntax
```r
Cell(type, computation_fn, format_rules = NULL)
```

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `type` | character | Cell type specification: "numeric", "categorical", "header", "pvalue" |
| `computation_fn` | function | Function for computing cell content with signature `function(data, ...)` |
| `format_rules` | list | Optional formatting specifications including digits, alignment, styling |

#### Cell Type Specifications

**Numeric Cells**
Computation functions for continuous variable summaries:
```r
Cell("numeric", function(data, ...) {
  x <- data$variable
  sprintf("%.1f ± %.1f", mean(x, na.rm = TRUE), sd(x, na.rm = TRUE))
}, format_rules = list(digits = 1, align = "center"))
```

**Categorical Cells**
Frequency and percentage calculations:
```r
Cell("categorical", function(data, ...) {
  freq <- table(data$variable)
  sprintf("%d (%.1f%%)", freq, 100 * freq / sum(freq))
}, format_rules = list(align = "center"))
```

**P-value Cells**
Statistical significance testing:
```r
Cell("pvalue", function(data, ...) {
  test_result <- t.test(variable ~ group, data = data)
  format_pvalue(test_result$p.value)
}, format_rules = list(align = "right"))
```

## Rendering Functions

### render_console()

**Generate formatted console output with monospace alignment**

#### Syntax
```r
render_console(blueprint, theme = NULL)
```

#### Implementation
Produces character vector suitable for console display with proper alignment and formatting according to theme specifications.

### render_latex()

**Generate LaTeX code for publication-quality typesetting**

#### Syntax
```r
render_latex(blueprint, theme = NULL)
```

#### Implementation
Creates LaTeX table code with journal-specific formatting, including:
- Appropriate table environments (tabular, longtable, threeparttable)
- Column alignment specifications
- Row styling and formatting
- Footnote integration with proper numbering

### render_html()

**Generate HTML output for web display**

#### Syntax
```r
render_html(blueprint, theme = NULL)
```

#### Implementation
Produces HTML table with CSS styling for responsive web display, including:
- Semantic table markup
- Responsive design capabilities
- Interactive features for large tables
- Print-optimized styling

## Theme System

### get_theme()

**Retrieve theme configuration for consistent formatting**

#### Syntax
```r
get_theme(theme_name)
```

#### Available Themes

**Console Theme**
Monospace formatting for development and debugging:
```r
list(
  font_family = "'Consolas', 'Monaco', monospace",
  padding = 2,
  decimal_places = 1,
  alignment = "left"
)
```

**NEJM Theme**
New England Journal of Medicine authentic formatting:
```r
list(
  font_family = "'Arial', Helvetica, sans-serif",
  font_size = "10px",
  stripe_color = "#fefcf0",
  border_style = "horizontal_only",
  variable_indent = 0,
  format_numeric = "mean ± sd"
)
```

**Lancet Theme**
The Lancet journal formatting specifications:
```r
list(
  font_family = "'Times New Roman', serif",
  background_color = "#ffffff",
  border_style = "horizontal_only",
  format_numeric = "mean (sd)",
  footnote_style = "numbered"
)
```

**JAMA Theme**
Journal of the American Medical Association formatting:
```r
list(
  font_family = "'Arial', sans-serif",
  border_style = "minimal",
  footnote_style = "lettered",
  format_numeric = "mean ± sd"
)
```

### list_available_themes()

**Enumerate all available theme configurations**

#### Syntax
```r
list_available_themes()
```

#### Return Value
Character vector of available theme names suitable for use with `theme` parameter.

## Statistical Functions

### calculate_summary_stats()

**Compute descriptive statistics for continuous variables**

#### Syntax
```r
calculate_summary_stats(x, summary_type = "mean_sd", digits = 1)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | numeric | Required | Numeric vector for statistical computation |
| `summary_type` | character | "mean_sd" | Summary statistic specification |
| `digits` | integer | 1 | Decimal precision for output formatting |

#### Summary Types

| Type | Description | Output Format |
|------|-------------|---------------|
| `"mean_sd"` | Mean ± standard deviation | "12.3 ± 4.5" |
| `"median_iqr"` | Median with interquartile range | "12.3 (8.1, 16.5)" |
| `"mean_se"` | Mean ± standard error | "12.3 ± 1.2" |
| `"median_range"` | Median with full range | "12.3 (5.0, 25.0)" |
| `"mean_ci"` | Mean with 95% confidence interval | "12.3 (10.1, 14.5)" |

### calculate_frequency_table()

**Generate frequency counts and percentages for categorical variables**

#### Syntax
```r
calculate_frequency_table(x, include_na = FALSE, format = "count_percent")
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | factor/character | Required | Categorical variable for frequency analysis |
| `include_na` | logical | FALSE | Include missing values in frequency calculation |
| `format` | character | "count_percent" | Output format specification |

#### Format Options

| Format | Description | Output Example |
|--------|-------------|----------------|
| `"count_percent"` | Count with percentage | "45 (67.2%)" |
| `"count_only"` | Count alone | "45" |
| `"percent_only"` | Percentage alone | "67.2%" |
| `"proportion"` | Decimal proportion | "0.672" |

### detect_variable_type()

**Automatic classification of variable types for appropriate statistical treatment**

#### Syntax
```r
detect_variable_type(x, threshold = 10)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `x` | vector | Required | Variable for type classification |
| `threshold` | integer | 10 | Threshold for categorical vs. continuous classification |

#### Classification Logic

1. **Factor Variables**: Automatically classified as categorical
2. **Character Variables**: Classified as categorical
3. **Numeric Variables**:
   - Continuous if unique values > threshold
   - Categorical if unique values ≤ threshold
4. **Logical Variables**: Classified as categorical

## Validation Functions

### validate_inputs()

**Comprehensive input validation with informative error messages**

#### Syntax
```r
validate_inputs(formula, data, strata = NULL, theme = NULL, footnotes = NULL)
```

#### Validation Checks

1. **Formula Validation**
   - Syntactic correctness
   - Variable existence in data
   - Appropriate variable types

2. **Data Validation**
   - Object class verification
   - Missing value patterns
   - Data quality assessment

3. **Parameter Validation**
   - Theme availability
   - Statistical test appropriateness
   - Parameter combination compatibility

#### Error Handling

The validation framework employs hierarchical error checking with specific error types:

- **`validation_error()`**: Input parameter violations
- **`data_quality_warning()`**: Data quality concerns
- **`performance_warning()`**: Performance optimization recommendations

## Utility Functions

### format_number()

**Standardized numeric formatting with scientific notation handling**

#### Syntax
```r
format_number(x, digits = 1, scientific_threshold = 0.001)
```

### format_percentage()

**Consistent percentage formatting with rounding conventions**

#### Syntax
```r
format_percentage(x, digits = 1, include_symbol = TRUE)
```

### format_pvalue()

**P-value formatting following statistical reporting conventions**

#### Syntax
```r
format_pvalue(p, threshold = 0.001, exact = TRUE)
```

#### Formatting Rules

| P-value Range | Output Format |
|---------------|---------------|
| p ≥ 0.001 | Exact value with 3 decimal places |
| p < 0.001 | "< 0.001" |
| p < 0.0001 | "< 0.0001" for very small values |

## Advanced Features

### Custom Summary Functions

Users may provide custom statistical functions through the `numeric_summary` parameter:

```r
# Bootstrap confidence interval example
bootstrap_ci <- function(x, ...) {
  if (length(x) < 10) return("Insufficient data")

  bootstrap_means <- replicate(1000, {
    sample_data <- sample(x, replace = TRUE)
    mean(sample_data, na.rm = TRUE)
  })

  ci_lower <- quantile(bootstrap_means, 0.025)
  ci_upper <- quantile(bootstrap_means, 0.975)

  sprintf("%.1f [%.1f, %.1f]",
          mean(x, na.rm = TRUE), ci_lower, ci_upper)
}

table1(treatment ~ biomarker, data = clinical_data,
       numeric_summary = bootstrap_ci)
```

### Stratified Analysis

Multi-level stratification enables complex subgroup analyses:

```r
# Multi-center trial with site stratification
table1(treatment ~ age + sex + biomarker,
       data = trial_data,
       strata = "site",
       theme = "nejm")
```

### Footnote System

Hierarchical footnote specification supports comprehensive annotation:

```r
footnotes <- list(
  variables = list(
    age = "Age at enrollment in years",
    biomarker = "Measured using standardized assay"
  ),
  columns = list(
    "Treatment A" = "Experimental intervention",
    "Treatment B" = "Standard care control"
  ),
  general = "Data presented as mean ± SD or n (%)"
)

table1(treatment ~ age + biomarker,
       data = clinical_data,
       footnotes = footnotes,
       theme = "nejm")
```

## Performance Considerations

### Memory Efficiency

The sparse storage implementation provides significant memory improvements:

- **Traditional approach**: O(n×m) memory usage for n rows × m columns
- **Blueprint approach**: O(k) memory usage for k populated cells
- **Typical improvement**: 60-80% memory reduction for clinical trial tables

### Computational Complexity

- **Cell access**: O(1) hash table lookup
- **Table construction**: O(k) for k populated cells
- **Statistical computation**: O(n) for n observations
- **Rendering**: O(nm) for table dimensions

### Optimization Recommendations

1. **Large Datasets**: Consider stratification to reduce memory usage
2. **Complex Statistics**: Use built-in functions when possible for optimal performance
3. **Multiple Outputs**: Generate blueprint once, render multiple formats efficiently

## Error Handling and Debugging

### Common Error Patterns

**Variable Not Found**
```
Error: Variable 'treatment' not found in data
Solution: Verify variable names match data frame columns exactly
```

**Inappropriate Statistical Test**
```
Warning: Chi-square test inappropriate for small cell counts, using Fisher exact test
Solution: Automatic fallback implemented, no user action required
```

**Memory Allocation Issues**
```
Warning: Large table detected (>10,000 cells), consider stratification
Solution: Use strata parameter to reduce table dimensions
```

### Debugging Utilities

**Blueprint Inspection**
```r
# Examine blueprint structure
str(blueprint, max.level = 2)

# Check cell population status
sum(sapply(ls(blueprint$cells), function(x) !is.null(blueprint$cells[[x]])))

# Memory usage analysis
object.size(blueprint)
```

**Performance Monitoring**
```r
# Benchmark table creation
system.time({
  bp <- table1(treatment ~ age + sex + biomarker, data = large_dataset)
})

# Memory usage tracking
gc()
pryr::mem_used()
```

## Integration with R Markdown

### Automatic Format Detection

The package integrates seamlessly with R Markdown through automatic output format detection:

```r
# In R Markdown document
bp <- table1(treatment ~ age + sex, data = clinical_data, theme = "nejm")
display_table(bp, clinical_data)  # Automatically renders appropriate format
```

### PDF Output (LaTeX)
```yaml
output:
  pdf_document:
    extra_dependencies: ["booktabs", "threeparttable", "xcolor"]
```

### HTML Output
```yaml
output:
  html_document:
    theme: flatly
```

## Extensibility Framework

### Custom Theme Development

Users may define custom themes following the established structure:

```r
custom_theme <- list(
  name = "Custom Journal",
  font_family = "'Helvetica Neue', sans-serif",
  font_size = "11px",
  dimension_rules = list(
    factor_separator = "space",
    footnote_style = "symbol"
  ),
  css_properties = list(
    background_color = "#f0f0f0",
    border_color = "#cccccc"
  )
)
```

### Statistical Method Extensions

New statistical methods may be integrated through standardized function interfaces:

```r
# Custom statistical test
custom_test <- function(x, group, ...) {
  # Implementation of novel statistical method
  # Must return list with 'statistic' and 'p.value' components
}

table1(treatment ~ biomarker, data = clinical_data,
       continuous_test = custom_test)
```

This API reference provides comprehensive documentation for all user-facing functions and methodological details necessary for effective utilization of the `zztable1_nextgen` package in biomedical research applications.