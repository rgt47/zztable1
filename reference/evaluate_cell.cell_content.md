# Evaluate Static Content Cell

S3 method for evaluating content cells containing static text.

## Usage

``` r
# S3 method for class 'cell_content'
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

  Content cell object

- data:

  Data frame (not used for content cells)

- env:

  Evaluation environment (not used)

- force_recalc:

  Force recalculation (not used)

- blueprint:

  Blueprint object (optional)

## Value

Cell content as character string
