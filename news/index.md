# Changelog

## zztable1 0.6.0

### Correctness fixes

- **The result cache was never populated, so every render recomputed
  from the data.** Two independent faults disabled it. First,
  [`evaluate_computation_cell()`](https://rgt47.github.io/zztable1/reference/evaluate_computation_cell.md)
  gates both the cache read and the cache write on `cell$cache_key`, but
  no code ever assigned that field;
  [`create_stat_cache_key()`](https://rgt47.github.io/zztable1/reference/create_stat_cache_key.md)
  existed and was never called, and the cell constructors did not accept
  a key. The guard was therefore always false and
  [`get_cached()`](https://rgt47.github.io/zztable1/reference/get_cached.md)/[`set_cached()`](https://rgt47.github.io/zztable1/reference/set_cached.md)
  were unreachable. Second, the cell-level fallback stored its result
  with `cell$cached_result <- result`. A cell is a plain list, so that
  assignment mutated a local copy that was discarded when the function
  returned. Cells are now stamped with their position key as they enter
  the blueprint, in `[<-.table1_blueprint`, which covers every
  construction path; results are written once into the blueprint’s
  `stat_cache` environment, which persists because it is an environment.
  Re-rendering a blueprint of 60 computation cells at 200,000 rows now
  costs 0.06 s against 0.81 s for the first render, where previously
  every render cost the same.

- **Repeated renders of one blueprint could print different p-values.**
  Categorical comparisons fall back to
  `fisher.test(simulate.p.value = TRUE, B = 10000)` when the exact test
  fails, which draws on the RNG. Because nothing was cached, each render
  re-ran the simulation, so rendering the same table to console and then
  to LaTeX could report two different p-values for the same cell. With
  the cache repaired, a blueprint evaluates each cell once and every
  later render reproduces it. Note that two separately constructed
  blueprints over the same data can still differ in these p-values;
  seeding remains the user’s responsibility.

- **Cache invalidation.** Replacing or removing a cell now drops the
  result cached at that position, and a blueprint whose data is swapped
  for a frame of different shape clears the cache rather than serving
  values computed from the previous data.
  [`is_cached()`](https://rgt47.github.io/zztable1/reference/is_cached.md)
  now uses a hash lookup instead of scanning
  [`ls()`](https://rdrr.io/r/base/ls.html), which was linear in the
  number of cached entries and so quadratic over a full render.

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
