# Blueprints keep cells, caches, and stores in environments, which R
# does not copy on assignment. These tests pin down value semantics for
# edits made through `[<-`: modifying one binding must not change
# another binding to the same blueprint.

set.seed(20261107L)
cow_data <- data.frame(
  arm = factor(sample(c("A", "B"), 200, replace = TRUE)),
  age = rnorm(200, 60, 10),
  crp = rlnorm(200, 1, 1),
  sex = factor(sample(c("F", "M"), 200, replace = TRUE))
)

first_computation <- function(bp) {
  keys <- sort(ls(bp$cells))
  key <- Filter(
    function(k) inherits(get(k, bp$cells), "cell_computation"), keys
  )[1]
  as.integer(strsplit(key, "_")[[1]])
}
edited_cell <- function(old) {
  Cell(
    type = "computation",
    data_subset = old$data_subset,
    computation = function(x) "EDITED"
  )
}
render <- function(bp) capture.output(render_console(bp))

# --- table1() output ------------------------------------------------------

bp <- table1(arm ~ age + crp + sex, data = cow_data)
expect_true(isTRUE(bp$metadata$copy_on_write),
  info = "table1() returns a blueprint with copy-on-write enabled")
expect_true(length(ls(bp$cells)) > 0,
  info = "in-place population still fills the blueprint")

original_out <- render(bp)
ij <- first_computation(bp)
bp2 <- bp
bp2[ij[1], ij[2]] <- edited_cell(bp[ij[1], ij[2]])

expect_identical(render(bp), original_out,
  info = "editing a copy leaves the original's output unchanged")
expect_true(any(grepl("EDITED", render(bp2))),
  info = "the edited copy shows the edit")
expect_false(identical(bp$cells, bp2$cells),
  info = "the edited copy has its own cell environment")
expect_false(identical(bp$metadata$stat_cache, bp2$metadata$stat_cache),
  info = "the edited copy has its own result cache")
expect_false(
  identical(bp$metadata$spanner_store, bp2$metadata$spanner_store),
  info = "the edited copy has its own spanner store"
)
expect_false(
  identical(bp$metadata$summary_store, bp2$metadata$summary_store),
  info = "the edited copy has its own summary store"
)

# --- cell counts stay consistent with each binding's cells ---------------

bp3 <- bp
n_before <- bp$metadata$cell_count
grid <- expand.grid(i = seq_len(bp$nrows), j = seq_len(bp$ncols))
grid_keys <- sprintf("%d_%d", grid$i, grid$j)
free <- which(!grid_keys %in% ls(bp$cells))
expect_true(length(free) > 0,
  info = "the fixture table has an empty position to fill")
bp3[grid$i[free[1]], grid$j[free[1]]] <-
  Cell(type = "content", content = "new")
expect_equal(bp3$metadata$cell_count, n_before + 1L,
  info = "adding a cell increments the copy's count")
expect_equal(bp$metadata$cell_count, n_before,
  info = "the original's count is unchanged")
expect_equal(length(ls(bp3$cells)), length(ls(bp$cells)) + 1L,
  info = "only the copy gains the new cell")

# --- cached results survive an edit to a different cell -----------------

bp4 <- table1(arm ~ age + crp + sex, data = cow_data)
invisible(render(bp4))
n_cached <- length(setdiff(
  ls(bp4$metadata$stat_cache, all.names = TRUE), ".data_fingerprint"
))
ij4 <- first_computation(bp4)
bp4[ij4[1], ij4[2]] <- edited_cell(bp4[ij4[1], ij4[2]])
n_after <- length(setdiff(
  ls(bp4$metadata$stat_cache, all.names = TRUE), ".data_fingerprint"
))
expect_equal(n_after, n_cached - 1L,
  info = "an edit drops only the edited cell's cached result")

# --- functions do not modify their argument ------------------------------

relabel <- function(b) {
  k <- first_computation(b)
  b[k[1], k[2]] <- edited_cell(b[k[1], k[2]])
  b
}
bp5 <- table1(arm ~ age + crp + sex, data = cow_data)
out5 <- render(bp5)
bp5_new <- relabel(bp5)
expect_identical(render(bp5), out5,
  info = "a function that edits a blueprint leaves the caller's intact")
expect_true(any(grepl("EDITED", render(bp5_new))),
  info = "the function's return value carries the edit")

# --- transposed and manually built blueprints ----------------------------

bpt <- table1(arm ~ age + crp, data = cow_data, transpose = TRUE)
expect_true(isTRUE(bpt$metadata$copy_on_write),
  info = "transposed blueprints also have copy-on-write enabled")
bpt2 <- bpt
bpt2[1, 1] <- Cell(type = "content", content = "EDITED")
expect_false(any(grepl("EDITED", render(bpt))),
  info = "editing a copy of a transposed blueprint leaves it unchanged")

bpm <- Table1Blueprint(2, 2)
bpm[1, 1] <- Cell(type = "content", content = "a")
bpm2 <- bpm
bpm2[1, 1] <- Cell(type = "content", content = "b")
expect_identical(bpm[1, 1]$content, "a",
  info = "manually built blueprints have value semantics")
expect_identical(bpm2[1, 1]$content, "b",
  info = "the manual copy holds its own edit")

# --- spanners and summary rows -------------------------------------------

spanner_ids <- function(b) ls(b$metadata$spanner_store)
summary_keys <- function(b) ls(b$metadata$summary_store)

bps <- table1(arm ~ age + crp, data = cow_data, pvalue = FALSE)
bps_out <- render(bps)
bps2 <- add_spanner(bps, label = "Arms", columns = 2:3, id = "arms")
expect_identical(spanner_ids(bps2), "arms",
  info = "add_spanner() returns a blueprint carrying the spanner")
expect_identical(spanner_ids(bps), character(0),
  info = "add_spanner() leaves its input unchanged")
expect_identical(render(bps), bps_out,
  info = "the input's output is unchanged after add_spanner()")

bps_alias <- bps
bps_alias <- add_spanner(bps_alias, label = "Arms", columns = 2:3)
expect_identical(spanner_ids(bps), character(0),
  info = "adding a spanner through an alias leaves the original alone")

bps3 <- add_spanner(bps2, label = "Top", spanners = "arms")
expect_identical(sort(spanner_ids(bps3)), c("arms", "top"),
  info = "nested spanners accumulate across reassignment")
expect_identical(spanner_ids(bps2), "arms",
  info = "the intermediate blueprint keeps only its own spanner")

bpr <- add_summary_rows(bps, fns = list(n = function(x) sum(!is.na(x))))
bpr <- add_grand_summary_rows(bpr,
  fns = list(total = function(x) sum(!is.na(x))))
expect_identical(sort(sub("_[0-9]+$", "", summary_keys(bpr))),
  c("grand", "group"),
  info = "summary rows accumulate across reassignment")
expect_identical(summary_keys(bps), character(0),
  info = "summary-row functions leave their input unchanged")

delim_data <- data.frame(
  arm = factor(rep(c("A", "B"), 50)),
  lab.wbc = rnorm(100), lab.rbc = rnorm(100)
)
bpd <- table1(arm ~ lab.wbc + lab.rbc, data = delim_data,
  pvalue = FALSE, transpose = TRUE)
bpd2 <- add_spanner_delim(bpd)
expect_identical(spanner_ids(bpd2), "lab",
  info = "add_spanner_delim() adds a spanner per prefix")
expect_identical(bpd2$col_names[2:3], c("wbc", "rbc"),
  info = "add_spanner_delim() relabels the grouped columns")
expect_identical(bpd$col_names[2:3], c("lab.wbc", "lab.rbc"),
  info = "add_spanner_delim() leaves its input's labels unchanged")
expect_identical(spanner_ids(bpd), character(0),
  info = "add_spanner_delim() leaves its input's spanners unchanged")
