# Add a Column Spanner to a Blueprint

Groups one or more columns under a shared header label. Spanners can
reference other spanners by id to create nested hierarchies.

## Usage

``` r
add_spanner(
  blueprint,
  label,
  columns = NULL,
  id = NULL,
  spanners = NULL,
  level = NULL
)
```

## Arguments

- blueprint:

  A table1_blueprint object

- label:

  Character string displayed as the spanner header

- columns:

  Integer vector of column indices or character vector of column names
  to group under this spanner

- id:

  Optional unique identifier for this spanner. Defaults to a sanitised
  version of label. Required when building nested spanners that
  reference this one as a parent.

- spanners:

  Character vector of child spanner ids to nest under this spanner. When
  provided, `columns` is ignored and the spanner covers all columns
  owned by the referenced children.

- level:

  Integer spanner level (1 = closest to data columns). Normally computed
  automatically; set manually only to force a specific position.

## Value

The blueprint with the spanner added. The input blueprint is not
modified, so the result must be assigned, for example
`bp <- add_spanner(bp, ...)`.

## Examples

``` r
d <- data.frame(
  arm = factor(rep(c("A", "B"), 20)),
  age = seq(30, 69)
)
bp <- table1(arm ~ age, data = d, pvalue = FALSE)
bp <- add_spanner(bp, label = "Treatment", columns = 2:3)
```
