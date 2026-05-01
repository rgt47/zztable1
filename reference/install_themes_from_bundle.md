# Install themes from bundle

Registers all themes from a bundle in the current session.

## Usage

``` r
install_themes_from_bundle(bundle, overwrite = FALSE)
```

## Arguments

- bundle:

  Theme bundle object

- overwrite:

  Logical, whether to overwrite existing themes

## Value

Invisibly returns the bundle

## Examples

``` r
if (FALSE) { # \dontrun{
bundle <- load_theme_bundle("path/to/bundle.rds")
install_themes_from_bundle(bundle)
} # }
```
