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

## Examples

``` r
bp <- Table1Blueprint(5, 3)

# Assign cell
bp[1, 1] <- Cell(type = "content", content = "Variable")

# Remove cell
bp[1, 1] <- NULL
```
