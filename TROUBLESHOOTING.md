# Troubleshooting Guide

This guide helps resolve common issues when using zztable1_nextgen.

## Table of Contents

1. [Installation & Loading](#installation--loading)
2. [Data Input Issues](#data-input-issues)
3. [Rendering & Output](#rendering--output)
4. [Themes & Styling](#themes--styling)
5. [Stratification & Analysis](#stratification--analysis)
6. [Performance Issues](#performance-issues)
7. [Getting Help](#getting-help)

---

## Installation & Loading

### Problem: Package doesn't load

**Error:** `Error in library(zztable1nextgen): there is no package called 'zztable1nextgen'`

**Solution:**
```r
# Install the package first
# From source directory:
devtools::install()

# Or from local path:
install.packages("/path/to/zztable1_nextgen", repos = NULL, type = "source")

# Then load
library(zztable1nextgen)
```

### Problem: Function not found after loading

**Error:** `Error: could not find function "table1"`

**Verify installation:**
```r
# Check if package loaded correctly
library(zztable1nextgen)

# List available functions
ls("package:zztable1nextgen")

# Check for conflicts
conflicts()

# Try explicitly:
zztable1nextgen::table1(...)
```

---

## Data Input Issues

### Problem: "Data must be a data.frame"

**Error:** `Error: 'data' must be a data.frame`

**Solution:**
```r
# Make sure data is a data.frame, not a tibble or matrix
data <- as.data.frame(data)

# Works with tibbles too (convert if needed)
library(tibble)
data <- as.data.frame(tibble_data)

# Create a simple test
data <- data.frame(
  group = c("A", "B"),
  value = c(1, 2)
)
table1(group ~ value, data = data)
```

### Problem: "Formula must have form: strata ~ variables"

**Error:** `Error in parse_formula: Formula must have form: strata ~ variables`

**Solution:**

The correct formula format is:
```r
# Format 1: Simple (no strata)
table1(~ age + sex + bmi, data = df)

# Format 2: With strata
table1(treatment ~ age + sex + bmi, data = df)

# NOT these:
# table1(df)  # Wrong: need formula
# table1(age + sex ~ bmi, data = df)  # Wrong: strata must be single variable
```

### Problem: "Variable not found in data"

**Error:** `Error: 'mpg' not found in data`

**Solution:**
```r
# Check data structure
str(your_data)
head(your_data)
names(your_data)

# Use correct variable names
table1(~ mpg + hp, data = mtcars)  # Correct
# NOT: table1(~ MPG + HP, data = mtcars)  # Case-sensitive!

# Check for spaces or special characters
colnames(your_data)  # May reveal hidden spaces
```

### Problem: Data has missing values - getting errors

**Error:** Error when data contains `NA` values

**Solution:**
```r
# Option 1: Remove missing values before table creation
clean_data <- na.omit(your_data)
bp <- table1(~ age + sex, data = clean_data)

# Option 2: Display missing values in table
bp <- table1(
  ~ age + sex,
  data = your_data,
  missing = TRUE  # Shows count of missing values
)

# Option 3: Use custom NA handling
# Check documentation: ?table1
```

---

## Rendering & Output

### Problem: "No output displayed"

**Symptom:** `table1()` returns blueprint but prints nothing

**Solution:**
```r
# Explicitly render the blueprint
data(mtcars)
bp <- table1(~ mpg + hp, data = mtcars)

# Option 1: Use print method
print(bp)

# Option 2: Explicitly render for format
render_console(bp)  # For console
render_html(bp)     # For HTML
render_latex(bp)    # For LaTeX

# Option 3: In R Markdown - use results='asis'
# In chunk: {r results='asis'}
# table1(~ mpg + hp, data = mtcars)
```

### Problem: LaTeX output doesn't compile

**Error:** `! Undefined control sequence` or other LaTeX errors

**Solution:**
```r
# Ensure LaTeX packages are available
# Add to R Markdown YAML header:
output:
  pdf_document:
    extra_dependencies:
      - booktabs
      - xcolor
      - colortbl
      - threeparttable

# Or manually add to LaTeX preamble:
preamble: |
  \usepackage{booktabs}
  \usepackage{xcolor}
  \usepackage{colortbl}
```

### Problem: HTML table doesn't render correctly in browser

**Symptom:** Table appears broken or misaligned in HTML output

**Solution:**
```r
# Include CSS for table styling
# In R Markdown:
```r
# Generate CSS for themes
theme_css <- zztable1nextgen::generate_theme_css()
cat("<style>\n")
cat(theme_css)
cat("\n</style>")
```

# Or apply CSS manually for your theme
```

### Problem: Console output is misaligned

**Symptom:** Columns don't line up properly in console output

**Solution:**
```r
# Make sure terminal window is wide enough
# Recommended: 100+ character width

# Or use a simplified theme
bp <- table1(~ mpg + hp, data = mtcars, theme = "console")
render_console(bp)

# If still misaligned, check for special characters in data
# that might affect column widths
```

---

## Themes & Styling

### Problem: "Unknown theme 'xyz', using 'console'"

**Warning:** Theme not recognized, falls back to console

**Solution:**
```r
# Check available themes
list_available_themes()
# Output: "console" "nejm" "lancet" "jama" "bmj" "simple"

# Use correct theme name
table1(~ mpg + hp, data = mtcars, theme = "nejm")  # Correct
# NOT: table1(~ mpg + hp, data = mtcars, theme = "NEJM")  # Case-sensitive

# Create custom theme if needed
custom <- create_custom_theme("MyTheme", base_theme = "nejm")
table1(~ mpg + hp, data = mtcars, theme = custom)
```

### Problem: Theme colors don't appear in PDF

**Symptom:** Colors work in HTML but not in PDF output

**Solution:**
```r
# 1. Verify LaTeX color packages are loaded
# In YAML header:
extra_dependencies:
  - xcolor
  - colortbl

# 2. Check PDF viewer supports colors
# Try with: Adobe Reader, Evince, or similar

# 3. Try a simpler theme first
# NEJM and Lancet themes work reliably

# 4. Test rendering directly
bp <- table1(~ mpg + hp, data = mtcars, theme = "nejm")
latex_output <- render_latex(bp)
```

### Problem: Custom theme not working

**Symptom:** Custom theme created but not applied correctly

**Solution:**
```r
# Verify theme structure
my_theme <- create_custom_theme("Test", base_theme = "nejm")
str(my_theme)  # Check structure

# Ensure required fields present
required_fields <- c("name", "decimal_places", "css_properties")
all(required_fields %in% names(my_theme))

# Apply theme explicitly
bp <- table1(~ mpg + hp, data = mtcars)
bp_themed <- apply_theme(bp, my_theme)

# Or pass at creation
bp <- table1(~ mpg + hp, data = mtcars, theme = my_theme)
```

---

## Stratification & Analysis

### Problem: "Strata variable must be a factor"

**Error:** Error when using non-factor strata

**Solution:**
```r
# Convert strata variable to factor
data$group <- factor(data$group)

# Then use in formula
table1(group ~ age + sex, data = data)

# Or do it in formula
table1(factor(group) ~ age + sex, data = data)
```

### Problem: Stratified table not displaying correctly

**Symptom:** Missing strata or confusing layout

**Solution:**
```r
# Check data has multiple strata levels
table(data$strata_var)  # Should see multiple groups

# Verify formula syntax
# Format: strata_var ~ variables
table1(
  treatment ~ age + sex + weight,
  data = data
)

# Check strata has sufficient sample size
# Very small strata may not display well
```

### Problem: P-values not shown

**Error:** P-value column missing even with `pvalue = TRUE`

**Solution:**
```r
# pvalue requires stratified data (multiple groups)
# This works:
data$group <- factor(c(rep("A", 50), rep("B", 50)))
bp <- table1(group ~ age + sex, data = data, pvalue = TRUE)

# This doesn't (no groups to compare):
bp <- table1(~ age + sex, data = data, pvalue = TRUE)  # Error!

# Check statistical test
# Continuous variables use t-test (or others)
# Categorical variables use chi-square
```

---

## Performance Issues

### Problem: Table generation is slow

**Symptom:** Long wait time creating table for large data

**Solutions:**

```r
# 1. Use only necessary variables
# Slower:
bp <- table1(~ ., data = large_dataset)

# Faster:
bp <- table1(~ age + sex + weight, data = large_dataset)

# 2. Profile to find bottleneck
library(profvis)
profvis({
  bp <- table1(~ var1 + var2 + ... + var100, data = large_data)
})

# 3. Check for complex operations
# Avoid complex computed columns if not needed

# 4. Render format separately
bp <- table1(~ age + sex, data = data)  # Quick
html_out <- render_html(bp)  # Separate step
```

### Problem: Memory usage is high

**Symptom:** Out of memory errors with large data

**Solution:**
```r
# table1_nextgen uses sparse storage (efficient)
# But ensure you're not keeping unnecessary data

# Don't store huge datasets in blueprints
data <- data[, c("age", "sex", "group")]  # Keep only needed columns
bp <- table1(~ age + sex, strata = "group", data = data)

# Remove large objects when done
rm(large_dataset)
gc()  # Force garbage collection
```

---

## Getting Help

### Diagnostic Information

Collect this information when reporting issues:

```r
# System information
R.version.string
sessionInfo()

# Package version
packageVersion("zztable1nextgen")

# Minimal reproducible example
library(zztable1nextgen)
data(mtcars)
# ... your code causing the issue
```

### Debugging Steps

```r
# 1. Verify package loads
library(zztable1nextgen)

# 2. Test with built-in data
data(mtcars)
bp <- table1(~ mpg + hp, data = mtcars)

# 3. Render in different formats
render_console(bp)
render_html(bp)
render_latex(bp)

# 4. Check specific function
?table1
?create_custom_theme
?apply_theme
```

### Common Error Messages

| Error | Likely Cause | Solution |
|-------|--------------|----------|
| "First argument must be table1_blueprint" | Wrong input type | Check you passed blueprint to render function |
| "Data must be a data.frame" | Data is wrong class | Convert to data.frame: `as.data.frame(data)` |
| "Theme not found" | Theme doesn't exist | Use `list_available_themes()` or create custom |
| "Formula error" | Formula syntax wrong | Use format: `strata ~ var1 + var2` |
| "Variable not found" | Column name typo | Check spelling with `names(data)` |
| "LaTeX error" | Missing packages | Add packages to YAML header |

### Resources

- **Package documentation:** `?table1`, `?create_custom_theme`, etc.
- **Vignettes:**
  - `vignette("zztable1_nextgen_guide")` - Overview
  - `vignette("theming_system")` - Themes explained
  - `vignette("extending_themes")` - Custom themes
  - `vignette("stratified_examples")` - Stratification
- **Examples:** See `vignettes/` directory for complete examples

### Reporting Issues

If you believe you've found a bug:

1. **Create minimal reproducible example:**
```r
# Minimal code that reproduces the issue
library(zztable1nextgen)
data(mtcars)
# ... minimal steps to reproduce
```

2. **Include:**
   - R version
   - Package version
   - Error message (full traceback)
   - Data structure (small sample)
   - Expected vs. actual behavior

3. **Submit with:**
   - Clear description of issue
   - Steps to reproduce
   - Minimal example
   - Error output

---

## FAQ

**Q: Can I export to Excel?**
A: Export via CSV:
```r
df <- as.data.frame(bp)
write.csv(df, "table1.csv")
```

**Q: How do I customize summary statistics?**
A: Use `numeric_summary` parameter:
```r
table1(
  ~ age + weight,
  data = data,
  numeric_summary = "mean_sd"  # or "median_iqr", "mean_se"
)
```

**Q: Can I add footnotes?**
A: Yes, via `footnotes` parameter:
```r
table1(
  ~ mpg + hp,
  data = mtcars,
  footnotes = list(
    variables = list(mpg = "Miles per gallon"),
    general = list("Data from mtcars dataset")
  )
)
```

**Q: How do I save to PDF?**
A: Use R Markdown or:
```r
# In R Markdown: outputs to PDF automatically
# Or render separately then save
bp <- table1(~ mpg + hp, data = mtcars)
latex_output <- render_latex(bp)
# Save latex_output to .tex file and compile with pdflatex
```

---

## Still Having Issues?

Try this checklist:

- [ ] Is the package installed? (`library(zztable1nextgen)`)
- [ ] Are you using correct function names? (`table1`, not `table_1`)
- [ ] Is your data a data.frame? (`is.data.frame(data)`)
- [ ] Are variable names spelled correctly? (`names(data)`)
- [ ] Is your formula correct? (`~ var1 + var2` or `strata ~ var1 + var2`)
- [ ] Have you rendered the blueprint? (`render_console(bp)`)
- [ ] Are required packages installed for your output format?
  - LaTeX: `booktabs`, `xcolor`, `colortbl`
  - HTML: base R only
  - Console: base R only

If issues persist after checking these, please report with a minimal reproducible example.
