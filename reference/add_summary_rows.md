# Add Per-Group Summary Rows to a Blueprint

Defines aggregation functions that are computed at render time for each
row group in the table. A row group is a set of contiguous rows
belonging to the same variable (for Table 1 layouts) or the same
stratum.

## Usage

``` r
add_summary_rows(
  blueprint,
  fns,
  columns = NULL,
  side = "bottom",
  groups = NULL,
  fmt_fn = NULL
)
```

## Arguments

- blueprint:

  A table1_blueprint object

- fns:

  A named list of aggregation functions. Each function receives a
  numeric vector and returns a single value or formatted string. Names
  become the summary row labels.

- columns:

  Integer or character vector of columns to summarise. Defaults to all
  data columns (excludes the variable name column and the p-value
  column).

- side:

  Where to place summary rows: `"bottom"` (default) or `"top"` of each
  group.

- groups:

  Character vector of row group names to summarise. Defaults to all
  groups.

- fmt_fn:

  Optional formatting function applied to each computed value before
  display. Receives a numeric value, returns a character string.

## Value

The blueprint, modified in place.
