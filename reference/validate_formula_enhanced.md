# Validate formula with enhanced error reporting

Validates formula structure and provides helpful error messages. Uses
optional rlang for better error formatting.

## Usage

``` r
validate_formula_enhanced(formula, context = "formula")
```

## Arguments

- formula:

  A formula object

- context:

  Description of context (for error messages)

## Value

Invisible NULL if valid
