library(testthat)
library(zztable1)

# Sample dataset for testing
set.seed(123)
test_data <- data.frame(
  treatment = factor(c(rep("A", 25), rep("B", 25), rep("A", 25), rep("B", 25))),
  age = c(rnorm(50, mean = 50, sd = 10), rnorm(50, mean = 55, sd = 10)),
  sex = factor(sample(c("Male", "Female"), 100, replace = TRUE)),
  site = factor(rep(c("Site 1", "Site 2"), each = 50)),
  missing_var = c(rnorm(90), rep(NA, 10))
)

test_that("table1 generates output with correct structure", {
  result <- table1(data = test_data, form = treatment ~ age + sex)
  expect_s3_class(result, "data.frame")
  expect_named(result, c("variables", "code", "A", "B", "p.value"))
})

test_that("table1 includes totals when requested", {
  result <- table1(data = test_data, form = treatment ~ age + sex, totals = TRUE)
  expect_true("Total" %in% names(result))
})

test_that("table1 handles stratification correctly", {
  result <- table1(data = test_data, form = treatment ~ age + sex, strata = "site")
  expect_s3_class(result, "data.frame")
  expect_true(any(grepl("Site 1|Site 2", result$variables)))
})

test_that("table1 excludes p-values when pvalue = FALSE", {
  result <- table1(data = test_data, form = treatment ~ age + sex, pvalue = FALSE)
  expect_false("p.value" %in% names(result))
})

test_that("table1 handles missing values correctly", {
  result <- table1(data = test_data, form = treatment ~ missing_var + sex, missing = TRUE)
  expect_true(any(grepl("valid \\(missing\\)", result$variables)))
})

test_that("row_name.factor creates expected row names", {
  result <- row_name(test_data$sex, "sex", missing = FALSE)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)  # 1 for variable name, 2 for factor levels
})

test_that("row_name.numeric includes missing row when missing = TRUE", {
  result <- row_name(test_data$age, "age", missing = TRUE)
  expect_true(any(result$variables == "valid (missing)"))
})

test_that("row_name.numeric excludes missing row when missing = FALSE", {
  result <- row_name(test_data$age, "age", missing = FALSE)
  expect_false(any(result$variables == "valid (missing)"))
})

test_that("row_name.factor includes <NA> level for missing values", {
  test_data$sex[1] <- NA
  result <- row_name(test_data$sex, "sex", missing = TRUE)
  expect_true("<NA>" %in% result$variables)
})

test_that("row_name.factor does not include <NA> when missing = FALSE", {
  result <- row_name(test_data$sex, "sex", missing = FALSE)
  expect_false("<NA>" %in% result$variables)
})

test_that("row_summary.factor calculates correct frequencies", {
  result <- row_summary(test_data$sex, test_data$treatment, totals = FALSE)
  expect_equal(ncol(result), length(levels(test_data$treatment)))
})

test_that("row_summary.numeric calculates mean and SD", {
  result <- row_summary(test_data$age, test_data$treatment, totals = FALSE, missing = FALSE)
  expect_true(any(grepl("\\d+\\.\\d+ \\(\\d+\\.\\d+\\)", unlist(result))))
})

test_that("row_summary.numeric includes missing counts when missing = TRUE", {
  result <- row_summary(test_data$missing_var, test_data$treatment, totals = FALSE, missing = TRUE)
  expect_true(any(grepl("valid \\(missing\\)", rownames(result))))
})

test_that("row_summary.factor includes totals when totals = TRUE", {
  result <- row_summary(test_data$sex, test_data$treatment, totals = TRUE)
  expect_true("Total" %in% colnames(result))
})

test_that("row_summary.numeric includes totals when totals = TRUE", {
  result <- row_summary(test_data$age, test_data$treatment, totals = TRUE, missing = FALSE)
  expect_true("Total" %in% colnames(result))
})

test_that("row_pv.factor calculates p-values correctly", {
  result <- row_pv(test_data$sex, test_data$treatment)
  expect_true(is.character(result[1]))
  expect_true(as.numeric(result[1]) <= 1)
})

test_that("row_pv.numeric calculates p-values correctly", {
  result <- row_pv(test_data$age, test_data$treatment)
  expect_true(is.character(result))
  expect_true(as.numeric(result[1]) <= 1)
})

# test_that("latex outputs a valid LaTeX file", {
#   result <- table1(data = test_data, form = treatment ~ age + sex)
#   latex_file <- latex(result, fname = "test_table", digits = 2)
#   expect_true(file.exists("./tables/test_table.tex"))
# })

# test_that("html outputs a valid HTML table", {
#   result <- table1(data = test_data, form = treatment ~ age + sex)
#   html_table <- html(result)
#   expect_s3_class(html_table, "kableExtra")
# })

# test_that("build generates a complete table", {
#   result <- build( x = test_data[c("age", "sex")], grp = test_data$treatment, size = TRUE, totals = TRUE, missing = TRUE)
#   expect_s3_class(result, "data.frame")
#   expect_named(result, c("variables", "code", "A", "B", "Total", "p.value"))
# })
