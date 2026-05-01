# Evaluate summary rows for a single group

Evaluates aggregation functions against raw data extracted directly from
blueprint computation cells, avoiding the fragility of parsing formatted
strings.

## Usage

``` r
evaluate_summary_for_group(blueprint, row_range, summary_def, ncols)
```

## Arguments

- blueprint:

  Table1Blueprint object

- row_range:

  Integer vector of row indices for this group

- summary_def:

  A single summary definition list

- ncols:

  Number of columns in the output

## Value

List of character vectors, one per summary function

## Details

For each column, collects the raw numeric data subsets from every
computation cell in the row range by evaluating the cell's `data_subset`
expression against the blueprint's stored data frame. The aggregation
function then operates on the full set of underlying values.
