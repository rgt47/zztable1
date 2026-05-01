# Validate variable exists in data with enhanced error

Checks if a variable exists in a data frame with helpful error message.
Uses optional rlang for better error context.

## Usage

``` r
validate_var_in_data(var_name, data, context = "Variable")
```

## Arguments

- var_name:

  Character string with variable name

- data:

  Data frame to check

- context:

  Description of context (for error messages)

## Value

Invisible NULL if valid
