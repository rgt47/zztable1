# Prepare a Blueprint for Modification

Every function that writes to a blueprint's environments calls this
first. When copy-on-write is enabled (all blueprints returned to users),
the blueprint receives its own environments so that the write cannot
reach another binding to the same blueprint.

## Usage

``` r
prepare_for_write(x)
```

## Arguments

- x:

  A table1_blueprint

## Value

The blueprint, safe to modify
