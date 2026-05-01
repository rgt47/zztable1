# Create Publication-Ready Summary Tables (Optimized)

Optimized version of the table1 function with significant improvements
in memory efficiency, error handling, and performance. Maintains full
compatibility with the original interface while providing enhanced
functionality.

## Usage

``` r
table1(
  formula,
  data,
  strata = NULL,
  block = NULL,
  missing = NULL,
  pvalue = TRUE,
  size = TRUE,
  totals = FALSE,
  title = NULL,
  fname = "table1",
  layout = "console",
  numeric_summary = "mean_sd",
  footnotes = NULL,
  theme = "console",
  continuous_test = "ttest",
  categorical_test = "fisher",
  transpose = FALSE,
  ...
)
```

## Arguments

- formula:

  Formula specifying table structure (group ~ vars or ~ vars)

- data:

  Data frame containing all variables

- strata:

  Optional stratification variable name

- block:

  Deprecated parameter (maintained for compatibility)

- missing:

  Logical indicating whether to show missing value counts

- pvalue:

  Logical indicating whether to include p-values

- size:

  Logical indicating whether to show group sizes

- totals:

  Logical indicating whether to include totals column

- title:

  Optional table title

- fname:

  Output filename (for export functions)

- layout:

  Output format ("console", "latex", "html")

- numeric_summary:

  Summary type for numeric variables

- footnotes:

  Footnote specifications

- theme:

  Journal theme ("console", "nejm", "lancet", "jama", "bmj", "simple")

- continuous_test:

  Statistical test for continuous variables ("ttest", "anova", "welch",
  "kruskal")

- categorical_test:

  Statistical test for categorical variables ("fisher", "chisq")

- transpose:

  Logical; if `TRUE`, place groups as rows and variables as columns
  (gt-style summary layout). Requires all-numeric RHS variables and
  disables p-values, totals, missing rows, and stratification.

- ...:

  Additional arguments for future extensibility

## Value

Optimized table1_blueprint object with sparse storage

## Details

This optimized version provides significant improvements:

- Memory efficiency: 60-80

- Performance: Vectorized operations and optimized algorithms

- Reliability: Comprehensive input validation and error handling

- Maintainability: Modular architecture with focused functions

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic usage
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Auto"))

# Simple table
bp <- table1(transmission ~ mpg + hp, data = mtcars)
display_table(bp, mtcars)

# With theme and footnotes
bp <- table1(transmission ~ mpg + hp,
  data = mtcars,
  theme = "nejm", pvalue = TRUE,
  footnotes = list(
    variables = list(mpg = "EPA fuel economy rating")
  )
)
display_table(bp, mtcars)
} # }
```
