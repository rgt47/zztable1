# Inject Summary Rows Into Rendered Output

After the base table content is rendered, this function inserts
per-group summary rows at group boundaries and grand summary rows at the
table end.

## Usage

``` r
inject_summary_rows(lines, content_matrix, blueprint, format, theme)
```

## Arguments

- lines:

  Character vector of rendered table rows

- content_matrix:

  Character matrix of evaluated cell content

- blueprint:

  Table1Blueprint object

- format:

  Output format

- theme:

  Theme configuration

## Value

Character vector with summary rows injected
