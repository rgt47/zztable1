# Add Spanners from Column Name Delimiters

Automatically generates spanners by splitting column names on a
delimiter character. For example, columns named `"hematology.wbc"` and
`"hematology.rbc"` produce a spanner labelled `"hematology"` covering
both columns.

## Usage

``` r
add_spanner_delim(blueprint, delim = ".")
```

## Arguments

- blueprint:

  A table1_blueprint object

- delim:

  Single character delimiter (default `"."`)

## Value

The blueprint with spanners added.
