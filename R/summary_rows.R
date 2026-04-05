# ============================================================================
# Summary Rows System
# ============================================================================
#
# Provides per-group subtotals and grand totals for table1_blueprint
# objects. Summary row definitions are stored as metadata and
# evaluated lazily at render time against the actual cell data.
#
# Storage:
#   blueprint$metadata$summary_rows  -- per-group summary definitions
#   blueprint$metadata$grand_summary -- table-wide summary definitions
#
# ============================================================================

#' Add Per-Group Summary Rows to a Blueprint
#'
#' Defines aggregation functions that are computed at render time for
#' each row group in the table. A row group is a set of contiguous
#' rows belonging to the same variable (for Table 1 layouts) or the
#' same stratum.
#'
#' @param blueprint A table1_blueprint object
#' @param fns A named list of aggregation functions. Each function
#'   receives a numeric vector and returns a single value or formatted
#'   string. Names become the summary row labels.
#' @param columns Integer or character vector of columns to
#'   summarise. Defaults to all data columns (excludes the variable
#'   name column and the p-value column).
#' @param side Where to place summary rows: \code{"bottom"} (default)
#'   or \code{"top"} of each group.
#' @param groups Character vector of row group names to summarise.
#'   Defaults to all groups.
#' @param fmt_fn Optional formatting function applied to each
#'   computed value before display. Receives a numeric value,
#'   returns a character string.
#'
#' @return The blueprint, modified in place.
#' @export
add_summary_rows <- function(blueprint, fns, columns = NULL,
                             side = "bottom", groups = NULL,
                             fmt_fn = NULL) {
  stopifnot(inherits(blueprint, "table1_blueprint"))
  stopifnot(is.list(fns), length(fns) > 0)
  stopifnot(side %in% c("top", "bottom"))

  if (is.null(names(fns)) || any(names(fns) == "")) {
    stop("All entries in 'fns' must be named", call. = FALSE)
  }

  col_indices <- resolve_summary_columns(columns, blueprint)

  summary_def <- list(
    type = "group",
    fns = fns,
    columns = col_indices,
    side = side,
    groups = groups,
    fmt_fn = fmt_fn
  )

  store <- blueprint$metadata$summary_store
  key <- paste0("group_", length(ls(store, all.names = TRUE)) + 1L)
  assign(key, summary_def, envir = store)

  invisible(blueprint)
}

#' Add Grand Summary Rows to a Blueprint
#'
#' Defines aggregation functions computed over all data rows in the
#' table (excluding other summary rows). Grand summaries appear at
#' the very bottom (or top) of the table.
#'
#' @param blueprint A table1_blueprint object
#' @param fns A named list of aggregation functions.
#' @param columns Integer or character vector of columns to
#'   summarise. Defaults to all data columns.
#' @param side Where to place grand summary rows: \code{"bottom"}
#'   (default) or \code{"top"}.
#' @param fmt_fn Optional formatting function for computed values.
#'
#' @return The blueprint, modified in place.
#' @export
add_grand_summary_rows <- function(blueprint, fns, columns = NULL,
                                   side = "bottom", fmt_fn = NULL) {
  stopifnot(inherits(blueprint, "table1_blueprint"))
  stopifnot(is.list(fns), length(fns) > 0)
  stopifnot(side %in% c("top", "bottom"))

  if (is.null(names(fns)) || any(names(fns) == "")) {
    stop("All entries in 'fns' must be named", call. = FALSE)
  }

  col_indices <- resolve_summary_columns(columns, blueprint)

  grand_def <- list(
    type = "grand",
    fns = fns,
    columns = col_indices,
    side = side,
    fmt_fn = fmt_fn
  )

  store <- blueprint$metadata$summary_store
  key <- paste0("grand_", length(ls(store, all.names = TRUE)) + 1L)
  assign(key, grand_def, envir = store)

  invisible(blueprint)
}


# -- internal helpers --------------------------------------------------------

#' Resolve which columns to summarise
#' @keywords internal
resolve_summary_columns <- function(columns, blueprint) {
  if (is.null(columns)) {
    ncols <- blueprint$ncols
    has_pvalue <- isTRUE(blueprint$metadata$options$pvalue)
    end_col <- if (has_pvalue) ncols - 1L else ncols
    seq.int(2L, end_col)
  } else if (is.character(columns)) {
    idx <- match(columns, blueprint$col_names)
    if (any(is.na(idx))) {
      stop("Column(s) not found: ",
           paste(columns[is.na(idx)], collapse = ", "),
           call. = FALSE)
    }
    as.integer(idx)
  } else {
    as.integer(columns)
  }
}

#' Evaluate summary rows for a single group
#'
#' Evaluates aggregation functions against raw data extracted
#' directly from blueprint computation cells, avoiding the
#' fragility of parsing formatted strings.
#'
#' For each column, collects the raw numeric data subsets from
#' every computation cell in the row range by evaluating the
#' cell's \code{data_subset} expression against the blueprint's
#' stored data frame. The aggregation function then operates on
#' the full set of underlying values.
#'
#' @param blueprint Table1Blueprint object
#' @param row_range Integer vector of row indices for this group
#' @param summary_def A single summary definition list
#' @param ncols Number of columns in the output
#' @return List of character vectors, one per summary function
#' @keywords internal
evaluate_summary_for_group <- function(blueprint, row_range,
                                       summary_def, ncols) {
  fns <- summary_def$fns
  col_indices <- summary_def$columns
  fmt_fn <- summary_def$fmt_fn
  data <- blueprint$metadata$data
  results <- list()

  for (fn_name in names(fns)) {
    fn <- fns[[fn_name]]
    row_vals <- rep("", ncols)
    row_vals[1] <- fn_name

    for (ci in col_indices) {
      raw_values <- collect_raw_values(blueprint, row_range, ci, data)
      if (length(raw_values) > 0 && !all(is.na(raw_values))) {
        val <- tryCatch(fn(raw_values), error = function(e) NA)
        if (!is.null(fmt_fn)) {
          row_vals[ci] <- fmt_fn(val)
        } else if (is.numeric(val) && !is.na(val)) {
          row_vals[ci] <- format(round(val, 1), nsmall = 1)
        } else {
          row_vals[ci] <- as.character(val)
        }
      }
    }

    results[[fn_name]] <- row_vals
  }

  results
}

#' Collect raw numeric values from blueprint cells
#'
#' For each computation cell in the given rows and column,
#' evaluates the \code{data_subset} expression to retrieve the
#' underlying numeric vector. Content and separator cells are
#' skipped. Factor-level cells (whose data_subset yields a data
#' frame) return the row count as the numeric value.
#'
#' @param blueprint Table1Blueprint object
#' @param row_range Integer vector of row indices
#' @param col Column index
#' @param data Source data frame
#' @return Numeric vector of raw values
#' @keywords internal
collect_raw_values <- function(blueprint, row_range, col, data) {
  values <- numeric(0)

  for (ri in row_range) {
    key <- sprintf("%d_%d", ri, col)
    if (!exists(key, envir = blueprint$cells, inherits = FALSE)) next

    cell <- blueprint$cells[[key]]
    if (is.null(cell)) next
    if (!inherits(cell, "cell_computation")) next
    if (is.null(cell$data_subset)) next

    subset_result <- tryCatch(
      eval(cell$data_subset, list(data = data)),
      error = function(e) NULL
    )

    if (is.null(subset_result)) next

    if (is.data.frame(subset_result)) {
      values <- c(values, nrow(subset_result))
    } else if (is.numeric(subset_result)) {
      values <- c(values, subset_result[!is.na(subset_result)])
    }
  }

  values
}

#' Detect row group boundaries in a blueprint
#'
#' Scans the first column of the content matrix and identifies
#' group boundaries. A group starts at a non-indented row (a
#' variable header) and extends through its indented child rows.
#'
#' @param content_matrix Character matrix of evaluated cell content
#' @param blueprint The blueprint object (for metadata)
#' @return A list of lists, each with \code{name}, \code{start_row},
#'   and \code{end_row}.
#' @keywords internal
detect_row_groups <- function(content_matrix, blueprint) {
  nrows <- nrow(content_matrix)
  if (nrows == 0) return(list())

  col1 <- content_matrix[, 1]
  groups <- list()
  current_group <- NULL

  for (i in seq_len(nrows)) {
    cell_text <- col1[i]
    is_indented <- grepl("^\\s+", cell_text) || nchar(cell_text) == 0

    if (!is_indented && nchar(trimws(cell_text)) > 0) {
      if (!is.null(current_group)) {
        current_group$end_row <- i - 1L
        groups <- c(groups, list(current_group))
      }
      current_group <- list(
        name = trimws(cell_text),
        start_row = i,
        end_row = nrows
      )
    }
  }

  if (!is.null(current_group)) {
    current_group$end_row <- nrows
    groups <- c(groups, list(current_group))
  }

  groups
}
