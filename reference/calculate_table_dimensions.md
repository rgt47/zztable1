# Calculate Final Table Dimensions

Pure function that calculates final dimensions from component analyses.
Much cleaner than the original approach.

## Usage

``` r
calculate_table_dimensions(analyses, totals, pvalue, size, layout)
```

## Arguments

- analyses:

  List of component analyses

- totals:

  Logical for totals column

- pvalue:

  Logical for p-value column

- size:

  Logical for group sizes

- layout:

  Output layout

## Value

Complete dimension specification
