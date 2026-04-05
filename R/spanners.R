# ============================================================================
# Column Spanner System
# ============================================================================
#
# Provides hierarchical column headers (spanners) for table1_blueprint
# objects. Spanners group columns under shared labels and can be nested
# to produce multi-level column hierarchies.
#
# Storage: blueprint$metadata$spanners -- a list of spanner definitions,
# each with label, columns, id, level, and optional parent_id.
#
# ============================================================================

`%||%` <- function(x, y) if (is.null(x)) y else x

#' Add a Column Spanner to a Blueprint
#'
#' Groups one or more columns under a shared header label. Spanners
#' can reference other spanners by id to create nested hierarchies.
#'
#' @param blueprint A table1_blueprint object
#' @param label Character string displayed as the spanner header
#' @param columns Integer vector of column indices or character vector
#'   of column names to group under this spanner
#' @param id Optional unique identifier for this spanner. Defaults to
#'   a sanitised version of label. Required when building nested
#'   spanners that reference this one as a parent.
#' @param spanners Character vector of child spanner ids to nest under
#'   this spanner. When provided, \code{columns} is ignored and the
#'   spanner covers all columns owned by the referenced children.
#' @param level Integer spanner level (1 = closest to data columns).
#'   Normally computed automatically; set manually only to force a
#'   specific position.
#'
#' @return The blueprint, modified in place (spanner appended to
#'   \code{blueprint$metadata$spanners}).
#' @export
add_spanner <- function(blueprint, label, columns = NULL,
                        id = NULL, spanners = NULL, level = NULL) {
  stopifnot(inherits(blueprint, "table1_blueprint"))

  store <- blueprint$metadata$spanner_store
  existing <- as.list(store)

  id <- id %||% make_spanner_id(label)

  if (id %in% names(existing)) {
    stop("Spanner id '", id, "' already exists", call. = FALSE)
  }

  existing_spanners <- unname(existing)
  col_indices <- NULL

  if (!is.null(spanners)) {
    child_cols <- resolve_child_columns(existing_spanners, spanners)
    col_indices <- child_cols
    child_levels <- vapply(
      Filter(function(s) s$id %in% spanners, existing_spanners),
      `[[`, integer(1), "level"
    )
    level <- level %||% (max(child_levels) + 1L)
  } else if (!is.null(columns)) {
    col_indices <- resolve_column_indices(columns, blueprint$col_names)
    level <- level %||% 1L
  } else {
    stop("Either 'columns' or 'spanners' must be provided", call. = FALSE)
  }

  spanner_def <- list(
    id = id,
    label = label,
    columns = as.integer(sort(col_indices)),
    child_spanners = spanners,
    level = as.integer(level)
  )

  assign(id, spanner_def, envir = store)

  invisible(blueprint)
}


#' Add Spanners from Column Name Delimiters
#'
#' Automatically generates spanners by splitting column names on a
#' delimiter character. For example, columns named
#' \code{"hematology.wbc"} and \code{"hematology.rbc"} produce a
#' spanner labelled \code{"hematology"} covering both columns.
#'
#' @param blueprint A table1_blueprint object
#' @param delim Single character delimiter (default \code{"."})
#'
#' @return The blueprint with spanners added.
#' @export
add_spanner_delim <- function(blueprint, delim = ".") {
  stopifnot(inherits(blueprint, "table1_blueprint"))

  col_names <- blueprint$col_names
  groups <- list()

  for (i in seq_along(col_names)) {
    parts <- strsplit(col_names[i], delim, fixed = TRUE)[[1]]
    if (length(parts) >= 2) {
      group_label <- parts[1]
      short_label <- paste(parts[-1], collapse = delim)
      if (is.null(groups[[group_label]])) {
        groups[[group_label]] <- list(indices = integer(0),
                                      short = character(0))
      }
      groups[[group_label]]$indices <- c(
        groups[[group_label]]$indices, i
      )
      groups[[group_label]]$short <- c(
        groups[[group_label]]$short, short_label
      )
    }
  }

  for (group_label in names(groups)) {
    info <- groups[[group_label]]
    for (j in seq_along(info$indices)) {
      blueprint$col_names[info$indices[j]] <- info$short[j]
    }
    add_spanner(blueprint, label = group_label,
                columns = info$indices)
  }

  invisible(blueprint)
}


# -- internal helpers --------------------------------------------------------

#' Sanitise a label into a spanner id
#' @keywords internal
make_spanner_id <- function(label) {
  id <- tolower(gsub("[^a-zA-Z0-9]+", "_", label))
  id <- gsub("^_|_$", "", id)
  if (nchar(id) == 0) id <- "spanner"
  id
}

#' Resolve column references to integer indices
#' @keywords internal
resolve_column_indices <- function(columns, col_names) {
  if (is.character(columns)) {
    idx <- match(columns, col_names)
    if (any(is.na(idx))) {
      bad <- columns[is.na(idx)]
      stop("Column(s) not found: ",
           paste(bad, collapse = ", "), call. = FALSE)
    }
    idx
  } else if (is.numeric(columns)) {
    as.integer(columns)
  } else {
    stop("'columns' must be character or numeric", call. = FALSE)
  }
}

#' Collect all column indices owned by a set of child spanners
#' @keywords internal
resolve_child_columns <- function(spanners, child_ids) {
  found <- vapply(spanners,
                  function(s) s$id %in% child_ids, logical(1))
  if (sum(found) != length(child_ids)) {
    missing_ids <- setdiff(
      child_ids,
      vapply(spanners[found], `[[`, character(1), "id")
    )
    stop("Child spanner(s) not found: ",
         paste(missing_ids, collapse = ", "), call. = FALSE)
  }
  unique(unlist(lapply(spanners[found], `[[`, "columns")))
}

#' Get the list of spanner definitions from the blueprint
#' @param blueprint A table1_blueprint
#' @return List of spanner definition lists
#' @keywords internal
get_spanners <- function(blueprint) {
  store <- blueprint$metadata$spanner_store
  if (is.null(store) || length(ls(store, all.names = TRUE)) == 0) {
    return(list())
  }
  as.list(store)
}

#' Compute the maximum spanner level in a blueprint
#' @param blueprint A table1_blueprint
#' @return Integer max level, or 0 if no spanners
#' @keywords internal
max_spanner_level <- function(blueprint) {
  spanners <- get_spanners(blueprint)
  if (length(spanners) == 0) return(0L)
  max(vapply(spanners, `[[`, integer(1), "level"))
}

#' Build a matrix representation of spanner rows
#'
#' Returns a list of character vectors, one per spanner level (from
#' highest level to level 1), each of length \code{ncols}. Empty
#' strings indicate cells that are not part of any spanner at that
#' level.
#'
#' @param blueprint A table1_blueprint
#' @return List of named lists, each with \code{cells} (character
#'   vector) and \code{spans} (integer vector of colspans).
#' @keywords internal
build_spanner_rows <- function(blueprint) {
  spanners <- get_spanners(blueprint)
  if (length(spanners) == 0) return(list())

  n_levels <- max_spanner_level(blueprint)
  ncols <- blueprint$ncols
  rows <- list()

  for (lev in seq(n_levels, 1L)) {
    level_spanners <- Filter(function(s) s$level == lev, spanners)

    cells <- rep("", ncols)
    span_widths <- rep(1L, ncols)
    covered <- rep(FALSE, ncols)

    for (s in level_spanners) {
      cols <- s$columns
      if (length(cols) == 0) next
      min_col <- min(cols)
      max_col <- max(cols)
      cells[min_col] <- s$label
      span_widths[min_col] <- as.integer(max_col - min_col + 1L)
      covered[min_col:max_col] <- TRUE
    }

    rows[[length(rows) + 1]] <- list(
      cells = cells,
      spans = span_widths,
      covered = covered,
      level = lev
    )
  }

  rows
}
