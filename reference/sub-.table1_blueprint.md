# Optimized Cell Access for Blueprint

Provides efficient matrix-like indexing for table1_blueprint objects
using environment-based hash table lookup.

## Usage

``` r
# S3 method for class 'table1_blueprint'
x[i, j, drop = FALSE]
```

## Arguments

- x:

  A table1_blueprint object

- i:

  Row index (1-based)

- j:

  Column index (1-based)

- drop:

  Logical (ignored for compatibility)

## Value

The cell object at position \[i, j\] or NULL if empty

## Details

The optimized implementation uses O(1) hash table lookup through R
environments. Bounds checking is performed to ensure safe access.

## Examples

``` r
bp <- Table1Blueprint(5, 3)
bp[1, 1] <- Cell(type = "content", content = "Variable")
cell <- bp[1, 1] # O(1) lookup
```
