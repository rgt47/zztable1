# Evaluate Computation Cell

S3 method for evaluating cells that perform computations.

## Usage

``` r
# S3 method for class 'cell_computation'
evaluate_cell(
  cell,
  data,
  env = parent.frame(),
  force_recalc = FALSE,
  blueprint = NULL
)
```

## Arguments

- cell:

  Computation cell object

- data:

  Data frame for computation context

- env:

  Evaluation environment

- force_recalc:

  Force cache invalidation

- blueprint:

  Blueprint object (optional)

## Value

Computed result as character string
