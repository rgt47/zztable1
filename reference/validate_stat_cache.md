# Validate the Cache Against the Current Data

Compares the data now being evaluated against the data that populated
the cache, and empties the cache if they differ. The fingerprint is
stored inside the cache environment itself, under a reserved name,
because the blueprint is a plain list and a write to its metadata would
not survive the function call.

## Usage

``` r
validate_stat_cache(blueprint, data)
```

## Arguments

- blueprint:

  Table1Blueprint object

- data:

  Data frame being evaluated

## Value

TRUE if the cache is valid for this data, FALSE if it was cleared,
invisibly
