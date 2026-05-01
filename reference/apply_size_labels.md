# Append Group Sizes to Column Headers

When `size = TRUE`, appends `(N=XX)` below each group column header and
the totals column header. Skips the first column (variable names) and
the p-value column.

## Usage

``` r
apply_size_labels(col_headers, blueprint, format)
```

## Arguments

- col_headers:

  Character vector of column header labels

- blueprint:

  Table1Blueprint object

- format:

  Output format

## Value

Modified col_headers with size labels
