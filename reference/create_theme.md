# Create Theme Configuration

Internal factory function for creating consistent theme objects. Used to
define all built-in themes.

## Usage

``` r
create_theme(
  name,
  decimal_places = 1,
  variable_indent = 2,
  level_indent = 4,
  stratum_separator = "text",
  factor_separator = "text",
  show_missing = TRUE,
  collapse_binary = FALSE,
  dimension_rules = list(),
  rendering_rules = list(),
  css_properties = list()
)
```

## Arguments

- name:

  Display name of the theme

- decimal_places:

  Decimal places for numeric formatting

- variable_indent:

  Indentation for variables

- level_indent:

  Indentation for factor levels

- stratum_separator:

  Separator type between strata

- factor_separator:

  Separator type between factors

- dimension_rules:

  List of dimension calculation rules

- rendering_rules:

  List of rendering functions

- css_properties:

  Named list of CSS properties

## Value

Theme object (list with class "table1_theme")
