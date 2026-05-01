# Enhanced Cell Evaluation (S3 Generic)

S3 generic function for cell evaluation with type-specific methods.
Routes to appropriate evaluation method based on cell class.

## Usage

``` r
evaluate_cell(
  cell,
  data,
  env = parent.frame(),
  force_recalc = FALSE,
  blueprint = NULL
)
```

## Arguments

- cell:

  Cell object to evaluate

- data:

  Data frame for computation context

- env:

  Evaluation environment

- force_recalc:

  Logical to force cache invalidation

- blueprint:

  Table1Blueprint object for caching context (optional)

## Value

Evaluated cell result

## Details

This is an S3 generic function that dispatches to type-specific
methods: - \`evaluate_cell.cell_content\` - Evaluates static content
cells - \`evaluate_cell.cell_computation\` - Evaluates computation
cells - \`evaluate_cell.cell_separator\` - Evaluates separator cells -
\`evaluate_cell.default\` - Fallback for unknown cell types
