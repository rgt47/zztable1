# Get Theme Configuration

Retrieves a theme configuration by name. Falls back to console theme if
the requested theme is not found.

## Usage

``` r
get_theme(theme_name = "console")
```

## Arguments

- theme_name:

  Character string specifying theme name (e.g., "nejm", "lancet")

## Value

Theme object (list with class "table1_theme")

## Details

Available themes: "console", "nejm", "lancet", "jama", "bmj", "simple"

## Examples

``` r
theme <- get_theme("nejm")
cat(theme$name)
#> New England Journal of Medicine
```
