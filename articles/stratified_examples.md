# Stratified Table 1 Analysis Examples

## Introduction

Stratified analysis is a crucial component of epidemiological and
clinical research. This vignette demonstrates how to create stratified
Table 1 analyses using the `zztable1` package. Stratified tables allow
you to examine patterns within subgroups of your data, revealing
important differences that might be obscured in overall analyses.

## Clinical Trial Data Example

Let’s create a comprehensive clinical trial dataset that includes
multiple potential stratification variables.

``` r

# Create a realistic multi-center clinical trial dataset
set.seed(42)
n <- 300

clinical_data <- data.frame(
  # Primary treatment variable
  treatment = factor(
    sample(c("Placebo", "Low Dose", "High Dose"), n, replace = TRUE, 
           prob = c(0.4, 0.3, 0.3)),
    levels = c("Placebo", "Low Dose", "High Dose")
  ),
  
  # Potential stratification variables
  site = factor(sample(paste("Site", LETTERS[1:4]), n, replace = TRUE)),
  sex = factor(sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.55, 0.45))),
  age_group = factor(
    sample(c("18-44", "45-64", "65+"), n, replace = TRUE, prob = c(0.3, 0.4, 0.3)),
    levels = c("18-44", "45-64", "65+")
  ),
  disease_severity = factor(
    sample(c("Mild", "Moderate", "Severe"), n, replace = TRUE, prob = c(0.4, 0.4, 0.2)),
    levels = c("Mild", "Moderate", "Severe")
  ),
  
  # Baseline characteristics
  age = round(rnorm(n, 58, 15)),
  bmi = round(rnorm(n, 26.5, 4.2), 1),
  systolic_bp = round(rnorm(n, 135, 18)),
  
  # Comorbidities
  diabetes = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.75, 0.25))),
  hypertension = factor(sample(c("No", "Yes"), n, replace = TRUE, prob = c(0.65, 0.35))),
  
  # Lab values
  hemoglobin = round(rnorm(n, 13.2, 1.8), 1),
  creatinine = round(rnorm(n, 1.1, 0.3), 2)
)

# Add some realistic missing values
clinical_data$bmi[sample(1:n, 8)] <- NA
clinical_data$hemoglobin[sample(1:n, 5)] <- NA
clinical_data$creatinine[sample(1:n, 3)] <- NA

# Show dataset structure
str(clinical_data)
```

‘data.frame’: 300 obs. of 12 variables: \$ treatment : Factor w/ 3
levels “Placebo”,“Low Dose”,..: 2 2 1 2 3 3 2 1 3 2 … \$ site : Factor
w/ 4 levels “Site A”,“Site B”,..: 1 4 2 4 1 1 2 3 1 2 … \$ sex : Factor
w/ 2 levels “Female”,“Male”: 2 2 1 2 2 2 1 2 2 2 … \$ age_group : Factor
w/ 3 levels “18-44”,“45-64”,..: 2 2 3 2 3 1 2 2 3 2 … \$
disease_severity: Factor w/ 3 levels “Mild”,“Moderate”,..: 1 1 1 2 3 3 1
1 2 1 … \$ age : num 34 29 53 61 24 62 64 77 60 61 … \$ bmi : num 27.5
28.3 26.5 29.1 28.3 28.8 28.6 33.5 22.1 32.8 … \$ systolic_bp : num 128
132 148 126 144 145 117 134 125 143 … \$ diabetes : Factor w/ 2 levels
“No”,“Yes”: 1 1 1 2 1 1 1 1 1 1 … \$ hypertension : Factor w/ 2 levels
“No”,“Yes”: 1 1 1 2 1 1 1 2 1 1 … \$ hemoglobin : num 13.9 12.4 13.4 12
14.6 10.1 13.5 13.2 15.1 12.8 … \$ creatinine : num 0.94 1.54 1.23 0.79
0.71 1.17 1.01 1.07 1.05 1.3 …

``` r

head(clinical_data, 10)
```

treatment site sex age_group disease_severity age bmi systolic_bp 1 Low
Dose Site A Male 45-64 Mild 34 27.5 128 2 Low Dose Site D Male 45-64
Mild 29 28.3 132 3 Placebo Site B Female 65+ Mild 53 26.5 148 4 Low Dose
Site D Male 45-64 Moderate 61 29.1 126 5 High Dose Site A Male 65+
Severe 24 28.3 144 6 High Dose Site A Male 18-44 Severe 62 28.8 145 7
Low Dose Site B Female 45-64 Mild 64 28.6 117 8 Placebo Site C Male
45-64 Mild 77 33.5 134 9 High Dose Site A Male 65+ Moderate 60 22.1 125
10 Low Dose Site B Male 45-64 Mild 61 32.8 143 diabetes hypertension
hemoglobin creatinine 1 No No 13.9 0.94 2 No No 12.4 1.54 3 No No 13.4
1.23 4 Yes Yes 12.0 0.79 5 No No 14.6 0.71 6 No No 10.1 1.17 7 No No
13.5 1.01 8 No Yes 13.2 1.07 9 No No 15.1 1.05 10 No No 12.8 1.30

## Stratified Analysis Examples

### Example 1: Stratified by Study Site

Understanding how baseline characteristics vary across different study
sites is crucial for multi-center trials.

``` r

create_table(
  treatment ~ age + sex + bmi + diabetes + systolic_bp,
  data = clinical_data,
  strata = "site",
  theme = "nejm",
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

**Key Observations:** - Each study site shows as a separate table
section - Within-site treatment group comparisons - Helps identify
site-specific recruitment patterns - Essential for assessing treatment
balance across sites

### Example 2: Stratified by Sex

Sex-stratified analysis is important for understanding treatment effects
and baseline differences between male and female participants.

``` r

create_table(
  treatment ~ age + age_group + bmi + diabetes + hypertension + hemoglobin,
  data = clinical_data,
  strata = "sex", 
  theme = "lancet",
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

**Key Observations:** - Separate baseline characteristics for males and
females - Age and BMI distributions may differ by sex - Hemoglobin
levels typically differ between sexes - Treatment allocation balance
within each sex

### Example 3: Stratified by Disease Severity

Disease severity stratification helps understand how patient
characteristics and treatment allocation vary by baseline disease
status.

``` r

create_table(
  treatment ~ age + sex + bmi + systolic_bp + diabetes + hypertension + creatinine,
  data = clinical_data,
  strata = "disease_severity",
  theme = "jama",
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

**Key Observations:** - Baseline characteristics across mild, moderate,
and severe disease - Treatment allocation may vary by severity -
Comorbidity prevalence often increases with disease severity - Important
for stratified randomization assessment

### Example 4: Stratified by Age Group

Age-group stratified analysis reveals how baseline characteristics and
treatment allocation vary across different age ranges.

``` r

create_table(
  treatment ~ sex + bmi + systolic_bp + diabetes + hypertension + hemoglobin + creatinine,
  data = clinical_data,
  strata = "age_group",
  theme = "nejm",
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

**Key Observations:** - Younger vs middle-aged vs older participants -
Comorbidity prevalence increases with age - Lab values may vary by age
group - Treatment allocation balance across age groups

## Advanced Stratified Analysis

### Multiple Variables with Missing Data

Let’s examine how stratified analysis handles missing data and multiple
variable types.

``` r

create_table(
  treatment ~ age + bmi + hemoglobin + creatinine + diabetes + hypertension,
  data = clinical_data,
  strata = "sex",
  theme = "lancet", 
  missing = TRUE,  # Show missing value patterns
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

### Site and Sex Combined Analysis

For comprehensive analysis, we might want to examine the interaction of
multiple stratification factors.

``` r

# Create a combined stratification variable for demonstration
clinical_data$site_sex <- interaction(clinical_data$site, clinical_data$sex, sep = " - ")

# Show the distribution
table(clinical_data$site_sex, clinical_data$treatment)
```

                  Placebo Low Dose High Dose

Site A - Female 10 8 13 Site B - Female 10 19 11 Site C - Female 20 10 8
Site D - Female 8 5 6 Site A - Male 18 13 15 Site B - Male 31 15 10 Site
C - Male 12 15 10 Site D - Male 14 9 10

``` r

create_table(
  treatment ~ age + bmi + diabetes + systolic_bp,
  data = clinical_data,
  strata = "site_sex",
  theme = "jama",
  pvalue = TRUE
)
```

[TABLE]

## Comparative Analysis

### Before and After Stratification

Let’s compare an overall analysis with a stratified analysis to see how
stratification reveals important patterns.

#### Overall Analysis (Non-stratified)

``` r

create_table(
  treatment ~ age + sex + bmi + diabetes + hypertension + systolic_bp,
  data = clinical_data,
  theme = "console",
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

#### Stratified by Disease Severity

``` r

create_table(
  treatment ~ age + sex + bmi + diabetes + hypertension + systolic_bp,
  data = clinical_data,
  strata = "disease_severity",
  theme = "console", 
  pvalue = TRUE,
  totals = TRUE
)
```

[TABLE]

**Key Differences:** - Overall analysis may mask important subgroup
differences - Stratified analysis reveals severity-specific patterns -
P-values may differ when accounting for stratification - Treatment
balance assessment within severity levels

## Summary and Best Practices

### When to Use Stratified Analysis

1.  **Multi-center Studies**: Always stratify by study site
2.  **Sex Differences**: Important for most clinical studies
3.  **Age Groups**: Especially relevant for studies spanning wide age
    ranges
4.  **Disease Severity**: Critical for understanding baseline risk
5.  **Geographic Regions**: For studies spanning different populations

### Interpretation Guidelines

1.  **Sample Sizes**: Check adequate sample sizes within strata
2.  **Missing Data**: Consider missing data patterns within strata
3.  **P-values**: Interpret within-strata comparisons carefully
4.  **Clinical Relevance**: Focus on clinically meaningful differences
5.  **Multiple Comparisons**: Consider adjustment for multiple testing

### Available Stratification Variables in This Dataset

| Variable | Description | Use Case |
|:---|:---|:---|
| site | Study site (A, B, C, D) | Multi-center trial balance |
| sex | Participant sex (Male, Female) | Sex-specific effects |
| age_group | Age groups (18-44, 45-64, 65+) | Age-related patterns |
| disease_severity | Disease severity (Mild, Moderate, Severe) | Baseline risk stratification |
| diabetes | Diabetes status (No, Yes) | Comorbidity analysis |
| hypertension | Hypertension status (No, Yes) | Cardiovascular risk factors |

Available Stratification Variables {.table}

The stratified analysis capabilities of `zztable1` provide powerful
tools for understanding complex clinical trial data. By examining
baseline characteristics within meaningful subgroups, researchers can
better assess treatment allocation, identify potential confounders, and
plan appropriate statistical analyses.
