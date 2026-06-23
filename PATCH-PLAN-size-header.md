# Patch Plan: zztable1 Size-Header Misalignment Bug

*2026-06-22 17:57 PDT*

## 1. Summary

When `table1(..., size = TRUE)` is called with a grouping variable that
is a character vector (or a factor whose level order differs from
alphabetical order), the per-group sizes shown in the column headers
(`(N=...)`) are attached to the wrong columns. The data cells are
correct; only the `(N=...)` header labels are misassigned.

This is a correctness bug: a reader sees a plausible but incorrect N for
each group.

## 2. Reproduction

``` r

library(zztable1)
d <- data.frame(
  arm = c(rep("Placebo", 259), rep("Vitamin E", 257), rep("Donepezil", 253)),
  age = rnorm(769, 73, 7)
)
bp <- table1(arm ~ age, data = d, size = TRUE)
bp$metadata$dimensions$group_info$sizes
#>   Placebo Vitamin E Donepezil
#>       253       259       257     <- WRONG: Placebo is 259, not 253
table(d$arm)
#> Donepezil   Placebo Vitamin E
#>       253       259       257     <- table() is alphabetical
```

Observed in the ADCS MCI report (`arm` is a character vector with
appearance order Placebo, Vitamin E, Donepezil): the rendered Table 1
header showed Placebo (N=253), Vitamin E (N=259), Donepezil (N=257),
whereas the true sizes are Placebo=259, Vitamin E=257, Donepezil=253.

## 3. Root Cause

In `R/dimensions.R`,
[`analyze_groups()`](https://rgt47.github.io/zztable1/reference/analyze_groups.md):

``` r

# Get observed levels efficiently
if (is.factor(grp_data)) {
  levels <- levels(grp_data)[table(grp_data, useNA = "no") > 0]
} else {
  levels <- unique(grp_data[!is.na(grp_data)])      # APPEARANCE order
}

# Quick size calculation
sizes <- as.vector(table(grp_data, useNA = "no"))   # table() order (alpha)
names(sizes) <- levels                              # MISMATCH
```

`as.vector(table(grp_data))` returns counts in
[`table()`](https://rdrr.io/r/base/table.html) order, which is
alphabetical for a character vector and factor-level order for a factor.
`levels` is built from [`unique()`](https://rdrr.io/r/base/unique.html)
for a character vector, which is appearance order. Assigning
appearance-order names to alphabetical-order values misaligns the
name-to-value mapping.

The downstream lookup in
[`apply_size_labels()`](https://rgt47.github.io/zztable1/reference/apply_size_labels.md)
(`R/rendering.R`) is correct (it indexes `sizes[[col_name]]` by name),
so the corruption is entirely at construction in
[`analyze_groups()`](https://rgt47.github.io/zztable1/reference/analyze_groups.md).

Two related defects in the same idiom:

- **Factor with absent levels.** `levels(grp_data)[table(...) > 0]`
  filters to present levels, but `as.vector(table(grp_data))` still
  includes zero-count level entries, so `names(sizes) <- levels` can
  mismatch lengths and yield `NA` names when a factor has an unused
  level.
- **[`analyze_strata()`](https://rgt47.github.io/zztable1/reference/analyze_strata.md)**
  (same file) uses the identical `as.vector(table(strata_data))` idiom
  (line 237). Its `sizes` is not named, but any positional pairing of
  `strata$levels` with `strata$sizes` inherits the same order mismatch
  for character strata.

## 4. The Patch

Reorder the counts to match `levels` by indexing the table by the level
names. This guarantees name-to-value alignment for factor and character
inputs and naturally drops absent factor levels.

### 4.1 `analyze_groups()` (R/dimensions.R, ~line 199-201)

``` r

# Quick size calculation
sizes <- as.vector(table(grp_data, useNA = "no"))
names(sizes) <- levels
```

becomes

``` r

# Size calculation aligned to `levels` order (robust to factor vs
# character ordering and to absent factor levels).
counts <- table(grp_data, useNA = "no")
sizes <- as.integer(counts[levels])
names(sizes) <- levels
```

### 4.2 `analyze_strata()` (R/dimensions.R, ~line 237)

``` r

sizes = as.vector(table(strata_data, useNA = "no"))
```

becomes

``` r

sizes = as.integer(table(strata_data, useNA = "no")[levels])
```

(here `levels` is the local strata `levels` computed just above).

Both edits are local, do not change function signatures, and do not
affect the `levels`/`col_names` order, so column ordering in the
rendered table is unchanged. Only the size-to-column mapping is
corrected.

## 5. Regression Test

Add to `tests/testthat/test-dimensions.R` (or a new
`test-size-header.R`):

``` r

test_that("group sizes align with levels for character grouping", {
  d <- data.frame(
    g = c(rep("B", 5), rep("C", 3), rep("A", 2)),  # appearance B,C,A
    x = rnorm(10)
  )
  gi <- zztable1:::analyze_groups("g", d)
  expect_identical(gi$sizes[["A"]], 2L)
  expect_identical(gi$sizes[["B"]], 5L)
  expect_identical(gi$sizes[["C"]], 3L)
})

test_that("group sizes drop absent factor levels", {
  d <- data.frame(
    g = factor(c("A", "A", "C"), levels = c("A", "B", "C")),
    x = rnorm(3)
  )
  gi <- zztable1:::analyze_groups("g", d)
  expect_false("B" %in% names(gi$sizes))
  expect_identical(gi$sizes[["A"]], 2L)
  expect_identical(gi$sizes[["C"]], 1L)
})
```

## 6. Validation Steps

1.  Apply the two edits in `R/dimensions.R`.
2.  `Rscript -e 'devtools::test()'` in the package; confirm the new
    tests pass and no existing tests regress.
3.  `Rscript -e 'devtools::check()'` for a clean R CMD check.
4.  Reinstall: `Rscript -e 'devtools::install()'` (or
    [`pak::local_install()`](https://pak.r-lib.org/reference/local_install.html)).
5.  In the ADCS MCI report, re-enable `size = TRUE` in the `zztab_pdf`
    helper (currently `size = FALSE` as a workaround) and re-render;
    confirm Table 1 shows Placebo (N=259), Vitamin E (N=257), Donepezil
    (N=253).

## 7. Risks and Scope

- **Low risk.** The change only reorders an internal counts vector to
  match an already-correct `levels` vector. No public API change.
- **Behavior change.** Tables previously rendered with `size = TRUE` on
  character or non-alphabetical-factor groups will now show different
  (correct) Ns. Any snapshot tests of such tables must be updated to the
  corrected values.
- **No effect** on factors whose level order already equals alphabetical
  order and have no absent levels (the common case), so most existing
  output is unchanged.

## 8. Note on the .Rbuildignore

This planning file lives at the package root; add `^PATCH-PLAN-.*\.md$`
to `.Rbuildignore` (or delete the file) before building so R CMD check
does not flag a non-standard top-level file.
