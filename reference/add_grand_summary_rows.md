# Add Grand Summary Rows to a Blueprint

Defines aggregation functions computed over all data rows in the table
(excluding other summary rows). Grand summaries appear at the very
bottom (or top) of the table.

## Usage

``` r
add_grand_summary_rows(
  blueprint,
  fns,
  columns = NULL,
  side = "bottom",
  fmt_fn = NULL
)
```

## Arguments

- blueprint:

  A table1_blueprint object

- fns:

  A named list of aggregation functions.

- columns:

  Integer or character vector of columns to summarise. Defaults to all
  data columns.

- side:

  Where to place grand summary rows: `"bottom"` (default) or `"top"`.

- fmt_fn:

  Optional formatting function for computed values.

## Value

The blueprint, modified in place.
