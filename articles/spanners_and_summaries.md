# Column Spanners and Summary Rows

## Overview

This vignette demonstrates two structural extensions to the zztable1
blueprint framework:

- **Column spanners** group columns under hierarchical headers
- **Summary rows** insert computed subtotals at group boundaries

Both features are applied post-hoc to an existing blueprint using a
pipeline-style API.

## Sample Data

``` r

set.seed(42)
n <- 120

trial <- data.frame(
  arm = factor(
    sample(c("Placebo", "Treatment"), n, replace = TRUE),
    levels = c("Placebo", "Treatment")
  ),
  age = round(rnorm(n, 62, 14)),
  sex = factor(
    sample(c("Male", "Female"), n, replace = TRUE)
  ),
  bmi = round(rnorm(n, 27, 5), 1),
  diabetes = factor(
    sample(c("No", "Yes"), n, replace = TRUE,
           prob = c(0.7, 0.3))
  )
)
```

## Column Spanners

### Basic spanner

A single-level spanner groups the treatment arm columns under a shared
label.

``` r

bp <- table1(
  arm ~ age + sex + bmi + diabetes,
  data = trial,
  pvalue = TRUE,
  theme = "nejm"
)

add_spanner(bp, label = "Treatment Arms",
            columns = c(2L, 3L))

render_bp(bp)
```

[TABLE]

### Multiple spanners

Two separate spanners, each covering different column ranges.

``` r

bp2 <- table1(
  arm ~ age + sex + bmi + diabetes,
  data = trial,
  pvalue = TRUE,
  totals = TRUE,
  theme = "lancet"
)

add_spanner(bp2, label = "By Arm",
            columns = c(2L, 3L), id = "arms")
add_spanner(bp2, label = "Overall",
            columns = 4L, id = "overall")

render_bp(bp2, "lancet")
```

[TABLE]

### Nested (hierarchical) spanners

A parent spanner groups two child spanners, producing a two-level column
hierarchy.

``` r

bp3 <- table1(
  arm ~ age + sex + bmi + diabetes,
  data = trial,
  pvalue = TRUE,
  totals = TRUE,
  theme = "jama"
)

add_spanner(bp3, label = "By Arm",
            columns = c(2L, 3L), id = "by_arm")
add_spanner(bp3, label = "Overall",
            columns = 4L, id = "overall")
add_spanner(bp3, label = "Patient Characteristics",
            spanners = c("by_arm", "overall"))

render_bp(bp3, "jama")
```

[TABLE]

## Summary Rows

### Per-group summaries

Summary rows are computed over the numeric values in each variable group
and inserted at the group boundary.

``` r

bp4 <- table1(
  arm ~ age + sex + bmi,
  data = trial,
  pvalue = FALSE,
  theme = "nejm"
)

add_summary_rows(bp4,
  fns = list(
    "Group n" = function(x) sum(!is.na(x))
  ),
  side = "bottom"
)

render_bp(bp4)
```

[TABLE]

### Grand summary

A grand summary row aggregates across the entire table.

``` r

bp5 <- table1(
  arm ~ age + bmi,
  data = trial,
  pvalue = TRUE,
  theme = "lancet"
)

add_grand_summary_rows(bp5,
  fns = list(
    "Overall Mean" = function(x) round(mean(x, na.rm = TRUE), 1)
  ),
  side = "bottom"
)

render_bp(bp5, "lancet")
```

[TABLE]

### Combined: subtotals and grand total

Per-group counts and a grand total in the same table.

``` r

bp6 <- table1(
  arm ~ age + sex + bmi + diabetes,
  data = trial,
  pvalue = TRUE,
  totals = TRUE,
  theme = "jama"
)

add_summary_rows(bp6,
  fns = list(
    "Subtotal n" = function(x) sum(!is.na(x))
  ),
  side = "bottom"
)

add_grand_summary_rows(bp6,
  fns = list(
    "Grand Total n" = function(x) sum(!is.na(x))
  ),
  side = "bottom"
)

render_bp(bp6, "jama")
```

[TABLE]

## Both Features Together

Spanners and summary rows on the same blueprint.

``` r

bp7 <- table1(
  arm ~ age + sex + bmi + diabetes,
  data = trial,
  pvalue = TRUE,
  totals = TRUE,
  theme = "nejm"
)

add_spanner(bp7, label = "Randomised Arms",
            columns = c(2L, 3L), id = "arms")
add_spanner(bp7, label = "All",
            columns = 4L, id = "all")
add_spanner(bp7, label = "Participants",
            spanners = c("arms", "all"))

add_summary_rows(bp7,
  fns = list(
    "n obs" = function(x) sum(!is.na(x))
  ),
  side = "bottom"
)

add_grand_summary_rows(bp7,
  fns = list(
    "Total n" = function(x) sum(!is.na(x))
  ),
  side = "bottom"
)

render_bp(bp7)
```

[TABLE]

## API Reference

| Function | Purpose |
|:---|:---|
| [`add_spanner()`](https://rgt47.github.io/zztable1/reference/add_spanner.md) | Add a column spanner to a blueprint |
| [`add_spanner_delim()`](https://rgt47.github.io/zztable1/reference/add_spanner_delim.md) | Auto-generate spanners from column name delimiters |
| [`add_summary_rows()`](https://rgt47.github.io/zztable1/reference/add_summary_rows.md) | Add per-group summary rows |
| [`add_grand_summary_rows()`](https://rgt47.github.io/zztable1/reference/add_grand_summary_rows.md) | Add table-wide grand summary rows |

### `add_spanner()` Parameters

| Parameter  | Description                             |
|:-----------|:----------------------------------------|
| `label`    | Display text for the spanner header     |
| `columns`  | Column indices or names to group        |
| `id`       | Unique identifier (for nesting)         |
| `spanners` | Child spanner ids (for nested spanners) |
| `level`    | Explicit level override                 |

### `add_summary_rows()` Parameters

| Parameter | Description                                      |
|:----------|:-------------------------------------------------|
| `fns`     | Named list of aggregation functions              |
| `columns` | Columns to summarise (default: all data columns) |
| `side`    | `"bottom"` or `"top"` of each group              |
| `groups`  | Restrict to specific groups                      |
| `fmt_fn`  | Custom formatting function                       |
