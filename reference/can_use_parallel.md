# Check if parallel processing is available

Determines if the parallel package is available and if parallel
processing should be used.

## Usage

``` r
can_use_parallel(num_cells, threshold = 1000)
```

## Arguments

- num_cells:

  Number of cells to process

- threshold:

  Minimum cells for parallel overhead to be worthwhile

## Value

Logical indicating if parallel processing should be used
