# Fingerprint a Data Frame for Cache Validation

Produces a cheap descriptor used to detect that the data underlying a
blueprint has been swapped between renders. It is O(p), not O(n), so it
can be checked on every cell evaluation without cost. It detects a
change in shape or column names, not a change in values within an
identically shaped frame; the latter is unsupported, as the blueprint is
documented to require that its data remain unchanged.

## Usage

``` r
data_fingerprint(data)
```

## Arguments

- data:

  Data frame, or NULL

## Value

A list describing the data, or NULL
