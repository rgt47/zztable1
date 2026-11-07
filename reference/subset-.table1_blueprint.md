# Optimized Cell Assignment for Blueprint

Provides efficient assignment of cells to blueprint positions using hash
table storage with automatic memory management.

## Usage

``` r
# S3 method for class 'table1_blueprint'
x[i, j] <- value
```

## Arguments

- x:

  A table1_blueprint object

- i:

  Row index (1-based)

- j:

  Column index (1-based)

- value:

  A Cell object or NULL to remove

## Value

Modified table1_blueprint object

## Details

Assignment automatically manages memory by:

- Storing only non-NULL cells

- Removing cells when assigned NULL

- Updating cell count metadata

- Validating cell objects before storage

Assignment has value semantics. A blueprint keeps its cells and result
cache in environments, which R does not copy when a blueprint is
assigned to a second name, so before writing, the blueprint being
modified receives its own copies of those environments. After
`bp2 <- bp; bp2[i, j] <- value`, `bp` is unchanged, and a function that
edits a blueprint it was passed does not alter the caller's object.
Cached results for the cells that were not edited are carried over to
the copy.

## Examples

``` r
bp <- Table1Blueprint(5, 3)

# Assign cell
bp[1, 1] <- Cell(type = "content", content = "Variable")

# Remove cell
bp[1, 1] <- NULL
```
