# ============================================================================
# Consolidated Validation System
# ============================================================================

#' Validate All Table1 Inputs (Consolidated)
#'
#' Single entry point for all validation with comprehensive error checking
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
  # Basic type checks
  if (!inherits(formula, "formula")) {
    stop("First argument must be a formula (e.g., group ~ var1 + var2)", call. = FALSE)
  }
  
  if (!is.data.frame(data)) {
    stop("Data must be a data.frame", call. = FALSE)
  }
  
  if (nrow(data) == 0) {
    stop("Data frame is empty", call. = FALSE)
  }
  
  # Formula validation
  all_vars <- all.vars(formula)
  missing_vars <- setdiff(all_vars, colnames(data))
  if (length(missing_vars) > 0) {
    stop("Variables not found in data: ", paste(missing_vars, collapse = ", "), 
         call. = FALSE)
  }
  
  # Strata validation
  if (!is.null(strata)) {
    if (!is.character(strata) || length(strata) != 1) {
      stop("Strata must be a single character string", call. = FALSE)
    }
    if (!strata %in% colnames(data)) {
      stop("Stratification variable '", strata, "' not found in data", call. = FALSE)
    }
  }
  
  # Footnotes validation
  if (!is.null(footnotes) && !is.list(footnotes)) {
    stop("Footnotes must be a list", call. = FALSE)
  }
  
  # Data quality checks (warnings, not errors)
  check_data_quality(data, all_vars)
  
  # Theme validation
  if (is.character(theme)) {
    valid_themes <- c("console", "nejm", "lancet", "jama", "bmj")
    if (!theme %in% valid_themes) {
      warning("Unknown theme '", theme, "', using 'console'", call. = FALSE)
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