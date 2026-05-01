# Export theme to R package format

Creates R code that can be included in a package to register a theme.

## Usage

``` r
export_theme_to_package(theme_obj, file = NULL)
```

## Arguments

- theme_obj:

  Theme object to export

- file:

  Optional file path to write to

## Value

Character string with R code (invisibly if file specified)

## Details

The returned code can be included in an R package's R/ directory to
automatically register the theme when the package loads.

## Examples

``` r
if (FALSE) { # \dontrun{
my_theme <- create_custom_theme("MyTheme")
code <- export_theme_to_package(my_theme)
cat(code)
} # }
```
