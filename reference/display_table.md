# Display Blueprint as Formatted Table

Convenience function that evaluates the blueprint and displays it as a
nicely formatted table. This provides the "Table 1" output that users
expect.

## Usage

``` r
display_table(blueprint, data, format = "console", ...)
```

## Arguments

- blueprint:

  A table1_blueprint object

- data:

  Data frame containing the source data

- format:

  Output format ("console", "latex", "html")

- ...:

  Additional arguments passed to print methods

## Value

Invisibly returns the rendered output

## Examples

``` r
if (FALSE) { # \dontrun{
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Auto"))
blueprint <- table1(transmission ~ mpg + hp, data = mtcars)
display_table(blueprint, mtcars)
} # }
```
