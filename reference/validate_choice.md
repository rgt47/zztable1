# Validate a Single Choice Argument

Requires an exact match (no partial matching, unlike
[`match.arg()`](https://rdrr.io/r/base/match.arg.html)) so that a typo
cannot silently select a different option.

## Usage

``` r
validate_choice(value, choices, arg)
```

## Arguments

- value:

  Supplied value

- choices:

  Character vector of allowed values

- arg:

  Argument name used in the error message

## Value

`value`, invisibly, if valid; otherwise an error
