# Create Cell Object with Validation (User Interface)

User-facing constructor that provides comprehensive input validation and
creates properly validated Cell objects.

## Usage

``` r
Cell(
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

  Character string specifying cell type. Must be one of: "content",
  "computation", "separator"

- content:

  Static text content (required for "static" type)

- data_subset:

  R expression for data subsetting (required for "computation")

- computation:

  R expression for calculation (required for "computation")

- dependencies:

  Character vector of variable dependencies

- format:

  Named list of formatting options

- cached_result:

  Cached computation result (for performance)

- footnote_number:

  Integer footnote number (for footnote cells)

- footnote_text:

  Character footnote text (for footnote cells)

## Value

Validated Cell object of class "cell"

## Examples

``` r
# Static cell
Cell(type = "content", content = "Age (years)")
#> Cell [content]
#> Content: 'Age (years)'

# Computation cell
Cell(
  type = "computation",
  data_subset = expression(data$age[data$group == "Treatment"]),
  computation = expression(paste0(round(mean(x), 1), " +/- ", round(sd(x), 1))),
  dependencies = c("data", "age", "group")
)
#> Cell [computation]
#> Data subset:  expression(data$age[data$group == "Treatment"]) 
#> Computation:  expression(paste0(round(mean(x), 1), " +/- ", round(sd(x), 1))) 

# Separator cell
Cell(type = "separator", content = "")
#> Cell [separator]
#> Content: ''
```
