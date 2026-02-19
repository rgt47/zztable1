## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----install------------------------------------------------------------------
# # Install from GitHub
# devtools::install_github("rgt47/zztable1")

## ----load---------------------------------------------------------------------
# library(zztable1)

## ----basic--------------------------------------------------------------------
# # Formula: grouping_variable ~ variables_to_summarize
# table1(arm ~ age + sex + bmi, data = trial_data)

## ----mtcars-example-----------------------------------------------------------
# # Create grouping variable
# mtcars$transmission <- factor(mtcars$am, labels = c("Automatic", "Manual"))
# 
# # Generate Table 1
# table1(transmission ~ mpg + hp + wt + cyl, data = mtcars)

## ----themes-------------------------------------------------------------------
# # New England Journal of Medicine
# table1(arm ~ age + sex, data = data, theme = "nejm")
# 
# # The Lancet
# table1(arm ~ age + sex, data = data, theme = "lancet")
# 
# # JAMA
# table1(arm ~ age + sex, data = data, theme = "jama")
# 
# # Console (default)
# table1(arm ~ age + sex, data = data, theme = "console")

## ----tests--------------------------------------------------------------------
# # Default tests (t-test for continuous, chi-square for categorical)
# table1(arm ~ age + sex, data = data, test = TRUE)
# 
# # Specify test types
# table1(arm ~ age + sex, data = data,
#        continuous_test = "kruskal",
#        categorical_test = "fisher")

## ----summaries----------------------------------------------------------------
# # Mean (SD) - default
# table1(arm ~ age, data = data, numeric_summary = "mean_sd")
# 
# # Median [IQR]
# table1(arm ~ age, data = data, numeric_summary = "median_iqr")
# 
# # Mean (95% CI)
# table1(arm ~ age, data = data, numeric_summary = "mean_ci")
# 
# # Median (range)
# table1(arm ~ age, data = data, numeric_summary = "median_range")

## ----stratified---------------------------------------------------------------
# table1(arm ~ age + sex, data = data, strata = "site")

## ----missing------------------------------------------------------------------
# table1(arm ~ age + sex, data = data, missing = TRUE)

## ----console------------------------------------------------------------------
# tbl <- table1(arm ~ age + sex, data = data)
# print(tbl)

## ----html---------------------------------------------------------------------
# tbl <- table1(arm ~ age + sex, data = data)
# render_html(tbl)

## ----latex--------------------------------------------------------------------
# tbl <- table1(arm ~ age + sex, data = data)
# render_latex(tbl)

