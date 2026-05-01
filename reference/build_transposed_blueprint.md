# Build Transposed Blueprint (groups as rows, variables as columns)

Constructs a minimal `table1_blueprint` with one row per group level and
one cell per (group, variable) pair. All RHS variables must be numeric.
P-values, missing rows, and stratification are not supported in
transposed mode.

## Usage

``` r
build_transposed_blueprint(
  formula,
  data,
  numeric_summary = "mean_sd",
  theme = "console",
  title = NULL
)
```

## Arguments

- formula:

  Two-sided formula `group ~ var1 + var2 + ...`.

- data:

  Data frame containing all variables.

- numeric_summary:

  Summary type (string or function).

- theme:

  Theme name or object.

- title:

  Optional title.

## Value

A `table1_blueprint` object with pre-computed cells.
