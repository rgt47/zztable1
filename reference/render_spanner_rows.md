# Render Spanner Rows

Produces output lines for column spanners in the appropriate format.
Spanner rows appear above the column headers, from highest level
(outermost grouping) down to level 1. Columns not covered by any spanner
receive a `rowspan` (HTML) or `\multirow` (LaTeX) that spans all spanner
levels plus the column header row.

## Usage

``` r
render_spanner_rows(
  blueprint,
  theme,
  format,
  unspanned = integer(0),
  col_headers = blueprint$col_names
)
```

## Arguments

- blueprint:

  Table1Blueprint object

- theme:

  Theme configuration

- format:

  Output format

- unspanned:

  Integer vector of column indices not in any spanner

- col_headers:

  Character vector of column header labels

## Value

Character vector with spanner header lines
