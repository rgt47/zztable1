# Format a LaTeX table row with theme-specific styling

Format a LaTeX table row with theme-specific styling

## Usage

``` r
format_latex_table_row(row_data, row_index, theme, row_type = "data")
```

## Arguments

- row_data:

  Character vector of cell values

- row_index:

  Row number (for striping)

- theme:

  Theme configuration

- row_type:

  Type of row ("data", "factor_level", "header")

## Value

Character string with formatted LaTeX row
