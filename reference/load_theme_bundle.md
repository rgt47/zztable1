# Load theme bundle from file

Loads a previously saved theme bundle.

## Usage

``` r
load_theme_bundle(file)
```

## Arguments

- file:

  Path to bundle file

## Value

Theme bundle object

## Examples

``` r
if (FALSE) { # \dontrun{
bundle <- load_theme_bundle("mythemes.rds")
install_themes_from_bundle(bundle)
} # }
```
