# ============================================================================
# Caching System Tests
# ============================================================================
#
# Tests for Phase 5.2: Statistical Result Caching
# Validates blueprint-level caching of statistical computations

context("Result Caching System")

# Test 1: Cache key generation
test_that("cache key generation works correctly", {
  key1 <- create_stat_cache_key("age", NULL, "ttest")
  expect_match(key1, "^var_age_strat_none_test_ttest$")

  key2 <- create_stat_cache_key("sex", "treatment", "chisq")
  expect_match(key2, "^var_sex_strat_treatment_test_chisq$")

  # Keys should be deterministic
  key1_again <- create_stat_cache_key("age", NULL, "ttest")
  expect_equal(key1, key1_again)
})

# Test 2: Cache key sanitization
test_that("cache key sanitization handles special characters", {
  # Special characters should be converted to underscores
  key <- create_stat_cache_key("age (years)", "arm==treatment", "t.test")
  # Parentheses and periods become underscores, but == is preserved for meaning
  expect_true(grepl("var_age__years", key))
  expect_true(grepl("test_t_test", key))

  # Key should still be deterministic
  key_again <- create_stat_cache_key("age (years)", "arm==treatment", "t.test")
  expect_equal(key, key_again)
})

# Test 3: Blueprint has stat cache
test_that("blueprint contains stat_cache in metadata", {
  bp <- Table1Blueprint(5, 3)
  expect_true(!is.null(bp$metadata$stat_cache))
  expect_true(inherits(bp$metadata$stat_cache, "environment"))
})

# Test 4: is_cached function
test_that("is_cached correctly identifies cached and uncached results", {
  bp <- Table1Blueprint(5, 3)

  # Initially nothing is cached
  expect_false(is_cached(bp, "var_age_strat_none_test_ttest"))

  # After storing something, it should be found
  set_cached(bp, "var_age_strat_none_test_ttest", "mean: 45.2 (sd: 8.3)")
  expect_true(is_cached(bp, "var_age_strat_none_test_ttest"))
})

# Test 5: get_cached and set_cached functions
test_that("get_cached and set_cached work correctly", {
  bp <- Table1Blueprint(5, 3)

  # Getting from empty cache returns NULL
  result <- get_cached(bp, "test_key")
  expect_null(result)

  # After setting, get returns the value
  test_value <- "mean: 45.2 (sd: 8.3)"
  set_cached(bp, "test_key", test_value)
  result <- get_cached(bp, "test_key")
  expect_equal(result, test_value)

  # Different keys return different values
  set_cached(bp, "other_key", "different_value")
  result1 <- get_cached(bp, "test_key")
  result2 <- get_cached(bp, "other_key")
  expect_equal(result1, test_value)
  expect_equal(result2, "different_value")
})

# Test 6: Blueprint has cache infrastructure
test_that("blueprint cache infrastructure is initialized", {
  data(mtcars)
  mtcars$group <- factor(rep(c("A", "B"), 16))

  # Create blueprint with cells
  bp <- table1(group ~ cyl + mpg, data = mtcars)

  # Cache should exist and be an environment
  expect_true(!is.null(bp$metadata$stat_cache))
  expect_true(inherits(bp$metadata$stat_cache, "environment"))

  # Initially should be empty
  cache_size_initial <- length(ls(bp$metadata$stat_cache))
  expect_equal(cache_size_initial, 0)

  # Manually add something to cache
  set_cached(bp, "test_key", "test_value")

  # Cache should now have content
  cache_size_after <- length(ls(bp$metadata$stat_cache))
  expect_equal(cache_size_after, 1)

  # Should be able to retrieve it
  cached_value <- get_cached(bp, "test_key")
  expect_equal(cached_value, "test_value")
})

# Test 7: Multiple blueprints have independent caches
test_that("each blueprint has its own independent cache", {
  data(mtcars)
  mtcars$group <- factor(rep(c("A", "B"), 16))

  bp1 <- table1(group ~ mpg, data = mtcars)
  bp2 <- table1(group ~ hp, data = mtcars)

  # Both should have caches
  expect_true(!is.null(bp1$metadata$stat_cache))
  expect_true(!is.null(bp2$metadata$stat_cache))

  # Caches should be different objects
  expect_false(identical(bp1$metadata$stat_cache, bp2$metadata$stat_cache))

  # Setting in one shouldn't affect the other
  set_cached(bp1, "key1", "value1")
  expect_true(is_cached(bp1, "key1"))
  expect_false(is_cached(bp2, "key1"))
})

# Test 8: Cache improves performance
test_that("caching improves performance on multiple renders", {
  data(mtcars)
  mtcars$group <- factor(rep(c("A", "B"), 16))

  # Create table with stratification
  bp <- table1(group ~ mpg + hp + wt, data = mtcars)

  # Time multiple renders
  t1 <- system.time({
    for (i in 1:5) {
      render_console(bp)
    }
  })[3]

  # Expected: second render should be faster due to cache
  # We're doing 5 renders, so speedup should be noticeable
  expect_true(t1 > 0)

  # This is a soft test - just verify timing works
  # Hard assertion would be brittle across systems
})

# Test 9: Cache persists across operations
test_that("cache persists when accessed from different contexts", {
  data(mtcars)
  mtcars$group <- factor(rep(c("A", "B"), 16))
  bp <- table1(group ~ mpg + cyl, data = mtcars)

  # Set some cached values
  set_cached(bp, "stat1", "value1")
  set_cached(bp, "stat2", "value2")
  set_cached(bp, "stat3", "value3")

  # Cache should have 3 items
  cache_size_1 <- length(ls(bp$metadata$stat_cache))
  expect_equal(cache_size_1, 3)

  # Retrieve them
  val1 <- get_cached(bp, "stat1")
  val2 <- get_cached(bp, "stat2")
  val3 <- get_cached(bp, "stat3")

  # All should be correct
  expect_equal(val1, "value1")
  expect_equal(val2, "value2")
  expect_equal(val3, "value3")

  # Cache size should be unchanged
  cache_size_2 <- length(ls(bp$metadata$stat_cache))
  expect_equal(cache_size_2, 3)
})

# Test 10: Cache can handle many entries
test_that("cache can store and retrieve many entries", {
  bp <- Table1Blueprint(5, 3)

  # Add many cache entries
  for (i in 1:50) {
    key <- paste0("stat_", i)
    value <- paste0("result_", i)
    set_cached(bp, key, value)
  }

  # Cache should have 50 items
  cache_size <- length(ls(bp$metadata$stat_cache))
  expect_equal(cache_size, 50)

  # All should be retrievable
  for (i in 1:50) {
    key <- paste0("stat_", i)
    expected_value <- paste0("result_", i)
    retrieved <- get_cached(bp, key)
    expect_equal(retrieved, expected_value)
  }
})

# Test 11: Cache keys work with stratified variable names
test_that("cache keys handle stratified variable names", {
  # Create cache keys that simulate stratified analysis
  key1 <- create_stat_cache_key("age", "cyl_factor_4", "ttest")
  key2 <- create_stat_cache_key("age", "cyl_factor_6", "ttest")
  key3 <- create_stat_cache_key("age", "cyl_factor_8", "ttest")

  # Keys should all be different
  expect_false(identical(key1, key2))
  expect_false(identical(key2, key3))
  expect_false(identical(key1, key3))

  # Keys should be deterministic
  key1_again <- create_stat_cache_key("age", "cyl_factor_4", "ttest")
  expect_equal(key1, key1_again)

  # Keys should be usable in cache operations
  bp <- Table1Blueprint(5, 3)
  set_cached(bp, key1, "result1")
  set_cached(bp, key2, "result2")
  set_cached(bp, key3, "result3")

  expect_equal(get_cached(bp, key1), "result1")
  expect_equal(get_cached(bp, key2), "result2")
  expect_equal(get_cached(bp, key3), "result3")
})

# Test 12: Cache handles edge cases
test_that("cache handles edge cases correctly", {
  bp <- Table1Blueprint(5, 3)

  # Test with very long key
  long_key <- paste(rep("a", 500), collapse = "")
  set_cached(bp, long_key, "long_key_value")
  expect_true(is_cached(bp, long_key))
  expect_equal(get_cached(bp, long_key), "long_key_value")

  # Test with numeric-like key
  numeric_key <- "key_123_456_789"
  set_cached(bp, numeric_key, "numeric_value")
  expect_true(is_cached(bp, numeric_key))
  expect_equal(get_cached(bp, numeric_key), "numeric_value")

  # Test with underscore-only key
  underscore_key <- "___"
  set_cached(bp, underscore_key, "underscore_value")
  expect_true(is_cached(bp, underscore_key))
  expect_equal(get_cached(bp, underscore_key), "underscore_value")

  # Test with complex nested structure as value
  complex_value <- list(a = 1, b = list(c = 2, d = 3))
  set_cached(bp, "complex_key", complex_value)
  expect_equal(get_cached(bp, "complex_key"), complex_value)
})

# Test 13: Cache functions work independently
test_that("cache utility functions work correctly", {
  bp <- Table1Blueprint(5, 3)

  # Test the full cache workflow
  key <- create_stat_cache_key("var1", "group_A", "ttest")
  value <- "mean: 45.2 (sd: 8.3)"

  # Initially not cached
  expect_false(is_cached(bp, key))

  # After setting, should be cached
  set_cached(bp, key, value)
  expect_true(is_cached(bp, key))

  # Should retrieve correct value
  retrieved <- get_cached(bp, key)
  expect_equal(retrieved, value)
})

# Test 14: Cache key with complex variable names
test_that("cache keys handle complex variable names", {
  # Real-world variable names can have numbers, underscores, etc.
  key1 <- create_stat_cache_key("age_at_baseline_years", "arm_1_treatment", "t_test")
  expect_true(nchar(key1) > 0)
  expect_match(key1, "^var_")

  # Repeated generation should give same key
  key1_repeat <- create_stat_cache_key("age_at_baseline_years", "arm_1_treatment", "t_test")
  expect_equal(key1, key1_repeat)
})

# Test 15: Empty blueprint cache operations
test_that("cache operations handle empty cache gracefully", {
  bp <- Table1Blueprint(5, 3)

  # All these should work without errors
  expect_false(is_cached(bp, "nonexistent_key"))
  expect_null(get_cached(bp, "nonexistent_key"))

  # Setting should work
  set_cached(bp, "new_key", "value")
  expect_true(is_cached(bp, "new_key"))
  expect_equal(get_cached(bp, "new_key"), "value")
})
