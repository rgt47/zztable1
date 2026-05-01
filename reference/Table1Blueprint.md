# Create Memory-Efficient Table1 Blueprint Object

Creates an optimized blueprint object with sparse storage using R
environments for hash-table like performance. Only populated cells
consume memory, providing significant memory savings for typical sparse
table structures.

## Usage

``` r
Table1Blueprint(nrows, ncols)
```

## Arguments

- nrows:

  Integer specifying the number of rows in the final table. Must be a
  positive integer

- ncols:

  Integer specifying the number of columns in the final table. Must be a
  positive integer

## Value

An object of class `"table1_blueprint"` with components:

- `cells`: Environment with hash-table storage for cells

- `nrows`: Number of rows

- `ncols`: Number of columns

- `row_names`: Character vector of row identifiers

- `col_names`: Character vector of column headers

- `metadata`: List containing structural information

## Details

The optimized blueprint uses environment-based sparse storage instead of
pre-allocating all cells. Benefits include:

- Memory usage scales with actual content, not table dimensions

- O(1) hash-table lookup for cell access

- Automatic garbage collection of unused cells

- Support for very large sparse tables

## See also

[`Cell`](https://rgt47.github.io/zztable1/reference/Cell.md),
[`validate_table1_blueprint`](https://rgt47.github.io/zztable1/reference/validate_table1_blueprint.md)

## Examples

``` r
# Small table - minimal memory usage
bp_small <- Table1Blueprint(5, 3)
bp_small[1, 1] <- Cell(type = "content", content = "Variable")

# Large sparse table - still efficient
bp_large <- Table1Blueprint(1000, 100) # Only uses memory for metadata
```
