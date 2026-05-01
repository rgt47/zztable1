# Render Table Headers (Format-Agnostic)

Renders column headers with proper footnote markers for the specified
format. When column spanners are defined, emits spanner rows above the
column headers to produce multi-level hierarchical headings.

## Usage

``` r
render_table_headers(blueprint, theme, format)
```

## Arguments

- blueprint:

  Table1Blueprint object

- theme:

  Theme configuration

- format:

  Output format

## Value

Character vector with rendered headers
