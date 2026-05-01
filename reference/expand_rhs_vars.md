# Expand RHS Variables with Dot and Minus Support

Uses [`terms()`](https://rdrr.io/r/stats/terms.html) to expand `.` (all
variables) and handle `-` (variable removal) in the formula RHS.

## Usage

``` r
expand_rhs_vars(rhs_expr, data, exclude)
```

## Arguments

- rhs_expr:

  The RHS expression from the formula

- data:

  Data frame (needed for dot expansion)

- exclude:

  Character vector of variable names to exclude (grouping variable,
  strata variable)

## Value

Character vector of resolved analysis variable names
