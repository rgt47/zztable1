# Validate variable is of expected type

Checks variable type and provides helpful error message.

## Usage

``` r
validate_var_type(var_name, data, expected_class, context = "Variable")
```

## Arguments

- var_name:

  Character string with variable name

- data:

  Data frame containing the variable

- expected_class:

  Expected class(es)

- context:

  Description of context (for error messages)

## Value

Invisible NULL if valid
