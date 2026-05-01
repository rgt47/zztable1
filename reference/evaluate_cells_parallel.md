# Evaluate cells using parallel processing

Evaluates cells across multiple cores using platform-appropriate
parallelization (mclapply for Unix/Linux/Mac, parLapply for Windows).

## Usage

``` r
evaluate_cells_parallel(blueprint)
```

## Arguments

- blueprint:

  Table1Blueprint object

## Value

Data frame with evaluated cell contents
