# Validate All Table1 Inputs (Consolidated)

Single entry point for all validation with comprehensive error checking.
Uses optional rlang package for enhanced error messages when available.

## Usage

``` r
validate_inputs(
  formula,
  data,
  strata = NULL,
  theme = "console",
  footnotes = NULL,
  ...
)
```

## Arguments

- formula:

  Formula object

- data:

  Data frame

- strata:

  Optional stratification variable

- theme:

  Theme specification

- footnotes:

  Optional footnotes list

- ...:

  Other parameters

## Value

TRUE if valid, otherwise stops with error
