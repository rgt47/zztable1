# Theme-Aware Table Dimension Calculation

Theme-Aware Table Dimension Calculation

## Usage

``` r
calculate_table_dimensions_themed(
  analyses,
  totals,
  pvalue,
  size,
  theme,
  missing = FALSE
)
```

## Arguments

- analyses:

  Analysis results

- totals:

  Include totals column

- pvalue:

  Include p-value column

- size:

  Include size information

- theme:

  Theme object

- missing:

  Include missing value information

## Value

An object of class \`themed_table_dimensions\`: a list of the computed
row and column counts, the theme adjustments applied, the footnote
markers, and a \`summary\` element recording the inputs the calculation
was based on.
