# Estimate speedup from parallel processing

Estimates the potential speedup for a given number of cells. Takes into
account parallel overhead and diminishing returns.

## Usage

``` r
estimate_parallel_speedup(num_cells, num_cores = NULL)
```

## Arguments

- num_cells:

  Number of cells to process

- num_cores:

  Number of cores available

## Value

Estimated speedup factor (1.0 = no benefit, 2.0 = 2x faster)
