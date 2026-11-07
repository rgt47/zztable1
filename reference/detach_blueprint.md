# Give a Blueprint Its Own Environments

Replaces the cell environment and the stat_cache, spanner_store, and
summary_store environments with copies, so that later in-place writes do
not reach any other binding that shared them. Cached results are carried
over, so cells that are not subsequently edited are still served from
the cache.

## Usage

``` r
detach_blueprint(x)
```

## Arguments

- x:

  A table1_blueprint

## Value

The blueprint with copied environments
