# Base Rendering Pipeline (Format-Agnostic)

Internal function that provides the common rendering flow for all
formats. Handles theme resolution, headers, table content, and
footnotes.

## Usage

``` r
render_pipeline(blueprint, theme = NULL, format, default_theme = "console")
```

## Arguments

- blueprint:

  Table1Blueprint object

- theme:

  Theme configuration (optional) - will be resolved if character

- format:

  Output format ("console", "latex", "html", etc.)

- default_theme:

  Default theme name if none specified

## Value

Character vector with rendered output
