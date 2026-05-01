# Collect raw numeric values from blueprint cells

For each computation cell in the given rows and column, evaluates the
`data_subset` expression to retrieve the underlying numeric vector.
Content and separator cells are skipped. Factor-level cells (whose
data_subset yields a data frame) return the row count as the numeric
value.

## Usage

``` r
collect_raw_values(blueprint, row_range, col, data)
```

## Arguments

- blueprint:

  Table1Blueprint object

- row_range:

  Integer vector of row indices

- col:

  Column index

- data:

  Source data frame

## Value

Numeric vector of raw values
