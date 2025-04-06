# zztable1

<!-- badges: start -->
[![R-CMD-check](https://github.com/rgt47/zztable1/workflows/R-CMD-check/badge.svg)](https://github.com/rgt47/zztable1/actions)
<!-- badges: end -->

## Overview

`zztable1` is an R package for creating publication-ready summary tables for clinical trial data. It simplifies the process of generating "Table 1" style baseline characteristic summaries by treatment group, with appropriate statistical tests and formatting.

## Features

- Summarize both categorical and continuous variables with appropriate statistics
- Calculate counts and percentages for categorical variables
- Calculate means and standard deviations for continuous variables
- Compute p-values using appropriate statistical tests (Fisher's exact test for categorical variables, linear regression for continuous variables)
- Handle missing data with customizable display options
- Stratify results by another variable for subgroup analysis
- Export to LaTeX with NEJM-style formatting or custom styling
- Control display of totals, group sizes, and p-values

## Installation

You can install the development version of zztable1 from GitHub with:

```r
# install.packages("devtools")
devtools::install_github("rgt47/zztable1")
```

## Dependencies

`zztable1` relies on several packages from the tidyverse and other useful packages:

- **Data manipulation**: purrr, dplyr, tibble
- **Table utilities**: kableExtra, janitor
- **Statistics**: broom, stats
- **Data manipulation**: berryFunctions

These dependencies will be automatically installed when you install the package.

## Usage

### Basic Table

```r
library(zztable1)

# Create a sample dataset
set.seed(123)
trial_data <- data.frame(
  arm = factor(rep(c("Treatment", "Placebo"), each = 50)),
  age = rnorm(100, mean = 45, sd = 15),
  sex = factor(sample(c("Male", "Female"), 100, replace = TRUE)),
  bmi = rnorm(100, mean = 26, sd = 5)
)

# Create a basic summary table
table1(form = arm ~ age + sex + bmi, data = trial_data)
```

### Adding Totals and Group Sizes

```r
table1(form = arm ~ age + sex + bmi, 
      data = trial_data,
      totals = TRUE,
      size = TRUE)
```

### Handling Missing Data

```r
# Add some missing values
trial_data$age[sample(1:100, 5)] <- NA
trial_data$bmi[sample(1:100, 8)] <- NA

# Create table showing missing data
table1(form = arm ~ age + sex + bmi, 
      data = trial_data,
      missing = TRUE)
```

### Disabling P-values

```r
table1(form = arm ~ age + sex + bmi, 
      data = trial_data,
      pvalue = FALSE)
```

### Stratified Tables

```r
# Add a stratification variable
trial_data$site <- factor(sample(c("Site1", "Site2", "Site3"), 100, replace = TRUE))

# Create a stratified table
table1(form = arm ~ age + sex + bmi, 
      data = trial_data,
      strata = "site")
```

### Tables Without a Grouping Variable

```r
# Create a table without group comparisons
table1(form = ~ age + sex + bmi, 
      data = trial_data,
      totals = TRUE,
      pvalue = FALSE)
```

### Exporting to LaTeX with NEJM Styling

```r
# Create a table
tab <- table1(form = arm ~ age + sex + bmi, data = trial_data)

# Export to LaTeX with NEJM-style formatting
latex(tab, digits = 2, fname = "my_table")
```

### Custom Styling for LaTeX Output

```r
# Define a custom theme
my_theme <- list(
  foreground = c("black", "darkblue", "black", "darkblue", "black"),
  background = c("#f5f5f5", "white", "#e6e6e6", "white", "#f0f0f0")
)

# Export with custom styling
latex(tab, digits = 2, fname = "custom_table", theme = my_theme)
```

## Function Reference

### Main Functions

- `table1()`: Create summary tables with formula interface
- `latex()`: Export tables to LaTeX format with custom styling

### Supporting Functions

- `row_name()`: Generate appropriate row names for variables
- `row_summary()`: Generate summary statistics for variables
- `row_pv()`: Calculate p-values for group comparisons

## Example Output

A simple table for a clinical trial might look like:

| Variable | Treatment (n=50) | Placebo (n=50) | p-value |
|----------|------------------|----------------|---------|
| **Age**  | 45.2 (14.3)      | 44.9 (13.7)    | 0.876   |
| **Sex**  |                  |                | 0.342   |
| Male     | 28 (56%)         | 24 (48%)       |         |
| Female   | 22 (44%)         | 26 (52%)       |         |
| **BMI**  | 26.3 (5.2)       | 25.8 (4.9)     | 0.721   |

## Customization Options

### Table Options

| Option    | Description                               | Default |
|-----------|-------------------------------------------|---------|
| `totals`  | Include a totals column                   | FALSE   |
| `missing` | Show counts of missing values             | FALSE   |
| `pvalue`  | Include p-values for group comparisons    | TRUE    |
| `size`    | Show group sizes in the table             | FALSE   |

### LaTeX Formatting Options

| Option    | Description                               | Default |
|-----------|-------------------------------------------|---------|
| `digits`  | Number of decimal places for numeric data | 3       |
| `fname`   | Filename for the output LaTeX file        | "table0"|
| `theme`   | Styling theme with colors                 | theme_nejm |

## Documentation

For more detailed information, see the package vignette:

```r
vignette("zztable1-intro", package = "zztable1")
```

## Citation

If you use this package in your research, please cite:

```
Ronald (Ryy) G. Thomas (2025). zztable1: Create Publication-Ready Summary Tables for Clinical Trials. 
R package version 0.1.0. https://github.com/rgt47/zztable1
```

## License

This project is licensed under the GPL-3 License - see the LICENSE file for details.

## Acknowledgments

This package builds on concepts from several existing table-making packages in R:
- `tableone`
- `gtsummary`
- `arsenal`
- `janitor`
