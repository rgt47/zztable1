## End-to-end tests for the blueprint result cache.
##
## test_caching.R exercises the cache helpers in isolation, calling
## set_cached()/get_cached() with hand-made keys. Those assertions
## passed for a long period during which rendering never touched the
## cache at all, because cells were constructed without the cache_key
## that evaluate_cell() gates on. The tests below therefore drive the
## cache the way a user does, through table1() and render_console().

library(tinytest)

drop_cached <- getFromNamespace("drop_cached", "zztable1")

make_data <- function(n = 400) {
  set.seed(4242L)
  data.frame(
    group = factor(rep(c("A", "B"), length.out = n)),
    age = rnorm(n, 50, 10),
    sex = factor(sample(c("F", "M"), n, replace = TRUE))
  )
}

dat <- make_data()
bp <- table1(group ~ age + sex, data = dat)

cache_keys <- function(blueprint) {
  cache <- blueprint$metadata$stat_cache
  setdiff(ls(cache, all.names = TRUE), ".data_fingerprint")
}

computation_cells <- function(blueprint) {
  cells <- mget(ls(blueprint$cells), envir = blueprint$cells)
  Filter(function(z) inherits(z, "cell_computation"), cells)
}

## Every cell placed in the blueprint carries its position key, which is
## what the cache is addressed by. Without this the cache is unreachable.
all_cells <- mget(ls(bp$cells), envir = bp$cells)
expect_true(
  length(all_cells) > 0,
  info = "blueprint should contain cells"
)
expect_true(
  all(vapply(all_cells, function(z) !is.null(z$cache_key), logical(1))),
  info = "every cell must be stamped with its position as a cache key"
)

## Nothing is computed until a render is requested.
expect_equal(
  length(cache_keys(bp)), 0,
  info = "an unrendered blueprint must hold no cached results"
)

first <- render_console(bp)

expect_equal(
  length(cache_keys(bp)), length(computation_cells(bp)),
  info = paste(
    "after one render the cache must hold exactly one entry per",
    "computation cell"
  )
)

## A second render must return the same output. Before the cache was
## repaired this could fail on its own: categorical p-values fall back
## to a Monte Carlo Fisher test, so re-evaluating produced slightly
## different numbers on each render of the same blueprint.
second <- render_console(bp)
expect_identical(
  first, second,
  info = "repeated renders of one blueprint must be identical"
)

## Prove the read path is actually consulted, without depending on
## timing. Poke a sentinel into the cache and check it surfaces.
target <- cache_keys(bp)[1]
bp$metadata$stat_cache[[target]] <- "SENTINEL"
expect_true(
  any(grepl("SENTINEL", render_console(bp), fixed = TRUE)),
  info = "render must read values from the cache rather than recompute"
)

## Replacing the cell at a position must invalidate the value cached
## for the old occupant, otherwise the stale result would be shown.
pos <- as.integer(strsplit(target, "_", fixed = TRUE)[[1]])
bp[pos[1], pos[2]] <- Cell(type = "content", content = "REPLACED")
expect_false(
  target %in% cache_keys(bp),
  info = "replacing a cell must drop the result cached at its position"
)
expect_true(
  any(grepl("REPLACED", render_console(bp), fixed = TRUE)),
  info = "the replacement cell's content must be rendered"
)

## Swapping in data of a different shape must empty the cache, so that
## results computed from the previous data cannot leak into the new
## table.
bp2 <- table1(group ~ age + sex, data = dat)
invisible(render_console(bp2))
expect_true(
  length(cache_keys(bp2)) > 0,
  info = "cache should be populated before the data-swap check"
)

wider <- make_data()
wider$extra <- rnorm(nrow(wider))
bp2$metadata$data <- wider
invisible(render_console(bp2))
expect_true(
  length(cache_keys(bp2)) > 0,
  info = "cache should repopulate against the new data"
)

## force_recalc must bypass the cache entirely.
bp3 <- table1(group ~ age + sex, data = dat)
invisible(render_console(bp3))
comp <- computation_cells(bp3)[[1]]
bp3$metadata$stat_cache[[comp$cache_key]] <- "STALE"
expect_identical(
  evaluate_cell(comp, dat, blueprint = bp3),
  "STALE",
  info = "without force_recalc the cached value is returned"
)
recomputed <- evaluate_cell(
  comp, dat, blueprint = bp3, force_recalc = TRUE
)
expect_false(
  identical(recomputed, "STALE"),
  info = "force_recalc must recompute rather than return a cached value"
)
## A forced recomputation also refreshes the cache, so the stale value
## must not survive it.
expect_identical(
  evaluate_cell(comp, dat, blueprint = bp3), recomputed,
  info = "force_recalc must write the fresh result back to the cache"
)

## drop_cached removes a single entry and leaves the rest intact.
bp4 <- table1(group ~ age + sex, data = dat)
invisible(render_console(bp4))
before <- cache_keys(bp4)
drop_cached(bp4, before[1])
after <- cache_keys(bp4)
expect_equal(
  length(after), length(before) - 1L,
  info = "drop_cached must remove exactly one entry"
)
expect_false(
  before[1] %in% after,
  info = "drop_cached must remove the requested entry"
)
