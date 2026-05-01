# Optimized Table Dimension Analysis

Completely redesigned dimension analysis using modern R patterns. Much
more efficient and maintainable than the original approach.

## Usage

``` r
analyze_dimensions(
  x_vars,
  grp_var,
  data,
  strata = NULL,
  missing = FALSE,
  size = FALSE,
  totals = FALSE,
  pvalue = TRUE,
  layout = "console",
  footnotes = NULL,
  theme = NULL,
  block = NULL,
  collapse_binary = FALSE
)
```

## Arguments

- x_vars:

  Character vector of analysis variables

- grp_var:

  Character string naming grouping variable

- data:

  Data frame containing variables

- strata:

  Optional stratification variable name

- missing:

  Logical indicating whether to show missing counts

- size:

  Logical indicating whether to show group sizes

- totals:

  Logical indicating whether to include totals column

- pvalue:

  Logical indicating whether to include p-values

- layout:

  Character string specifying output format

- footnotes:

  Optional footnote specifications

## Value

Optimized dimension analysis structure
