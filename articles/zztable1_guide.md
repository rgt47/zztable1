# zztable1: Advanced Publication-Ready Summary Tables

## Introduction

The `zztable1` package provides a next-generation architecture for
creating publication-ready summary tables (commonly called “Table 1”)
used in biomedical research and clinical trials. This vignette
demonstrates the key features and capabilities of the package.

### Key Features

- **Lazy Evaluation Architecture**: Fast blueprint creation with
  computation on demand
- **Journal-Specific Theming**: NEJM, Lancet, JAMA, BMJ formatting
  styles
- **Advanced Footnote System**: Variable-specific, column-specific, and
  general footnotes with superscript markers
- **Multiple Output Formats**: Console, LaTeX, and HTML output with
  proper column headers
- **Flexible Statistics**: Built-in and custom summary statistics
- **Stratified Analysis**: Support for subgroup analyses
- **Full Compatibility**: Same interface as original zztable1 package
- **R Markdown Integration**: Automatic format detection for seamless
  PDF/HTML output

### Installation and Setup

``` r

# Development version
devtools::install_github("rgt47/zztable1")
```

## Basic Usage

### Simple Summary Tables

Let’s start with a basic example using the mtcars dataset:

``` r

# Prepare data
data(mtcars)
mtcars$transmission <- factor(
  ifelse(mtcars$am == 1, "Manual", "Automatic"),
  levels = c("Automatic", "Manual")
)
mtcars$engine_type <- factor(
  ifelse(mtcars$vs == 1, "V-shaped", "Straight"),
  levels = c("Straight", "V-shaped")
)

# Create basic summary table
create_table(transmission ~ mpg + hp + wt, data = mtcars)
```

[TABLE]

### Adding Statistical Tests

Include p-values for group comparisons:

``` r

create_table(transmission ~ mpg + hp + wt,
             data = mtcars,
             pvalue = TRUE)
```

[TABLE]

### Including Total Column

Add an overall summary column:

``` r

create_table(transmission ~ mpg + hp + wt,
             data = mtcars,
             pvalue = TRUE,
             totals = TRUE)
```

[TABLE]

## Advanced Features

### Custom Numeric Summaries

#### Built-in Options

The package provides several built-in summary statistics:

``` r

# Default: Mean (SD)
cat("Mean (SD) format:\n")
```

Mean (SD) format:

``` r

create_table(transmission ~ mpg + hp, data = mtcars)
```

[TABLE]

``` r


# Median [IQR]
cat("\nMedian [IQR] format:\n")
```

Median \[IQR\] format:

``` r

create_table(transmission ~ mpg + hp, data = mtcars,
             numeric_summary = "median_iqr")
```

[TABLE]

``` r


# Mean +/- SE
cat("\nMean +/- SE format:\n")
```

Mean +/- SE format:

``` r

create_table(transmission ~ mpg + hp, data = mtcars,
             numeric_summary = "mean_se")
```

[TABLE]

#### Custom Functions

Create your own summary statistics:

``` r

# Custom function: Median (Min-Max)
custom_summary <- function(x) {
  med <- round(median(x, na.rm = TRUE), 1)
  min_val <- round(min(x, na.rm = TRUE), 1)
  max_val <- round(max(x, na.rm = TRUE), 1)
  paste0(med, " (", min_val, "-", max_val, ")")
}

cat("Custom Median (Min-Max) format:\n")
```

Custom Median (Min-Max) format:

``` r

create_table(transmission ~ mpg + hp, data = mtcars,
             numeric_summary = custom_summary)
```

[TABLE]

### Stratified Analysis

Perform subgroup analyses using stratification:

``` r

# Create stratification variable
mtcars$cylinder_group <- factor(
  ifelse(mtcars$cyl <= 4, "4-cylinder",
  ifelse(mtcars$cyl <= 6, "6-cylinder", "8-cylinder")),
  levels = c("4-cylinder", "6-cylinder", "8-cylinder")
)

# Stratified analysis
create_table(transmission ~ mpg + hp,
             data = mtcars,
             strata = "cylinder_group",
             pvalue = TRUE)
```

[TABLE]

## Journal-Specific Theming

### Available Themes

View all available themes:

``` r

themes <- list_available_themes()
print(themes)
```

\[1\] “console” “nejm” “lancet” “jama” “bmj” “simple”

### Theme Comparison

#### Console Theme (Default)

``` r

cat("Console Theme:\n")
```

Console Theme:

``` r

create_table(transmission ~ mpg + hp, data = mtcars,
             theme = "console")
```

[TABLE]

#### NEJM Theme (1 decimal place)

``` r

cat("NEJM Theme (1 decimal place):\n")
```

NEJM Theme (1 decimal place):

``` r

create_table(transmission ~ mpg + hp, data = mtcars,
             theme = "nejm")
```

[TABLE]

#### JAMA Theme (1 decimal place)

``` r

cat("JAMA Theme (2 decimal places):\n")
```

JAMA Theme (2 decimal places):

``` r

create_table(transmission ~ mpg + hp, data = mtcars,
             theme = "jama")
```

[TABLE]

#### Lancet Theme

``` r

cat("Lancet Theme:\n")
```

Lancet Theme:

``` r

create_table(transmission ~ mpg + hp, data = mtcars,
             theme = "lancet")
```

[TABLE]

## Footnote System

### Variable-Specific Footnotes

Add footnotes to specific variables with superscript markers:

``` r

create_table(transmission ~ mpg + hp + wt,
             data = mtcars,
             theme = "nejm",
             footnotes = list(
               variables = list(
                 mpg = "EPA fuel economy rating in miles per gallon",
                 hp = "Gross horsepower measured at crankshaft",
                 wt = "Vehicle weight in thousands of pounds"
               )
             ))
```

[TABLE]

### Column-Specific Footnotes

Add footnotes to columns:

``` r

create_table(transmission ~ mpg + hp,
             data = mtcars,
             theme = "nejm",
             pvalue = TRUE,
             footnotes = list(
               columns = list(
                 "p.value" = "Two-tailed t-test, alpha = 0.05"
               )
             ))
```

[TABLE]

### Comprehensive Footnotes

Combine multiple footnote types:

``` r

create_table(transmission ~ mpg + hp,
             data = mtcars,
             theme = "nejm",
             pvalue = TRUE,
             footnotes = list(
               variables = list(
                 mpg = "EPA fuel economy standard",
                 hp = "Gross horsepower"
               ),
               columns = list(
                 "p.value" = "Statistical significance testing"
               ),
               general = list(
                 "Data source: Henderson and Velleman (1981)",
                 "Missing values excluded from analysis"
               )
             ))
```

[TABLE]

## Clinical Trial Example

### Simulated Clinical Trial Data

Let’s create a more realistic clinical trial example:

``` r

set.seed(123)
n <- 200

# Generate clinical trial data
trial_data <- data.frame(
  patient_id = 1:n,
  treatment = factor(
    sample(c("Placebo", "Drug A", "Drug B"), n, replace = TRUE),
    levels = c("Placebo", "Drug A", "Drug B")
  ),
  age = round(rnorm(n, 65, 12)),
  sex = factor(sample(c("Male", "Female"), n, replace = TRUE)),
  race = factor(
    sample(c("White", "Black", "Hispanic", "Asian", "Other"), 
           n, replace = TRUE, prob = c(0.6, 0.2, 0.1, 0.08, 0.02)),
    levels = c("White", "Black", "Hispanic", "Asian", "Other")
  ),
  baseline_bmi = round(rnorm(n, 28, 5), 1),
  diabetes = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.7, 0.3))),
  hypertension = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.6, 0.4))),
  center = factor(sample(paste("Center", 1:4), n, replace = TRUE))
)

# Preview the data
head(trial_data, 10)
```

patient_id treatment age sex race baseline_bmi diabetes hypertension 1 1
Drug B 70 Female Black 25.5 Yes No 2 2 Drug B 65 Male White 20.9 No Yes
3 3 Drug B 60 Male Black 28.6 No Yes 4 4 Drug A 40 Male White 37.7 Yes
No 5 5 Drug B 79 Male White 32.0 Yes Yes 6 6 Drug A 47 Male White 33.8
No No 7 7 Drug A 74 Female White 29.8 No No 8 8 Drug A 88 Female White
25.0 No No 9 9 Drug B 48 Female White 27.0 Yes Yes 10 10 Placebo 73 Male
White 26.6 No No center 1 Center 3 2 Center 1 3 Center 3 4 Center 4 5
Center 1 6 Center 1 7 Center 4 8 Center 2 9 Center 3 10 Center 3

### Basic Clinical Table 1

``` r

create_table(treatment ~ age + sex + race + baseline_bmi +
             diabetes + hypertension,
             data = trial_data,
             theme = "nejm",
             pvalue = TRUE)
```

[TABLE]

### With Footnotes and Stratification

``` r

create_table(treatment ~ age + sex + race + baseline_bmi +
             diabetes + hypertension,
             data = trial_data,
             strata = "center",
             theme = "nejm",
             pvalue = TRUE,
             footnotes = list(
               variables = list(
                 age = "Age at enrollment (years)",
                 baseline_bmi = "Body mass index at baseline (kg/m²)",
                 diabetes = "Type 2 diabetes mellitus diagnosis",
                 hypertension = "Hypertension diagnosis"
               ),
               columns = list(
                 "p.value" = "ANOVA for continuous, chi-squared for categorical"
               ),
               general = list(
                 "Data are mean (SD) or n (%)",
                 "ITT population (N=200)"
               )
             ))
```

[TABLE]

## Different Output Formats

### Console Output (Default)

``` r

create_table(transmission ~ mpg + hp, data = mtcars, theme = "nejm")
```

[TABLE]

### LaTeX Output

``` r

bp_latex <- table1(transmission ~ mpg + hp, data = mtcars,
                   layout = "latex", theme = "nejm")

# Note: LaTeX output would contain LaTeX markup
cat("LaTeX theme config:\n")
```

LaTeX theme config:

``` r

cat("Font size:", bp_latex$metadata$theme$latex$font_size, "\n")
```

Font size:

``` r

cat("Packages:", paste(bp_latex$metadata$theme$latex$packages, collapse = ", "), "\n")
```

Packages:

### HTML Output

``` r

bp_html <- table1(transmission ~ mpg + hp, data = mtcars,
                  layout = "html", theme = "nejm")

# Note: HTML output would contain HTML markup
cat("HTML theme ready for web display\n")
```

HTML theme ready for web display

## Performance and Architecture

### Blueprint Architecture

The lazy evaluation approach provides several benefits:

``` r

# Large dataset simulation
large_data <- data.frame(
  group = factor(sample(c("A", "B", "C"), 10000, replace = TRUE)),
  var1 = rnorm(10000),
  var2 = rnorm(10000),
  var3 = rnorm(10000),
  var4 = rnorm(10000),
  var5 = rnorm(10000)
)

# Fast blueprint creation (no computations yet)
system.time({
  bp_large <- table1(group ~ var1 + var2 + var3 + var4 + var5, 
                     data = large_data)
})
```

user system elapsed 0.004 0.000 0.004

``` r


# Computations happen only during display
cat("Blueprint created instantly. Computations happen during display.\n")
```

Blueprint created instantly. Computations happen during display.

``` r

cat("Blueprint dimensions:", dim(bp_large), "\n")
```

Blueprint dimensions: 5 5

### Memory Efficiency

``` r

# Blueprint object structure
bp_small <- table1(transmission ~ mpg, data = mtcars)

cat("Blueprint components:\n")
```

Blueprint components:

``` r

cat("- Cells: ", length(bp_small$cells), "\n")
```

- Cells: 4

``` r

cat("- Dimensions: ", dim(bp_small), "\n")
```

- Dimensions: 1 4

``` r

cat("- Metadata keys: ", names(bp_small$metadata), "\n")
```

- Metadata keys: formula options data_info data dimensions
  footnote_markers footnote_list created optimized version cell_count
  theme stat_cache spanner_store summary_store

## Best Practices

### Recommendations

1.  **Choose Appropriate Themes**: Use journal-specific themes for
    manuscript preparation
2.  **Add Informative Footnotes**: Explain variables and statistical
    methods
3.  **Use Stratification Wisely**: For meaningful subgroup analyses
4.  **Custom Functions**: Create domain-specific summary statistics
5.  **Validate Results**: Check statistical assumptions and interpret
    p-values carefully

### Common Patterns

``` r

# Standard clinical trial baseline table
create_baseline_table <- function(data, treatment_var, theme = "nejm") {
  formula_str <- paste(treatment_var, "~ .")
  bp <- table1(as.formula(formula_str), 
               data = data,
               theme = theme,
               pvalue = TRUE,
               footnotes = list(
                 general = list(
                   "Data are mean (SD) or n (%)",
                   "P-values from ANOVA or chi-squared test"
                 )
               ))
  return(bp)
}

# Example usage
# bp_standard <- create_baseline_table(trial_data, "treatment")
cat("Utility function created for standardized baseline tables\n")
```

Utility function created for standardized baseline tables

## Troubleshooting

### Common Issues

1.  **Missing Variables**: Ensure all formula variables exist in the
    data
2.  **Factor Levels**: Check factor level ordering for expected display
3.  **Missing Values**: Use `missing = TRUE` to show missing counts
4.  **Theme Application**: Themes affect decimal places and formatting
5.  **Large Tables**: Use stratification to break down complex tables

### Error Handling

``` r

# Example of error handling
tryCatch({
  # This will cause an error - variable doesn't exist
  bp_error <- table1(nonexistent_var ~ mpg, data = mtcars)
}, error = function(e) {
  cat("Error caught:", e$message, "\n")
  cat("Solution: Check that all variables in formula exist in data\n")
})
```

Error caught: Variables not found in data: nonexistent_var

Available variables: mpg, cyl, disp, hp, drat, wt, qsec, vs, am, gear,
carb, transmission, engine_type, cylinder_group Solution: Check that all
variables in formula exist in data

## Conclusion

The `zztable1` package provides a powerful, flexible system for creating
publication-ready summary tables. Key advantages include:

- **Performance**: Lazy evaluation for fast blueprint creation
- **Flexibility**: Multiple themes, custom statistics, advanced
  footnotes  
- **Compatibility**: Same interface as original zztable1
- **Publication-Ready**: Journal-specific formatting out of the box

For more information, see the package documentation and function help
files.

------------------------------------------------------------------------

### Session Information

``` r

sessionInfo()
```

R version 4.6.0 (2026-04-24) Platform: x86_64-pc-linux-gnu Running
under: Ubuntu 24.04.4 LTS

Matrix products: default BLAS:
/usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 LAPACK:
/usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;
LAPACK version 3.12.0

locale: \[1\] LC_CTYPE=C.UTF-8 LC_NUMERIC=C LC_TIME=C.UTF-8  
\[4\] LC_COLLATE=C.UTF-8 LC_MONETARY=C.UTF-8 LC_MESSAGES=C.UTF-8  
\[7\] LC_PAPER=C.UTF-8 LC_NAME=C LC_ADDRESS=C  
\[10\] LC_TELEPHONE=C LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C

time zone: UTC tzcode source: system (glibc)

attached base packages: \[1\] stats graphics grDevices utils datasets
methods base

other attached packages: \[1\] zztable1_0.5.0 kableExtra_1.4.0
htmltools_0.5.9

loaded via a namespace (and not attached): \[1\] vctrs_0.7.3
svglite_2.2.2 cli_3.6.6 knitr_1.51  
\[5\] rlang_1.2.0 xfun_0.57 stringi_1.8.7 otel_0.2.0  
\[9\] textshaping_1.0.5 jsonlite_2.0.0 glue_1.8.1 ragg_1.5.2  
\[13\] sass_0.4.10 scales_1.4.0 rmarkdown_2.31 evaluate_1.0.5  
\[17\] jquerylib_0.1.4 fastmap_1.2.0 yaml_2.3.12 lifecycle_1.0.5  
\[21\] stringr_1.6.0 compiler_4.6.0 RColorBrewer_1.1-3 fs_2.1.0  
\[25\] htmlwidgets_1.6.4 rstudioapi_0.18.0 farver_2.1.2
systemfonts_1.3.2 \[29\] digest_0.6.39 viridisLite_0.4.3 R6_2.6.1
pillar_1.11.1  
\[33\] parallel_4.6.0 magrittr_2.0.5 bslib_0.10.0 tools_4.6.0  
\[37\] xml2_1.5.2 pkgdown_2.2.0 cachem_1.1.0 desc_1.4.3
