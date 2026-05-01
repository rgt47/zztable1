# Evaluate blueprint cells in parallel (if beneficial)

Evaluates cells in a blueprint, using parallel processing for large
tables if beneficial. Automatically determines whether to use serial or
parallel evaluation.

## Usage

``` r
evaluate_cells_smart(blueprint, force_parallel = FALSE)
```

## Arguments

- blueprint:

  Table1Blueprint object

- force_parallel:

  Logical, force parallel even for small tables

## Value

Data frame with evaluated cell contents
