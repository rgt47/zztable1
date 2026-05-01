# Validate Dimension Analysis Inputs

Streamlined validation focusing only on critical checks. Detailed
validation should happen at the API boundary.

## Usage

``` r
validate_dimensions_inputs(x_vars, grp_var, data, strata)
```

## Arguments

- x_vars:

  Analysis variables

- grp_var:

  Grouping variable

- data:

  Data frame

- strata:

  Stratification variable

## Details

This is an internal function used during dimension analysis. Performs
vectorized validation for efficiency.
