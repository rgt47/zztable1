# Internal Cell Constructor

Low-level constructor that creates cell objects after validation. Used
internally after input validation has been performed.

## Usage

``` r
new_cell(
  type,
  content = NULL,
  data_subset = NULL,
  computation = NULL,
  dependencies = NULL,
  format = list(),
  cached_result = NULL,
  footnote_number = NULL,
  footnote_text = NULL
)
```

## Arguments

- type:

  Validated cell type

- content:

  Content (validated)

- data_subset:

  Data subset expression (validated)

- computation:

  Computation expression (validated)

- dependencies:

  Dependencies vector (validated)

- format:

  Format list (validated)

- cached_result:

  Cached result (validated)

- footnote_number:

  Footnote number (validated)

- footnote_text:

  Footnote text (validated)

## Value

Cell object (not yet validated)
