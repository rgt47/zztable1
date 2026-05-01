# Extract variable name from expression (with optional rlang)

Safely extracts variable name from an R expression. If rlang is
available, uses rlang's quoting functions for better handling of complex
expressions. Otherwise falls back to deparse().

## Usage

``` r
expr_to_string(expr)
```

## Arguments

- expr:

  An R expression (symbol, call, or formula)

## Value

Character string with expression as text
