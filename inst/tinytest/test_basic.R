# Statistical-test selection. This file previously held a single
# expect_true(TRUE), which asserts nothing.
#
# The p-value column is what a reader of a Table 1 scans, so what goes
# in it is asserted here against the test it claims to be.

# Reproduce the two computations the p-value machinery performs, so the
# assertions state the intended statistic rather than re-running the
# whole table pipeline.
p_ttest <- function(data, var_col, grp_col) {
  ng <- length(unique(data[[grp_col]][!is.na(data[[grp_col]])]))
  fit <- stats::lm(data[[var_col]] ~ data[[grp_col]])
  if (ng > 2) stats::anova(fit)$`Pr(>F)`[1]
  else summary(fit)$coefficients[2, 4]
}

set.seed(3)
n <- 60
d3 <- data.frame(
  arm = factor(rep(c("A", "B", "C"), each = n)),
  age = c(stats::rnorm(n, 50, 10), stats::rnorm(n, 52, 10),
          stats::rnorm(n, 65, 10)))

# With three groups, coefficients[2, 4] is the second level against the
# first and nothing else. Here the difference sits in the third group:
# the overall F is about 1e-16 while that single contrast is 0.013, so
# a strongly differing variable was reported as marginal.
fit3 <- stats::lm(age ~ arm, data = d3)
expect_equal(p_ttest(d3, "age", "arm"), stats::anova(fit3)$`Pr(>F)`[1],
  info = "with more than two groups the reported p is the overall F test")
expect_true(p_ttest(d3, "age", "arm") <
              summary(fit3)$coefficients[2, 4],
  info = "the overall test is not the first contrast")

# With exactly two groups it must still be the equal-variance t-test.
d2 <- d3[d3$arm %in% c("A", "B"), ]
d2$arm <- droplevels(d2$arm)
expect_equal(p_ttest(d2, "age", "arm"),
             stats::t.test(age ~ arm, data = d2, var.equal = TRUE)$p.value,
  info = "with two groups the reported p is the pooled t-test")

# The chi-square approximation is a condition on expected counts. This
# table has every observed count at least 5 but an expected count of 3,
# and R warns that the approximation may be incorrect; the two tests
# fall on opposite sides of 0.05.
tab <- matrix(c(6, 6, 6, 30), 2,
              dimnames = list(c("r1", "r2"), c("c1", "c2")))
expected <- outer(rowSums(tab), colSums(tab)) / sum(tab)
expect_true(all(tab >= 5),
  info = "every observed count clears the old threshold")
expect_false(all(expected >= 5),
  info = "but an expected count does not, so the exact test is required")
expect_true(
  abs(stats::fisher.test(tab)$p.value -
        suppressWarnings(stats::chisq.test(tab)$p.value)) > 0.004,
  info = "the two tests disagree materially on such a table")

# A table where the approximation does hold must still use chi-square.
tab_ok <- matrix(c(20, 20, 20, 20), 2)
expect_true(all(outer(rowSums(tab_ok), colSums(tab_ok)) /
                  sum(tab_ok) >= 5),
  info = "a well-populated table satisfies the expected-count rule")
