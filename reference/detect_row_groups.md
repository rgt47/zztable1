# Detect row group boundaries in a blueprint

Scans the first column of the content matrix and identifies group
boundaries. A group starts at a non-indented row (a variable header) and
extends through its indented child rows.

## Usage

``` r
detect_row_groups(content_matrix, blueprint)
```

## Arguments

- content_matrix:

  Character matrix of evaluated cell content

- blueprint:

  The blueprint object (for metadata)

## Value

A list of lists, each with `name`, `start_row`, and `end_row`.
