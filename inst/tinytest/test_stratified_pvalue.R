# Regression test: stratified tables must compute the p-value within
# each stratum, not repeat the whole-sample p-value in every stratum
# row. See docs/pack_review_2026-08-15.md.

set.seed(42)
n <- 300
dat <- data.frame(
  region = rep(c("East", "West"), each = n / 2),
  trt = sample(c("A", "B"), n, replace = TRUE),
  age = rnorm(n, 50, 10),
  cat = sample(c("Yes", "No"), n, replace = TRUE)
)
dat$age[dat$region == "East" & dat$trt == "B"] <-
  dat$age[dat$region == "East" & dat$trt == "B"] + 20
dat$cat[dat$region == "East"] <- ifelse(
  dat$trt[dat$region == "East"] == "A",
  sample(c("Yes", "No"), sum(dat$region == "East"), replace = TRUE, prob = c(0.9, 0.1)),
  sample(c("Yes", "No"), sum(dat$region == "East"), replace = TRUE, prob = c(0.1, 0.9))
)

get_pvals <- function(bp) {
  vals <- character(0)
  for (r in seq_len(bp$nrows)) {
    for (col in seq_len(bp$ncols)) {
      cell <- bp[r, col]
      if (!is.null(cell) && cell$type == "computation") {
        vals <- c(vals, evaluate_cell(cell, bp$metadata$data, blueprint = bp))
      }
    }
  }
  vals
}

bp_numeric <- table1(trt ~ age | region, data = dat, pvalue = TRUE,
                     continuous_test = "ttest")
pvals_numeric <- get_pvals(bp_numeric)
expect_equal(length(pvals_numeric), 2,
  info = "one p-value cell per stratum for a numeric variable")
expect_true(length(unique(pvals_numeric)) == 2,
  info = "stratified numeric p-values differ across strata rather than repeating the whole-sample value")

bp_factor <- table1(trt ~ cat | region, data = dat, pvalue = TRUE,
                    categorical_test = "chisq")
pvals_factor <- get_pvals(bp_factor)
expect_equal(length(pvals_factor), 2,
  info = "one p-value cell per stratum for a categorical variable")
expect_true(length(unique(pvals_factor)) == 2,
  info = "stratified categorical p-values differ across strata rather than repeating the whole-sample value")

# The stratum-level test must match an independent computation on the
# same subset, not the whole-sample test.
east <- dat[dat$region == "East", ]
p_east_ref <- summary(lm(age ~ trt, data = east))$coefficients[2, 4]
p_east_ref_fmt <- if (p_east_ref < 0.001) "<0.001" else as.character(round(p_east_ref, 3))
expect_equal(pvals_numeric[1], p_east_ref_fmt,
  info = "stratum p-value matches an independent test on the same stratum subset")
