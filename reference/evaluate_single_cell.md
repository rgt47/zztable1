# Evaluate a single cell

Internal function to evaluate one cell. Exported for use in parallel
clusters.

## Usage

``` r
evaluate_single_cell(blueprint, key)
```

## Arguments

- blueprint:

  Table1Blueprint object

- key:

  Cell key (format: "r1_c1")

## Value

List with cell position and evaluated content
