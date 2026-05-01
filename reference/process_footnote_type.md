# Process Single Footnote Type

Helper function to process one type of footnote efficiently.

## Usage

``` r
process_footnote_type(footnote_spec, type, x_vars, counter)
```

## Arguments

- footnote_spec:

  Footnote specification for this type

- type:

  Footnote type ("variables", "columns", "general")

- x_vars:

  Analysis variables

- counter:

  Current footnote counter

## Value

List with markers, text, and next counter
