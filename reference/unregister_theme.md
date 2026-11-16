# Unregister a custom theme

Removes a theme from the registry. Cannot unregister built-in themes.

## Usage

``` r
unregister_theme(theme_name)
```

## Arguments

- theme_name:

  Character string with theme name

## Value

Invisibly returns TRUE if successful

## Examples

``` r
register_theme(create_custom_theme("MyCustomTheme"))
#> Theme 'MyCustomTheme' registered successfully
unregister_theme("MyCustomTheme")
#> Theme 'MyCustomTheme' unregistered
```
