# Get variable name with context (with optional rlang)

Extracts a clean variable name from a quoted expression. If rlang is
available, uses rlang::quo_name() for better handling. Otherwise uses
deparse().

## Usage

``` r
var_name_from_expr(x)
```

## Arguments

- x:

  A quoted expression or name

## Value

Character string with variable name
