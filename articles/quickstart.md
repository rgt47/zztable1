# Quickstart Guide: zztable1

## Overview

**zztable1** is a next-generation R package for creating
publication-quality summary tables (Table 1) with a flexible
blueprint-based architecture. The package features lazy evaluation,
sparse storage, and medical journal themes (NEJM, Lancet, JAMA).

## Installation

``` r

devtools::install_github("rgt47/zztable1")
library(zztable1)
```

## Sample Data

All examples below use a small simulated clinical trial dataset:

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
  ),
  site = factor(
    sample(paste("Site", LETTERS[1:3]), n,
           replace = TRUE)
  )
)

trial$bmi[sample(seq_len(n), 5)] <- NA
```

## Basic Usage

The formula interface: `grouping_variable ~ var1 + var2 + ...`

``` r

create_table(
  arm ~ age + sex + bmi + diabetes,
  data = trial,
  theme = "nejm"
)
```

[TABLE]

## Adding P-values and Totals

``` r

create_table(
  arm ~ age + sex + bmi + diabetes,
  data = trial,
  pvalue = TRUE,
  totals = TRUE,
  theme = "nejm"
)
```

[TABLE]

## Medical Journal Themes

### NEJM

``` r

create_table(
  arm ~ age + sex + bmi,
  data = trial,
  pvalue = TRUE,
  theme = "nejm"
)
```

[TABLE]

### Lancet

``` r

create_table(
  arm ~ age + sex + bmi,
  data = trial,
  pvalue = TRUE,
  theme = "lancet"
)
```

[TABLE]

### JAMA

``` r

create_table(
  arm ~ age + sex + bmi,
  data = trial,
  pvalue = TRUE,
  theme = "jama"
)
```

[TABLE]

## Numeric Summary Options

``` r

cat("### Mean (SD) -- default\n")
```

### Mean (SD) – default

``` r

create_table(
  arm ~ age + bmi, data = trial,
  numeric_summary = "mean_sd", theme = "console"
)
```

[TABLE]

``` r

cat("\n### Median [IQR]\n")
```

### Median \[IQR\]

``` r

create_table(
  arm ~ age + bmi, data = trial,
  numeric_summary = "median_iqr", theme = "console"
)
```

[TABLE]

``` r

cat("\n### Mean (95% CI)\n")
```

### Mean (95% CI)

``` r

create_table(
  arm ~ age + bmi, data = trial,
  numeric_summary = "mean_ci", theme = "console"
)
```

[TABLE]

## Statistical Tests

Default: t-test for continuous, Fisher’s exact for categorical.

``` r

create_table(
  arm ~ age + sex + diabetes,
  data = trial,
  pvalue = TRUE,
  continuous_test = "kruskal",
  categorical_test = "chisq",
  theme = "console"
)
```

[TABLE]

Available tests:

- Continuous: `"ttest"`, `"anova"`, `"welch"`, `"kruskal"`
- Categorical: `"chisq"`, `"fisher"`

## Stratified Analysis

``` r

create_table(
  arm ~ age + sex + bmi,
  data = trial,
  strata = "site",
  pvalue = TRUE,
  theme = "lancet"
)
```

[TABLE]

## Missing Data

``` r

create_table(
  arm ~ age + sex + bmi,
  data = trial,
  missing = TRUE,
  pvalue = TRUE,
  theme = "jama"
)
```

[TABLE]

## Available Themes

``` r

cat(paste(list_available_themes(), collapse = ", "), "\n")
```

console, nejm, lancet, jama, bmj, simple

## Function Reference

| Function | Purpose |
|:---|:---|
| [`table1()`](https://rgt47.github.io/zztable1/reference/table1.md) | Create Table 1 blueprint |
| [`print()`](https://rdrr.io/r/base/print.html) | Console output |
| [`render_console()`](https://rgt47.github.io/zztable1/reference/render_console.md) | Rendered console output |
| [`render_html()`](https://rgt47.github.io/zztable1/reference/render_html.md) | HTML output |
| [`render_latex()`](https://rgt47.github.io/zztable1/reference/render_latex.md) | LaTeX output |
| [`display_table()`](https://rgt47.github.io/zztable1/reference/display_table.md) | Auto-detect format and display |
| [`list_available_themes()`](https://rgt47.github.io/zztable1/reference/list_available_themes.md) | Show available themes |
| [`create_custom_theme()`](https://rgt47.github.io/zztable1/reference/create_custom_theme.md) | Create custom theme |

## Key Parameters

| Parameter          | Description               | Default   |
|:-------------------|:--------------------------|:----------|
| `theme`            | Journal theme             | “console” |
| `pvalue`           | Include p-values          | TRUE      |
| `totals`           | Include totals column     | FALSE     |
| `missing`          | Show missing counts       | FALSE     |
| `numeric_summary`  | Summary type              | “mean_sd” |
| `strata`           | Stratification variable   | NULL      |
| `continuous_test`  | Test for continuous vars  | “ttest”   |
| `categorical_test` | Test for categorical vars | “fisher”  |

## Formula Syntax

    grouping_variable ~ var1 + var2 + var3

## Next Steps

- [`vignette("theming_system")`](https://rgt47.github.io/zztable1/articles/theming_system.md)
  – Medical journal themes
- [`vignette("customizing_statistics")`](https://rgt47.github.io/zztable1/articles/customizing_statistics.md)
  – Custom summary functions
- [`vignette("stratified_examples")`](https://rgt47.github.io/zztable1/articles/stratified_examples.md)
  – Multi-center analyses
- [`vignette("dataset_examples")`](https://rgt47.github.io/zztable1/articles/dataset_examples.md)
  – Complete examples
