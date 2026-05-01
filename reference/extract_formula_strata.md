# Extract Strata Variable from Formula

Peeks at the formula's RHS for a `|` operator. If found, returns the
stratification variable name. This runs before full parsing so the
`strata` parameter can be set early.

## Usage

``` r
extract_formula_strata(formula)
```

## Arguments

- formula:

  A formula object

## Value

Character string (strata variable name) or NULL
