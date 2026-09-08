# Changelog

## zztable1 0.6.0

### Correctness fixes

- **`continuous_test = "ttest"` reported a single contrast when there
  were more than two groups.** The p-value was taken as
  `summary(fit)$coefficients[2, 4]`, which is the second group against
  the first and nothing else, carrying the pooled error term from all
  groups. The guard admitted any number of groups at or above two, so
  with three arms a variable whose overall F-test was 1e-16 appeared in
  the table as `p = 0.013`, because the difference sat in the third arm.
  That number went into the column a reader scans as the test of whether
  the variable differs across groups. With more than two groups the
  overall F is now used; it is the correct generalisation and reduces to
  the pooled t-test exactly when there are two groups, which is
  unchanged.

- **The chi-square guard tested observed counts rather than expected
  ones.** `all(tab >= 5)` checks the wrong quantity: the approximation
  is a condition on expected cell counts. A table with cells 6, 6, 6 and
  30 has every observed count at or above 5 while one expected count is
  3, so the chi-square branch was taken on a table where R itself warns
  that the approximation may be incorrect; it returned 0.054 against the
  exact test’s 0.049, on opposite sides of the conventional threshold.
  The guard now computes the expected counts and falls back to Fisher’s
  exact test when any is below 5, which is what the surrounding code
  already intended.

### Tests

- `test_basic.R` held a single `expect_true(TRUE)`. It now asserts what
  goes in the p-value column against the test it claims to be: that
  three groups give the overall F rather than the first contrast, that
  two groups still give the pooled t-test, and that the expected-count
  rule is what decides between chi-square and Fisher.
- Suite grows from 579 assertions to 585.

## zztable1 v0.5.0

- Initial public release.
