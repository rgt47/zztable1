# zztable1

## Publication-Ready Summary Tables for Biomedical Research

### Overview

`zztable1` provides an architecture for creating publication-ready
summary tables (Table 1) commonly used in biomedical research and
clinical trials, built on a lazy evaluation blueprint system.

### Key Features

- **Lazy Evaluation**: Statistics are computed when the table is
  rendered, and cached for reuse
- **Journal Theming**: NEJM, Lancet, JAMA, BMJ formatting styles
- **Footnotes**: Variable-specific, column, and general footnotes
- **Multiple Formats**: Console, LaTeX, and HTML output (column headers
  and group sizes in LaTeX and HTML; the console renderer currently
  prints no header row)
- **Configurable Statistics**: Built-in and custom summary functions
- **Stratified Analysis**: Subgroup analysis support

### Installation

``` r

# Development version from GitHub
# install.packages('pak')
pak::pak('rgt47/zztable1')

# When available on CRAN:
# install.packages('zztable1')
```

### Quick Start

``` r

# Load required libraries
library(datasets)

# Prepare data
data(mtcars)
mtcars$transmission <- factor(
  ifelse(mtcars$am == 1, "Manual", "Automatic")
)

# Create basic summary table
bp <- table1(transmission ~ mpg + hp + wt, data = mtcars)
print(bp)

# With journal theming and footnotes
bp_nejm <- table1(transmission ~ mpg + hp + wt, 
                  data = mtcars,
                  theme = "nejm",
                  pvalue = TRUE,
                  footnotes = list(
                    variables = list(
                      mpg = "EPA fuel economy rating",
                      hp = "Gross horsepower",
                      wt = "Vehicle weight (1000 lbs)"
                    ),
                    general = c("Data from mtcars dataset")
                  ))
display_table(bp_nejm, mtcars)
```

### Architecture

The package uses a **lazy evaluation blueprint** approach:

1.  **Formula Analysis** → Determines table dimensions and structure
2.  **Blueprint Creation** → Stores computation expressions in cells (no
    statistics computed)
3.  **Lazy Evaluation** → Computes statistics when the table is rendered
4.  **Multiple Output** → Same blueprint renders to different formats

``` r

# Builds the blueprint; statistics are not yet computed
bp <- table1(group ~ var1 + var2 + var3, data = large_dataset)

# Statistics are computed on first render and cached in the blueprint
display_table(bp, large_dataset)
as.data.frame(bp)  # Reuses the cached results
```

Blueprints have value semantics (since 0.7.0). Functions that modify a
blueprint, such as
[`add_spanner()`](https://rgt47.github.io/zztable1/reference/add_spanner.md)
and
[`add_summary_rows()`](https://rgt47.github.io/zztable1/reference/add_summary_rows.md),
return a modified copy, so assign the result:
`bp <- add_spanner(bp, ...)`.

### Journal Theming

Built-in themes for major medical journals, plus `"console"` (the
default) and `"simple"`:

``` r

# List available themes
list_available_themes()

# NEJM style (1 decimal place, ± separator, symbol footnote markers)
bp_nejm <- table1(group ~ variables, data = data, theme = "nejm")

# Lancet style (1 decimal place, lettered footnotes)
bp_lancet <- table1(group ~ variables, data = data, theme = "lancet")

# JAMA style (1 decimal place, lettered footnotes)
bp_jama <- table1(group ~ variables, data = data, theme = "jama")

# BMJ style (2 decimal places)
bp_bmj <- table1(group ~ variables, data = data, theme = "bmj")
```

Custom themes can be created with
[`create_custom_theme()`](https://rgt47.github.io/zztable1/reference/create_custom_theme.md)
and added with
[`register_theme()`](https://rgt47.github.io/zztable1/reference/register_theme.md).

### Advanced Features

#### Custom Numeric Summaries

``` r

# Built-in options
table1(group ~ var, data = data, numeric_summary = "median_iqr")
table1(group ~ var, data = data, numeric_summary = "mean_se")

# Custom function
custom_summary <- function(x) {
  paste0(round(median(x, na.rm = TRUE), 1), " [", 
         round(min(x, na.rm = TRUE), 1), "-",
         round(max(x, na.rm = TRUE), 1), "]")
}
table1(group ~ var, data = data, numeric_summary = custom_summary)
```

#### Targeted Footnotes

``` r

table1(group ~ var1 + var2, data = data,
       footnotes = list(
         # Variable-specific with superscripts
         variables = list(
           var1 = "Measured at baseline",
           var2 = "Primary endpoint" 
         ),
         # Column-specific
         columns = list(
           "p.value" = "Two-tailed t-test, α = 0.05"
         ),
         # General footnotes (a character vector)
         general = c(
           "ITT population (N=500)",
           "Data are mean (SD) or n (%)"
         )
       ))
```

#### Stratified Analysis

``` r

# Subgroup analysis by center, gender, etc.
table1(treatment ~ age + sex + bmi, 
       data = trial_data,
       strata = "center",
       theme = "nejm")
```

### Output Formats

The output format is chosen when the table is rendered. The `layout`
argument of
[`table1()`](https://rgt47.github.io/zztable1/reference/table1.md) sets
how footnote markers are written into variable labels, so set it to
match the intended output.

#### Console Output

``` r

bp <- table1(group ~ variables, data = data)
render_console(bp)  # or display_table(bp, data)
```

#### LaTeX Output

``` r

bp <- table1(group ~ variables, data = data, layout = "latex", theme = "nejm")
render_latex(bp)  # or display_table(bp, data, format = "latex")
# In R Markdown, print with cat() in a chunk with results='asis'
```

#### HTML Output

``` r

bp <- table1(group ~ variables, data = data, layout = "html")
render_html(bp)  # or display_table(bp, data, format = "html")
```

#### Conditional Formatting in R Markdown

To choose the format from the document’s output type:

``` r

# Helper function for conditional formatting
create_table <- function(formula, data, ...) {
  # Determine output format
  if (knitr::is_latex_output()) {
    format_type <- "latex"
  } else {
    format_type <- "html"
  }
  
  bp <- table1(formula = formula, data = data, layout = format_type, ...)
  display_table(bp, data, format = format_type)
}

# Use in a chunk with results='asis'
create_table(group ~ variables, data = data, theme = "nejm")
```

### Clinical Trial Example

``` r

# Typical baseline characteristics table
baseline_table <- table1(
  treatment ~ age + sex + race + baseline_bmi + diabetes + hypertension,
  data = trial_data,
  theme = "nejm",
  pvalue = TRUE,
  footnotes = list(
    variables = list(
      age = "Age at enrollment (years)",
      baseline_bmi = "Body mass index at baseline (kg/m²)",
      diabetes = "Type 2 diabetes mellitus diagnosis",
      hypertension = "Hypertension diagnosis per medical history"
    ),
    columns = list(
      "p.value" = "t-test (F-test for 3+ groups) for continuous, Fisher exact test for categorical variables"
    ),
    general = c(
      "Data are mean (SD) for continuous variables, n (%) for categorical",
      "Intent-to-treat population (N=500)",
      "Missing values excluded from percentage calculations"
    )
  )
)

display_table(baseline_table, trial_data)
```

### Performance

Cell statistics are computed on the first render and cached in the
blueprint, so later renders of the same blueprint (for example to
console and then to LaTeX) reuse the cached values. `NEWS.md` (version
0.6.0) records the timings measured when the cache was repaired.

### API Reference

#### Main Functions

- [`table1()`](https://rgt47.github.io/zztable1/reference/table1.md) -
  Create summary table blueprint
- [`display_table()`](https://rgt47.github.io/zztable1/reference/display_table.md) -
  Display formatted table  
- [`render_console()`](https://rgt47.github.io/zztable1/reference/render_console.md),
  [`render_latex()`](https://rgt47.github.io/zztable1/reference/render_latex.md),
  [`render_html()`](https://rgt47.github.io/zztable1/reference/render_html.md) -
  Render to a format
- [`add_spanner()`](https://rgt47.github.io/zztable1/reference/add_spanner.md),
  [`add_spanner_delim()`](https://rgt47.github.io/zztable1/reference/add_spanner_delim.md) -
  Column spanners (assign the result)
- [`add_summary_rows()`](https://rgt47.github.io/zztable1/reference/add_summary_rows.md),
  [`add_grand_summary_rows()`](https://rgt47.github.io/zztable1/reference/add_grand_summary_rows.md) -
  Summary rows (assign the result)
- [`list_available_themes()`](https://rgt47.github.io/zztable1/reference/list_available_themes.md) -
  Show available themes
- [`register_theme()`](https://rgt47.github.io/zztable1/reference/register_theme.md),
  [`create_custom_theme()`](https://rgt47.github.io/zztable1/reference/create_custom_theme.md) -
  Custom themes
- [`Table1Blueprint()`](https://rgt47.github.io/zztable1/reference/Table1Blueprint.md) -
  Create blueprint object (advanced)
- [`Cell()`](https://rgt47.github.io/zztable1/reference/Cell.md) -
  Create cell object (advanced)

#### Key Parameters

- `formula` - Formula: `group ~ var1 + var2 + ...`
- `data` - Data frame with variables
- `theme` - Theme: “console” (default), “nejm”, “lancet”, “jama”, “bmj”,
  “simple”
- `pvalue` - Include statistical tests
- `totals` - Include overall column
- `strata` - Stratification variable
- `numeric_summary` - Summary statistic type
- `footnotes` - Footnote specifications
- `layout` - Target format for footnote markers: “console”, “latex”,
  “html”

### Testing

Run the test suite (tinytest):

``` r

tinytest::test_package("zztable1")
```

### Documentation

- **Vignettes**: see the `vignettes/` directory for the package guide
  and topic tutorials
- **Help Files**: function documentation via
  [`?table1`](https://rgt47.github.io/zztable1/reference/table1.md) and
  friends
- **Tests**: `inst/tinytest/` - tinytest suite run by `tests/tinytest.R`

### Contributing

This is a research/development project. Key areas for contribution:

1.  **Additional Journal Themes** - More publication styles
2.  **Export Functions** - Word export (LaTeX and HTML rendering exist)
3.  **Advanced Statistics** - Additional statistical tests
4.  **Error Handling** - Enhanced input validation
5.  **Performance** - Further optimization for very large datasets

### Roadmap

Planned, not yet implemented:

Additional journal themes (BMC, PLOS, etc.)

CRAN submission

Interactive table editor and GUI

### License

GPL (\>= 3)

### Citation

``` bibtex
@software{zztable1,
  title = {zztable1: Next Generation Summary Tables},
  author = {Ronald G. Thomas},
  year = {2026},
  note = {R package version 0.7.0},
  url = {https://github.com/rgt47/zztable1}
}
```

### Support

- **Issues**: Report bugs and feature requests
- **Documentation**: See vignette and help files  
- **Examples**: Check `inst/tinytest/` and `vignettes/` directories

------------------------------------------------------------------------

zztable1 – A formula-based framework for generating publication-ready
summary tables.
