# Register a custom theme globally

Registers a custom theme in the package registry, making it available to
all subsequent calls in the session.

## Usage

``` r
register_theme(theme_obj, overwrite = FALSE)
```

## Arguments

- theme_obj:

  A theme object (list with required fields)

- overwrite:

  Logical, whether to overwrite existing theme

## Value

Invisibly returns the registered theme

## Details

A valid theme must have: - name: Character string with theme name -
decimal_places: Numeric decimal places - css_properties: List of CSS
properties - dimension_rules: List of dimension rules (optional)

## Examples

``` r
if (FALSE) { # \dontrun{
my_theme <- create_custom_theme("MyTheme", base_theme = "nejm")
register_theme(my_theme)
} # }
```
