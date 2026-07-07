# Comprehensive Theme Showcase: Table 1 Examples with Built-in R Datasets

## Introduction

This comprehensive vignette showcases **all available themes** in
`zztable1` using carefully selected built-in R datasets. Each theme is
designed to match specific publication standards, from medical journals
to general statistical reports.

### Available Themes

The package includes **6** built-in themes:

|  | Theme | Description |
|:---|:---|:---|
| console | console | Console - Basic monospace output for development |
| nejm | nejm | NEJM - New England Journal of Medicine styling with authentic cream striping |
| lancet | lancet | Lancet - Clean minimal formatting matching The Lancet |
| jama | jama | JAMA - Journal of American Medical Association styling |
| bmj | bmj | BMJ - British Medical Journal styling |
| simple | simple | Simple - Clean general-purpose theme for reports |

Available Themes in zztable1 {.table .table
style="margin-left: auto; margin-right: auto;"}

Each theme will be demonstrated using the same dataset to clearly show
the formatting differences.

## Theme Showcase: Motor Trend Car Dataset

We’ll use the `mtcars` dataset to demonstrate all themes with identical
data and parameters. This allows for direct comparison of theme
formatting while maintaining consistent content.

### Dataset Preparation

``` r

# Prepare mtcars with meaningful factor variables
data(mtcars)
mtcars$transmission <- factor(
  ifelse(mtcars$am == 1, "Manual", "Automatic"),
  levels = c("Automatic", "Manual")
)
mtcars$engine_shape <- factor(
  ifelse(mtcars$vs == 1, "V-shaped", "Straight"),
  levels = c("Straight", "V-shaped")
)
mtcars$cylinders <- factor(mtcars$cyl)

# Show sample data
knitr::kable(head(mtcars[, c("mpg", "hp", "wt", "transmission", "engine_shape", "cylinders")]), 
             caption = "Sample of prepared mtcars data") %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
                           full_width = FALSE)
```

|                   |  mpg |  hp |    wt | transmission | engine_shape | cylinders |
|:------------------|-----:|----:|------:|:-------------|:-------------|:----------|
| Mazda RX4         | 21.0 | 110 | 2.620 | Manual       | Straight     | 6         |
| Mazda RX4 Wag     | 21.0 | 110 | 2.875 | Manual       | Straight     | 6         |
| Datsun 710        | 22.8 |  93 | 2.320 | Manual       | V-shaped     | 4         |
| Hornet 4 Drive    | 21.4 | 110 | 3.215 | Automatic    | V-shaped     | 6         |
| Hornet Sportabout | 18.7 | 175 | 3.440 | Automatic    | Straight     | 8         |
| Valiant           | 18.1 | 105 | 3.460 | Automatic    | V-shaped     | 6         |

Sample of prepared mtcars data {.table .table .table-striped
.table-hover .table-condensed
style="width: auto !important; margin-left: auto; margin-right: auto;"}

### Complete Theme Showcase

Each theme below displays the same analysis (transmission type vs. car
characteristics) to highlight formatting differences:

#### Console Theme - Basic Analysis

*Simple comparison without p-values or totals*

``` r

create_table(
  formula = transmission ~ mpg + hp + wt + cylinders,
  data = mtcars,
  pvalue = FALSE,
  totals = FALSE,
  missing = FALSE,
  theme = "console"
)
```

[TABLE]

#### NEJM Theme - Clinical Trial Style with Stratification

*Stratified analysis by engine shape with missing values shown*

``` r

# Add some missing values for demonstration
mtcars_missing <- mtcars
mtcars_missing$mpg[c(1,5,10)] <- NA
mtcars_missing$hp[c(3,7,15)] <- NA

create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars_missing,
  strata = "engine_shape",
  pvalue = TRUE,
  totals = TRUE,
  missing = TRUE,
  theme = "nejm"
)
```

[TABLE]

#### 3. Lancet Theme - Multi-center Trial Format

*Stratified by cylinder count with comprehensive statistics*

``` r

create_table(
  formula = transmission ~ mpg + hp + wt + engine_shape,
  data = mtcars,
  strata = "cylinders",
  pvalue = TRUE,
  totals = TRUE,
  missing = FALSE,
  theme = "lancet"
)
```

[TABLE]

#### 4. JAMA Theme (Journal of American Medical Association)

*Professional medical journal styling with lettered footnotes*

``` r

create_table(
  formula = transmission ~ mpg + hp + wt + cylinders,
  data = mtcars_missing,
  pvalue = TRUE,
  totals = TRUE,
  missing = TRUE,
  theme = "jama"
)
```

[TABLE]

#### 5. Simple Theme - Descriptive with Footnotes

*Descriptive statistics with custom footnotes demonstration*

``` r

# Create footnotes for the analysis (using proper structure)
analysis_footnotes <- list(
  variables = list(
    mpg = "Miles per gallon measured at highway speeds",
    hp = "Horsepower measured at peak engine performance",
    wt = "Weight includes vehicle and standard equipment"
  ),
  general = "Data from 1974 Motor Trend magazine"
)

create_table(
  formula = transmission ~ mpg + hp + wt + cylinders,
  data = mtcars,
  pvalue = FALSE,
  totals = TRUE,
  missing = FALSE,
  footnotes = analysis_footnotes,
  theme = "simple"
)
```

[TABLE]

## Additional Dataset Examples

### Iris Dataset: Biological Measurements

The classic iris dataset demonstrates how themes handle multiple factor
levels and continuous measurements.

``` r

data(iris)
knitr::kable(head(iris[, c("Species", "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")]), 
             caption = "Sample of iris data - Species comparison") %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
                           full_width = FALSE)
```

| Species | Sepal.Length | Sepal.Width | Petal.Length | Petal.Width |
|:--------|-------------:|------------:|-------------:|------------:|
| setosa  |          5.1 |         3.5 |          1.4 |         0.2 |
| setosa  |          4.9 |         3.0 |          1.4 |         0.2 |
| setosa  |          4.7 |         3.2 |          1.3 |         0.2 |
| setosa  |          4.6 |         3.1 |          1.5 |         0.2 |
| setosa  |          5.0 |         3.6 |          1.4 |         0.2 |
| setosa  |          5.4 |         3.9 |          1.7 |         0.4 |

Sample of iris data - Species comparison {.table .table .table-striped
.table-hover .table-condensed
style="width: auto !important; margin-left: auto; margin-right: auto;"}

#### Medical Journal Theme Comparison: Iris Species Analysis

#### NEJM Theme - Multi-group Analysis

``` r

# Demonstrate footnotes with NEJM theme (uses numbered footnotes)
nejm_footnotes <- list(
  general = c(
    "Data from Anderson's iris dataset (1935)",
    "Measurements standardized to nearest 0.1 cm",
    "Statistical significance tested at alpha = 0.05"
  )
)

create_table(
  formula = Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
  data = iris,
  pvalue = TRUE,
  totals = TRUE,
  footnotes = nejm_footnotes,
  theme = "nejm"
)
```

[TABLE]

#### JAMA Theme - Multi-group Analysis

``` r

# Demonstrate footnotes with JAMA theme (uses lettered footnotes)
iris_footnotes <- list(
  general = c(
    "Measurements taken from dried specimens",
    "All measurements in centimeters", 
    "P-values from one-way ANOVA across species"
  )
)

create_table(
  formula = Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width,
  data = iris,
  pvalue = TRUE,
  totals = TRUE,
  footnotes = iris_footnotes,
  theme = "jama"
)
```

[TABLE]

### Sleep Data: Clinical Trial Example

Student’s sleep data demonstrating clinical trial-style reporting across
different themes.

``` r

data(sleep)
sleep$group <- factor(sleep$group, labels = c("Drug 1", "Drug 2"))

# Add simulated baseline characteristics for better demonstration
set.seed(456)
sleep$age <- round(rnorm(nrow(sleep), 25, 3))
sleep$sex <- factor(sample(c("Male", "Female"), nrow(sleep), replace = TRUE))

knitr::kable(head(sleep), caption = "Sleep study data with simulated demographics") %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"), 
                           full_width = FALSE)
```

| extra | group  | ID  | age | sex    |
|------:|:-------|:----|----:|:-------|
|   0.7 | Drug 1 | 1   |  21 | Female |
|  -1.6 | Drug 1 | 2   |  27 | Female |
|  -0.2 | Drug 1 | 3   |  27 | Female |
|  -1.2 | Drug 1 | 4   |  21 | Male   |
|  -0.1 | Drug 1 | 5   |  23 | Male   |
|   3.4 | Drug 1 | 6   |  24 | Female |

Sleep study data with simulated demographics {.table .table
.table-striped .table-hover .table-condensed
style="width: auto !important; margin-left: auto; margin-right: auto;"}

#### Clinical Theme Comparison: Sleep Study

#### Lancet Theme - Clinical Trial Format

``` r

create_table(
  formula = group ~ extra + age + sex,
  data = sleep,
  pvalue = TRUE,
  totals = TRUE,
  theme = "lancet"
)
```

[TABLE]

#### Simple Theme - Report Format

``` r

create_table(
  formula = group ~ extra + age + sex,
  data = sleep,
  pvalue = TRUE,
  totals = TRUE,
  theme = "simple"
)
```

[TABLE]

### 4. Plant Growth Data (`PlantGrowth`)

Experimental data comparing plant weights under different conditions.

``` r

data(PlantGrowth)
knitr::kable(head(PlantGrowth), caption = "Sample of PlantGrowth data")
```

| weight | group |
|-------:|:------|
|   4.17 | ctrl  |
|   5.58 | ctrl  |
|   5.18 | ctrl  |
|   6.11 | ctrl  |
|   4.50 | ctrl  |
|   4.61 | ctrl  |

Sample of PlantGrowth data {.table}

``` r


# Simple treatment comparison
create_table(
  formula = group ~ weight,
  data = PlantGrowth,
  pvalue = TRUE,
  totals = TRUE,
  theme = "console"
)
```

[TABLE]

### 5. Tooth Growth Data (`ToothGrowth`)

Guinea pig tooth growth under different vitamin C treatments.

``` r

data(ToothGrowth)
ToothGrowth$dose <- factor(ToothGrowth$dose)
knitr::kable(head(ToothGrowth), caption = "Sample of ToothGrowth data")
```

|  len | supp | dose |
|-----:|:-----|:-----|
|  4.2 | VC   | 0.5  |
| 11.5 | VC   | 0.5  |
|  7.3 | VC   | 0.5  |
|  5.8 | VC   | 0.5  |
|  6.4 | VC   | 0.5  |
| 10.0 | VC   | 0.5  |

Sample of ToothGrowth data {.table}

``` r


# Demonstrate footnotes with clinical research context
clinical_footnotes <- list(
  variables = list(
    supp = "VC = Vitamin C supplement (ascorbic acid); OJ = Orange juice as natural vitamin C source",
    len = "Tooth length measured in microns",
    dose = "Dose levels: 0.5, 1.0, and 2.0 mg/day"
  ),
  general = "Guinea pig tooth growth study (Crampton, 1947)"
)

# Compare by supplement type with footnotes
create_table(
  formula = supp ~ len + dose,
  data = ToothGrowth,
  pvalue = TRUE,
  totals = TRUE,
  footnotes = clinical_footnotes,
  theme = "jama"
)
```

[TABLE]

#### Analysis by Dose

``` r

# Analysis with dose as grouping variable
create_table(
  formula = dose ~ len,
  data = ToothGrowth,
  pvalue = TRUE,
  theme = "lancet"
)
```

[TABLE]

### 6. Chickwts Data (Chicken Weights)

Chicken weights by different feed types.

``` r

data(chickwts)
knitr::kable(head(chickwts), caption = "Sample of chickwts data")
```

| weight | feed      |
|-------:|:----------|
|    179 | horsebean |
|    160 | horsebean |
|    136 | horsebean |
|    227 | horsebean |
|    217 | horsebean |
|    168 | horsebean |

Sample of chickwts data {.table}

``` r


create_table(
  formula = feed ~ weight,
  data = chickwts,
  pvalue = TRUE,
  totals = TRUE,
  theme = "console"
)
```

[TABLE]

### 7. Built-in Dataset with Missing Values (`airquality`)

Environmental data with naturally occurring missing values.

``` r

data(airquality)
airquality$Month <- factor(
  month.name[airquality$Month],
  levels = month.name[5:9]  # May through September
)
knitr::kable(head(airquality), caption = "Sample of airquality data")
```

| Ozone | Solar.R | Wind | Temp | Month | Day |
|------:|--------:|-----:|-----:|:------|----:|
|    41 |     190 |  7.4 |   67 | May   |   1 |
|    36 |     118 |  8.0 |   72 | May   |   2 |
|    12 |     149 | 12.6 |   74 | May   |   3 |
|    18 |     313 | 11.5 |   62 | May   |   4 |
|    NA |      NA | 14.3 |   56 | May   |   5 |
|    28 |      NA | 14.9 |   66 | May   |   6 |

Sample of airquality data {.table}

``` r


# Show how missing values are handled
create_table(
  formula = Month ~ Ozone + Solar.R + Wind + Temp,
  data = airquality,
  pvalue = TRUE,
  totals = TRUE,
  theme = "nejm"
)
```

[TABLE]

## Theme Comparison

Let’s demonstrate the different medical journal themes side by side:

### Console Theme (Default)

``` r

create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars,
  pvalue = TRUE,
  totals = TRUE,
  theme = "console"
)
```

[TABLE]

### NEJM Theme (with striping)

``` r

create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars,
  pvalue = TRUE,
  totals = TRUE,
  theme = "nejm"
)
```

[TABLE]

### Lancet Theme (clean minimal)

``` r

create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars,
  pvalue = TRUE,
  totals = TRUE,
  theme = "lancet"
)
```

[TABLE]

### JAMA Theme (clean minimal)

``` r

create_table(
  formula = transmission ~ mpg + hp + wt,
  data = mtcars,
  pvalue = TRUE,
  totals = TRUE,
  theme = "jama"
)
```

[TABLE]

## Performance Demo

``` r

# Demonstrate with larger simulated dataset
set.seed(789)
large_data <- data.frame(
  treatment = factor(sample(c("Placebo", "Drug A", "Drug B"), 1000, replace = TRUE)),
  age = round(rnorm(1000, 65, 15)),
  sex = factor(sample(c("Male", "Female"), 1000, replace = TRUE)),
  weight = round(rnorm(1000, 70, 15), 1),
  height = round(rnorm(1000, 170, 10), 1),
  center = factor(sample(paste("Center", 1:5), 1000, replace = TRUE))
)

# Time the table creation  
system.time({
  create_table(
    formula = treatment ~ age + sex + weight + height,
    data = large_data,
    pvalue = TRUE,
    totals = TRUE,
    theme = "nejm"
  )
})
```

user system elapsed 0.010 0.000 0.011

## Available Themes

``` r

available_themes <- list_available_themes()
print(available_themes)
```

\[1\] “console” “nejm” “lancet” “jama” “bmj” “simple”

The package includes 6 built-in themes optimized for different journal
requirements and output formats.

## Conclusion

The `zztable1` package provides a flexible and efficient way to create
publication-ready “Table 1” summaries. The examples in this vignette
demonstrate:

- **Parameter Flexibility**: `strata`, `missing`, `pvalue`, `totals`,
  and `footnotes` parameters
- **Theme Variety**: All 6 built-in themes with authentic journal
  formatting
- **Footnote Support**: Both numbered (NEJM, Simple) and lettered (JAMA,
  Lancet) footnote styles
- **Missing Data Handling**: Comprehensive missing value reporting when
  `missing=TRUE`
- **Stratified Analysis**: Multi-group comparisons using the `strata`
  parameter
- **Performance**: Efficient handling of large datasets with complex
  parameter combinations

Key footnote features demonstrated: - **NEJM Theme**: Numbered footnotes
(1, 2, 3) for clinical publications - **JAMA Theme**: Lettered footnotes
(a, b, c) for medical research  
- **Simple Theme**: Numbered footnotes for general reports - **Custom
Content**: Flexible footnote text for methods, data sources, and
definitions

The package maintains the familiar R formula interface while providing
significant performance improvements and enhanced functionality through
its optimized architecture.
