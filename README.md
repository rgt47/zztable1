# zztable1

<!-- badges: start -->
[![R-CMD-check](https://github.com/yourusername/zztable1/workflows/R-CMD-check/badge.svg)](https://github.com/yourusername/zztable1/actions)
<!-- badges: end -->

## Overview

`zztable1` is an R package for creating publication-ready summary tables for clinical trial data. It simplifies the process of generating "Table 1" style baseline characteristic summaries by treatment group, with appropriate statistical tests and formatting.

## Features

- Summarize both categorical and continuous variables
- Calculate appropriate statistics (counts, percentages, means, SDs)
- Compute p-values using appropriate statistical tests
- Handle missing data with customizable display options
- Stratify results by another variable
- Export to LaTeX with customizable styling

## Installation

You can install the development version of zztable1 from GitHub with:

```r
# install.packages("devtools")
devtools::install_github("yourusername/zztable1")
```

## Usage

### Basic Table

```r
library(zztable1)

# Create a basic summary table
table1(arm ~ age + sex + bmi, data = trial_data)
```

### Adding Totals and Group Sizes

```r
table1(arm ~ age + sex + bmi, 
      data = trial_data,
      totals = TRUE,
      size = TRUE)
```

### Handling Missing Data

```r
table1(arm ~ age + sex, 
      data = trial_data,
      missing = TRUE)
```

### Stratified Tables

```r
table1(arm ~ age + sex, 
      data = trial_data,
      strata = "site")
```

### Exporting to LaTeX

```r
# Create a table
tab <- table1(arm ~ age + sex + bmi, data = trial_data)

# Export to LaTeX
latex(tab, digits = 2, fname = "my_table")
```

## Example Output

A simple table for a clinical trial might look like:

| Variable | Treatment (n=50) | Placebo (n=50) | p-value |
|----------|------------------|----------------|---------|
| **Age**  | 45.2 (14.3)      | 44.9 (13.7)    | 0.876   |
| **Sex**  |                  |                | 0.342   |
| Male     | 28 (56%)         | 24 (48%)       |         |
| Female   | 22 (44%)         | 26 (52%)       |         |
| **BMI**  | 26.3 (5.2)       | 25.8 (4.9)     | 0.721   |

## Documentation

For more detailed information, see the package vignette:

```r
vignette("zztable1-intro", package = "zztable1")
```

## Citation

If you use this package in your research, please cite:

```
Your Name (Year). zztable1: Create Publication-Ready Summary Tables for Clinical Trials. 
R package version 0.1.0. https://github.com/yourusername/zztable1
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

This package builds on concepts from several existing table-making packages in R:
- `tableone`
- `gtsummary`
- `arsenal`
