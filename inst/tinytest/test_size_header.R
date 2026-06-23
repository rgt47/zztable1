# =============================================================================
# Size-header alignment regression tests
#
# Guards against the bug where group sizes were attached to the wrong
# columns when the grouping variable is a character vector (appearance
# order != table() alphabetical order) or a factor with absent levels.
# =============================================================================

# Character grouping: appearance order (B, C, A) differs from the
# alphabetical order returned by table().
d_chr <- data.frame(
  g = c(rep("B", 5), rep("C", 3), rep("A", 2)),
  x = seq_len(10)
)
gi_chr <- zztable1:::analyze_groups("g", d_chr)

expect_equal(gi_chr$sizes[["A"]], 2L)
expect_equal(gi_chr$sizes[["B"]], 5L)
expect_equal(gi_chr$sizes[["C"]], 3L)

# Each named size must equal the true count for that level.
expect_equal(
  unname(gi_chr$sizes[gi_chr$levels]),
  as.integer(table(d_chr$g)[gi_chr$levels])
)

# Factor with an absent level: the absent level is dropped and the
# remaining sizes stay aligned with their levels.
d_fac <- data.frame(
  g = factor(c("A", "A", "C"), levels = c("A", "B", "C")),
  x = seq_len(3)
)
gi_fac <- zztable1:::analyze_groups("g", d_fac)

expect_false("B" %in% names(gi_fac$sizes))
expect_equal(gi_fac$sizes[["A"]], 2L)
expect_equal(gi_fac$sizes[["C"]], 1L)

# End-to-end: rendered header N labels match true group sizes.
bp <- table1(g ~ x, data = d_chr, size = TRUE)
sizes <- bp$metadata$dimensions$group_info$sizes
expect_equal(sizes[["A"]], 2L)
expect_equal(sizes[["B"]], 5L)
expect_equal(sizes[["C"]], 3L)
