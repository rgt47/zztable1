# Build a matrix representation of spanner rows

Returns a list of character vectors, one per spanner level (from highest
level to level 1), each of length `ncols`. Empty strings indicate cells
that are not part of any spanner at that level.

## Usage

``` r
build_spanner_rows(blueprint)
```

## Arguments

- blueprint:

  A table1_blueprint

## Value

List of named lists, each with `cells` (character vector) and `spans`
(integer vector of colspans).
