# Simple Table 1 Example

## A Simple Example

This vignette demonstrates the most basic usage of `zztable1` with a
small simulated clinical trial dataset.

``` r

set.seed(123)
trial_data <- data.frame(
  arm = factor(rep(c("Treatment", "Placebo"), each = 50)),
  age = rnorm(100, mean = 45, sd = 15),
  sex = factor(
    sample(c("Male", "Female"), 100, replace = TRUE)
  ),
  bmi = rnorm(100, mean = 26, sd = 5)
)

create_table(
  formula = arm ~ age + sex + bmi,
  data = trial_data,
  theme = "nejm",
  pvalue = TRUE
)
```

[TABLE]
