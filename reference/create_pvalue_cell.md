# Create P-value Cell Optimized

Creates optimized p-value computation cell.

## Usage

``` r
create_pvalue_cell(
  var_name,
  grp_var,
  test_type,
  strata_var = NULL,
  strata_val = NULL
)
```

## Arguments

- var_name:

  Variable name

- grp_var:

  Grouping variable name

- test_type:

  Type of statistical test

- strata_var:

  Name of the stratifying column, or \`NULL\` (default) for an
  unstratified table. When supplied, the computation restricts \`data\`
  to the current stratum before the test runs.

- strata_val:

  Value of \`strata_var\` identifying the current stratum. Ignored when
  \`strata_var\` is \`NULL\`.

## Value

P-value cell object
