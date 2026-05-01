# Knitr Print Method for table1_blueprint

Automatically renders a table1_blueprint object in the appropriate
format (HTML, LaTeX, or console) when used as the last expression in an
R Markdown or Quarto code chunk.

## Usage

``` r
knit_print.table1_blueprint(x, ...)
```

## Arguments

- x:

  A `table1_blueprint` object.

- ...:

  Additional arguments (ignored).

## Value

A [`knitr::asis_output`](https://rdrr.io/pkg/knitr/man/asis_output.html)
object.
