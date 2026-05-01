# Create safe data subsetting expression (with optional rlang)

Creates safe expressions for subsetting data with variables. If rlang is
available, uses tidy evaluation for safer handling.

## Usage

``` r
safe_extract_var(data, var_name)
```

## Arguments

- data:

  Data frame to subset

- var_name:

  Variable name to extract

## Value

Vector from data\[\[var_name\]\]
