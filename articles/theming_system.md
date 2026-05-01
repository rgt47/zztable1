# Theming System Demonstration

## Introduction

The `zztable1` package includes a comprehensive theming system that
allows you to format tables according to different journal standards.
This vignette demonstrates three major medical journal themes: NEJM,
Lancet, and JAMA.

## Sample Data Setup

We’ll use a consistent clinical trial dataset throughout this vignette
to clearly show the differences between themes.

``` r

# Create a realistic clinical trial dataset
set.seed(123)
n <- 200

clinical_data <- data.frame(
  treatment = factor(
    sample(c("Placebo", "Drug A", "Drug B"), n, replace = TRUE, prob = c(0.4, 0.3, 0.3)),
    levels = c("Placebo", "Drug A", "Drug B")
  ),
  age = round(rnorm(n, 65, 12)),
  sex = factor(sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.6, 0.4))),
  bmi = round(rnorm(n, 28, 5), 1),
  diabetes = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.7, 0.3)))
)

# Add some missing values to make it realistic
clinical_data$bmi[sample(1:n, 10)] <- NA

head(clinical_data)
```

treatment age sex bmi diabetes 1 Placebo 56 Male 27.6 Yes 2 Drug A 68
Female 22.2 Yes 3 Drug B 62 Male 24.8 No 4 Drug A 61 Male 27.9 Yes 5
Drug A 54 Male 31.4 No 6 Placebo 64 Female 19.7 Yes

## Journal-Specific Themes

### New England Journal of Medicine (NEJM) Theme

NEJM style emphasizes clean, minimal formatting with the distinctive ±
(plus-minus) format for continuous variables.

``` r

create_table(
  treatment ~ age + sex + bmi + diabetes,
  data = clinical_data,
  theme = "nejm",
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

**Key NEJM Features:** - Uses ± symbol for mean (standard deviation) -
Minimal borders with top/middle/bottom rules only - Alternating light
yellow/cream row striping for improved readability - Bold headers - 1
decimal place precision - Clean, professional appearance matching actual
NEJM publications

### The Lancet Theme

The Lancet style uses parentheses format and slightly different
formatting conventions.

``` r

create_table(
  treatment ~ age + sex + bmi + diabetes,
  data = clinical_data,
  theme = "lancet",
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

**Key Lancet Features:** - Uses parentheses for mean (standard
deviation) - Clean white background with minimal horizontal-only
borders - Sans-serif font family - 1 decimal place precision -
Professional medical journal appearance

### JAMA Theme

JAMA formatting follows conservative guidelines typical of American
medical publications.

``` r

create_table(
  treatment ~ age + sex + bmi + diabetes,
  data = clinical_data,
  theme = "jama",
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

**Key JAMA Features:** - Uses parentheses for mean (standard
deviation) - Clean white background with minimal horizontal-only
borders - Traditional medical journal appearance  
- 1 decimal place precision - Lettered footnote style

## Theme Comparison Summary

| Theme | Continuous Variables | Border Style | Font | Decimal Places | Best For |
|:---|:---|:---|:---|:---|:---|
| NEJM | Mean ± SD | Top/Mid/Bottom rules + striping | Arial, sans-serif | 1 | NEJM submissions |
| Lancet | Mean (SD) | Horizontal rules only | Arial, sans-serif | 1 | Lancet submissions |
| JAMA | Mean (SD) | Horizontal rules only | Arial, sans-serif | 1 | JAMA & American journals |

Theme Comparison Summary {.table}

## Usage Guidelines

Choose themes based on your target publication:

- **NEJM Theme**: Use for New England Journal of Medicine submissions or
  when you prefer the distinctive ± format
- **Lancet Theme**: Use for The Lancet submissions or European medical
  journals
- **JAMA Theme**: Use for JAMA submissions or other American medical
  publications

All themes maintain the same high performance and feature set while
providing publication-ready formatting tailored to specific journal
requirements.

## Available Themes

``` r

available_themes <- list_available_themes()
print(available_themes)
```

\[1\] “console” “nejm” “lancet” “jama” “bmj” “simple”

The package includes 6 built-in themes. The three demonstrated above
represent the most commonly used medical journal styles.
