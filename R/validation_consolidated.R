# ============================================================================
# Consolidated Validation System
# ============================================================================

#' Validate All Table1 Inputs (Consolidated)
#'
#' Single entry point for all validation with comprehensive error checking.
#' Uses optional rlang package for enhanced error messages when available.
#'
#' @param formula Formula object
#' @param data Data frame
#' @param strata Optional stratification variable
#' @param theme Theme specification
#' @param ... Other parameters
#'
#' @return TRUE if valid, otherwise stops with error
#' @export
validate_inputs <- function(formula, data, strata = NULL, theme = "console", footnotes = NULL, ...) {
  # Helper to use rlang abort() if available, else base stop()
  abort_or_stop <- function(message, class = NULL) {
    if (requireNamespace("rlang", quietly = TRUE)) {
      rlang::abort(message, class = class)
    } else {
      stop(message, call. = FALSE)
    }
  }

  # Basic type checks
  if (!inherits(formula, "formula")) {
    msg <- sprintf(
      "First argument must be a formula, not %s. Example: group ~ var1 + var2",
      class(formula)[1]
    )
    abort_or_stop(msg, class = "invalid_formula_type")
  }

  if (!is.data.frame(data)) {
    msg <- sprintf(
      "'data' must be a data.frame, not %s",
      class(data)[1]
    )
    abort_or_stop(msg, class = "invalid_data_type")
  }

  if (nrow(data) == 0) {
    abort_or_stop(
      "Data frame is empty - provide a non-empty data frame",
      class = "empty_data"
    )
  }

  # Formula validation
  all_vars <- all.vars(formula)
  missing_vars <- setdiff(all_vars, colnames(data))
  if (length(missing_vars) > 0) {
    available_vars <- paste(colnames(data), collapse = ", ")
    msg <- sprintf(
      "Variables not found in data: %s\n\nAvailable variables:\n  %s",
      paste(missing_vars, collapse = ", "),
      available_vars
    )
    abort_or_stop(msg, class = "variables_not_found")
  }

  # Strata validation
  if (!is.null(strata)) {
    if (!is.character(strata) || length(strata) != 1) {
      msg <- sprintf(
        "Strata must be a single character string, not %s",
        class(strata)[1]
      )
      abort_or_stop(msg, class = "invalid_strata_type")
    }
    if (!strata %in% colnames(data)) {
      msg <- sprintf(
        "Stratification variable '%s' not found in data",
        strata
      )
      abort_or_stop(msg, class = "strata_not_found")
    }
    if (!is.factor(data[[strata]]) && !is.character(data[[strata]])) {
      msg <- sprintf(
        "Stratification variable '%s' must be factor or character, not %s",
        strata,
        class(data[[strata]])[1]
      )
      abort_or_stop(msg, class = "invalid_strata_type")
    }
  }

  # Footnotes validation
  if (!is.null(footnotes) && !is.list(footnotes)) {
    msg <- sprintf(
      "Footnotes must be a list, not %s",
      class(footnotes)[1]
    )
    abort_or_stop(msg, class = "invalid_footnotes_type")
  }

  # Data quality checks (warnings, not errors)
  check_data_quality(data, all_vars)

  # Theme validation with optional rlang warnings
  if (is.character(theme)) {
    valid_themes <- c("console", "nejm", "lancet", "jama", "bmj")
    if (!theme %in% valid_themes) {
      msg <- sprintf("Unknown theme '%s', using 'console'", theme)
      if (requireNamespace("rlang", quietly = TRUE)) {
        rlang::warn(msg, class = "unknown_theme")
      } else {
        warning(msg, call. = FALSE)
      }
    }
  }

  invisible(TRUE)
}

#' Quick Data Quality Check
#'
#' @param data Data frame
#' @param variables Variable names to check
#'
#' @keywords internal
check_data_quality <- function(data, variables) {
  for (var in variables) {
    if (var %in% colnames(data)) {
      # Check for high missing values
      missing_pct <- 100 * sum(is.na(data[[var]])) / nrow(data)
      if (missing_pct > 50) {
        warning("Variable '", var, "' has ", round(missing_pct, 1), 
               "% missing values", call. = FALSE)
      }
      
      # Check for too many factor levels
      if (is.factor(data[[var]]) || is.character(data[[var]])) {
        n_levels <- length(unique(data[[var]]))
        if (n_levels > 20) {
          warning("Variable '", var, "' has ", n_levels, 
                 " levels, which may be too many for a summary table", call. = FALSE)
        }
      }
    }
  }
}