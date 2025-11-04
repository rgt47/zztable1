# zztable1

## Next-Generation Publication-Ready Summary Tables

[![R](https://img.shields.io/badge/R-3.5+-blue.svg)](https://www.r-project.org/)
[![Status](https://img.shields.io/badge/Status-Development-orange.svg)]()
[![Tests](https://img.shields.io/badge/Tests-91.9%25%20Pass-brightgreen.svg)]()

### Overview

`zztable1` provides a next-generation architecture for creating
publication-ready summary tables (Table 1) commonly used in biomedical
research and clinical trials. The package maintains full compatibility 
with the original `zztable1` interface while providing enhanced features
through a lazy evaluation blueprint system.

### Key Features

- **🚀 Lazy Evaluation**: Fast blueprint creation with computation on demand
- **📊 Journal Theming**: NEJM, Lancet, JAMA, BMJ formatting styles
- **📝 Advanced Footnotes**: Variable-specific, targeted footnote system
- **📋 Multiple Formats**: Console, LaTeX, and HTML output with proper column headers
- **⚡ High Performance**: Efficient handling of large datasets
- **🔧 Flexible Statistics**: Built-in and custom summary functions
- **📈 Stratified Analysis**: Subgroup analysis support
- **✅ Full Compatibility**: Same interface as original zztable1
- **📄 R Markdown Ready**: Automatic format detection for seamless document integration

### Installation

```r
# Development version
source("zztable1.R")

# When available on CRAN:
# install.packages("zztable1")
```

### Quick Start

```r
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
                    general = list("Data from mtcars dataset")
                  ))
display_table(bp_nejm, mtcars)
```

### Architecture

The package uses a revolutionary **lazy evaluation blueprint** approach:

1. **Formula Analysis** → Determines table dimensions and structure
2. **Blueprint Creation** → Stores computation metadata (no calculations)
3. **Lazy Evaluation** → Executes calculations only when needed
4. **Multiple Output** → Same blueprint renders to different formats

```r
# Blueprint creation is instant (no computations)
bp <- table1(group ~ var1 + var2 + var3, data = large_dataset)  # Fast!

# Calculations happen during display
display_table(bp, large_dataset)    # Computes on demand
as.data.frame(bp, data = large_dataset)  # Cached for performance
```

### Journal Theming

Built-in themes for major medical journals:

```r
# List available themes
list_available_themes()

# NEJM style (1 decimal place, numbered footnotes)
bp_nejm <- table1(group ~ variables, data = data, theme = "nejm")

# Lancet style (1 decimal, Vancouver formatting)
bp_lancet <- table1(group ~ variables, data = data, theme = "lancet")

# JAMA style (2 decimals, lettered footnotes)  
bp_jama <- table1(group ~ variables, data = data, theme = "jama")

# BMJ style (minimal formatting)
bp_bmj <- table1(group ~ variables, data = data, theme = "bmj")
```

### Advanced Features

#### Custom Numeric Summaries

```r
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

#### Sophisticated Footnotes

```r
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
         # Cell-specific (advanced)
         cells = list(
           list(row = 2, col = 3, text = "Missing data excluded")
         ),
         # General footnotes
         general = list(
           "ITT population (N=500)",
           "Data are mean (SD) or n (%)"
         )
       ))
```

#### Stratified Analysis

```r
# Subgroup analysis by center, gender, etc.
table1(treatment ~ age + sex + bmi, 
       data = trial_data,
       strata = "center",
       theme = "nejm")
```

### Output Formats

#### Console Output
```r
table1(group ~ variables, data = data, layout = "console")
```

#### LaTeX Output  
```r
bp <- table1(group ~ variables, data = data, layout = "latex", theme = "nejm")
# Use in R Markdown with results='asis'
```

#### HTML Output
```r
bp <- table1(group ~ variables, data = data, layout = "html")
# Renders in R Markdown HTML output
```

#### Conditional Formatting in R Markdown

For automatic format detection in R Markdown documents:

```r
# Helper function for conditional formatting
create_table <- function(formula, data, ...) {
  # Determine output format
  if (knitr::is_latex_output()) {
    layout <- "latex"
    format_type <- "latex"
  } else {
    layout <- "html"
    format_type <- "html"
  }
  
  bp <- table1(form = formula, data = data, layout = layout, ...)
  display_table(bp, data, format = format_type)
}

# Use in R Markdown - automatically detects PDF vs HTML output
create_table(group ~ variables, data = data, theme = "nejm")
```

### Clinical Trial Example

```r
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
      "p.value" = "ANOVA for continuous, χ² test for categorical variables"
    ),
    general = list(
      "Data are mean (SD) for continuous variables, n (%) for categorical",
      "Intent-to-treat population (N=500)",
      "Missing values excluded from percentage calculations"
    )
  )
)

display_table(baseline_table, trial_data)
```

### Performance

The lazy evaluation architecture provides excellent performance:

```r
# Large dataset (10,000 rows × 50 variables)
system.time({
  bp <- table1(group ~ ., data = large_data)  # Instant blueprint
})
#>    user  system elapsed 
#>   0.003   0.000   0.003 

# Computations happen during display (cached for reuse)
system.time({
  display_table(bp, large_data)  # First evaluation
})
#>    user  system elapsed 
#>   0.243   0.002   0.245 

system.time({
  df <- as.data.frame(bp, data = large_data)  # Uses cached results
})
#>    user  system elapsed 
#>   0.001   0.000   0.001
```

### API Reference

#### Main Functions
- `table1()` - Create summary table blueprint
- `display_table()` - Display formatted table  
- `list_available_themes()` - Show available themes
- `Table1Blueprint()` - Create blueprint object (advanced)
- `Cell()` - Create cell object (advanced)

#### Key Parameters
- `form` - Formula: `group ~ var1 + var2 + ...`
- `data` - Data frame with variables
- `theme` - Journal style: "nejm", "lancet", "jama", "bmj"
- `pvalue` - Include statistical tests
- `totals` - Include overall column
- `strata` - Stratification variable
- `numeric_summary` - Summary statistic type
- `footnotes` - Footnote specifications
- `layout` - Output format: "console", "latex", "html"

### Testing

Run the comprehensive test suite:

```r
source("tests/test_all.R")
```

Current test results: **91.9% pass rate** (34/37 tests)

### Documentation

- **Vignette**: `vignettes/zztable1_guide.Rmd` - Comprehensive guide
- **Help Files**: All functions have detailed documentation with examples
- **Tests**: `tests/test_all.R` - Complete test suite

### Comparison with Original zztable1

| Feature | Original zztable1 | zztable1 |
|---------|------------------|------------------|
| **Architecture** | Immediate computation | Lazy evaluation blueprint |
| **Performance** | Slower with large data | Fast blueprint, cached results |
| **Memory** | Higher usage | Efficient metadata storage |
| **Theming** | Limited formatting | Journal-specific themes |
| **Footnotes** | Basic support | Advanced targeting system |
| **Extensibility** | Monolithic functions | Modular cell-based design |
| **Output Formats** | Single format | Multiple formats from blueprint |
| **Interface** | ✅ Same | ✅ Fully compatible |

### Contributing

This is a research/development project. Key areas for contribution:

1. **Additional Journal Themes** - More publication styles
2. **Export Functions** - Direct LaTeX/HTML/Word export
3. **Advanced Statistics** - More sophisticated statistical tests
4. **Error Handling** - Enhanced input validation
5. **Performance** - Further optimization for very large datasets

### Roadmap

- [ ] **v1.1**: Export functions for direct LaTeX/HTML output
- [ ] **v1.2**: Additional journal themes (BMC, PLOS, etc.)
- [ ] **v1.3**: Advanced statistical tests (non-parametric, etc.)
- [ ] **v1.4**: R package structure with CRAN submission
- [ ] **v2.0**: Interactive table editor and GUI

### License

[Specify license when ready for distribution]

### Citation

```bibtex
@software{zztable1,
  title = {zztable1: Next-Generation Publication-Ready Summary Tables},
  author = {Development Team},
  year = {2024},
  note = {R package version 0.9.0},
  url = {https://github.com/user/zztable1}
}
```

### Support

- **Issues**: Report bugs and feature requests
- **Documentation**: See vignette and help files  
- **Examples**: Check `tests/` and `vignettes/` directories

---

**zztable1** - Because publication-ready tables should be both
powerful and elegant. 🚀📊