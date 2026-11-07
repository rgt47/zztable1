# Copy an Environment

Shallow copy: bindings are duplicated, but the objects they refer to are
shared until R's own copy-on-modify duplicates them.

## Usage

``` r
copy_env(e)
```

## Arguments

- e:

  An environment

## Value

A new environment with the same bindings and parent
