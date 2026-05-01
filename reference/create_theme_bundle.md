# Create theme bundle

Bundles multiple themes for distribution.

## Usage

``` r
create_theme_bundle(themes, name, description = NULL, author = NULL)
```

## Arguments

- themes:

  List of theme objects

- name:

  Bundle name

- description:

  Bundle description

- author:

  Bundle author

## Value

List with bundle information

## Details

Themes can be bundled together and distributed as an R package or shared
directly.

## Examples

``` r
if (FALSE) { # \dontrun{
themes <- list(
  create_custom_theme("Theme1"),
  create_custom_theme("Theme2")
)
bundle <- create_theme_bundle(themes, name = "MyThemes")
} # }
```
