# Create Custom Theme

Creates a new custom theme based on specified parameters. Can be used as
a starting point for modifications.

## Usage

``` r
create_custom_theme(
  name = "Custom",
  base_theme = "console",
  decimal_places = NULL,
  font_family = NULL,
  font_size = NULL,
  background_color = NULL,
  border_color = NULL
)
```

## Arguments

- name:

  Display name for the theme

- base_theme:

  Base theme to inherit from (default: "console")

- decimal_places:

  Number of decimal places

- font_family:

  Font family for CSS

- font_size:

  Font size for CSS

- background_color:

  Background color

- border_color:

  Border color

## Value

Custom theme object

## Examples

``` r
if (FALSE) { # \dontrun{
custom <- create_custom_theme("MyTheme", base_theme = "nejm")
} # }
```
