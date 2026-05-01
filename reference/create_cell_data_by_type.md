# Create Cell Data by Type

Creates optimized cell data structures tailored to each cell type. This
eliminates memory waste by only storing relevant fields.

## Usage

``` r
create_cell_data_by_type(
  type,
  content,
  data_subset,
  computation,
  dependencies,
  format,
  cached_result,
  footnote_number,
  footnote_text
)
```

## Arguments

- type:

  Cell type

- content:

  Cell content

- data_subset:

  Data subset expression

- computation:

  Computation expression

- dependencies:

  Dependencies vector

- format:

  Format list

- cached_result:

  Cached result

- footnote_number:

  Footnote number

- footnote_text:

  Footnote text

## Value

Optimized cell data list
