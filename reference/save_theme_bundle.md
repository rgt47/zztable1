# Save theme bundle to file

Serializes a theme bundle for distribution or storage.

## Usage

``` r
save_theme_bundle(bundle, file)
```

## Arguments

- bundle:

  Theme bundle object

- file:

  Path to save to

## Value

Invisibly returns the file path

## Examples

``` r
if (FALSE) { # \dontrun{
bundle <- create_theme_bundle(themes, name = "MyThemes")
save_theme_bundle(bundle, "mythemes.rds")
} # }
```
