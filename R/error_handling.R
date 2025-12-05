# ============================================================================
# Enhanced Error Handling with Optional rlang Integration
# ============================================================================
#
# This module provides error handling utilities that optionally leverage
# rlang for better error messages and debugging context. If rlang is not
# installed, falls back to base R error handling.
#
# @keywords internal

#' Check if rlang is available
#'
#' @return Logical indicating if rlang package is installed and can be loaded
#'
#' @keywords internal
has_rlang <- function() {
  tryCatch(
    {
      requireNamespace("rlang", quietly = TRUE)
    },
    error = function(e) FALSE
  )
}

#' Throw informative error (with optional rlang)
#'
#' Throws an error with context information. If rlang is available,
#' uses rlang::abort() for better error formatting and stack traces.
#' Otherwise falls back to base R stop().
#'
#' @param message Error message
#' @param class Error class (for rlang)
#' @param ... Additional arguments for error context
#'
#' @keywords internal
abort_with_context <- function(message, class = NULL, ...) {
  if (has_rlang()) {
    # Use rlang for enhanced error handling
    rlang::abort(message, class = class, ...)
  } else {
    # Fallback to base R
    stop(message, call. = FALSE)
  }
}

#' Extract variable name from expression (with optional rlang)
#'
#' Safely extracts variable name from an R expression. If rlang is available,
#' uses rlang's quoting functions for better handling of complex expressions.
#' Otherwise falls back to deparse().
#'
#' @param expr An R expression (symbol, call, or formula)
#' @return Character string with expression as text
#'
#' @keywords internal
expr_to_string <- function(expr) {
  if (has_rlang()) {
    # Use rlang for better expression handling
    tryCatch(
      {
        as.character(rlang::expr_text(expr))
      },
      error = function(e) deparse(expr)[1]
    )
  } else {
    # Fallback to deparse
    deparse(expr)[1]
  }
}

#' Get variable name with context (with optional rlang)
#'
#' Extracts a clean variable name from a quoted expression.
#' If rlang is available, uses rlang::quo_name() for better handling.
#' Otherwise uses deparse().
#'
#' @param x A quoted expression or name
#' @return Character string with variable name
#'
#' @keywords internal
var_name_from_expr <- function(x) {
  if (has_rlang()) {
    # Use rlang for cleaner variable extraction
    tryCatch(
      {
        # If it's a formula, get the LHS
        if (inherits(x, "formula")) {
          rlang::expr_text(x[[2]])
        } else if (is.name(x) || is.symbol(x)) {
          rlang::as_name(x)
        } else {
          rlang::expr_text(x)
        }
      },
      error = function(e) {
        # Fallback if rlang fails
        if (inherits(x, "formula")) {
          deparse(x[[2]])[1]
        } else {
          deparse(x)[1]
        }
      }
    )
  } else {
    # Fallback to base R
    if (inherits(x, "formula")) {
      deparse(x[[2]])[1]
    } else {
      deparse(x)[1]
    }
  }
}

#' Validate formula with enhanced error reporting
#'
#' Validates formula structure and provides helpful error messages.
#' Uses optional rlang for better error formatting.
#'
#' @param formula A formula object
#' @param context Description of context (for error messages)
#'
#' @return Invisible NULL if valid
#'
#' @keywords internal
validate_formula_structure <- function(formula, context = "formula") {
  if (!inherits(formula, "formula")) {
    msg <- sprintf(
      "%s must be a formula, not %s",
      context,
      class(formula)[1]
    )
    abort_with_context(msg, class = "invalid_formula")
  }

  formula_length <- length(formula)
  if (formula_length < 2 || formula_length > 3) {
    msg <- sprintf(
      "%s must have 2 or 3 parts, got %d",
      context,
      formula_length
    )
    abort_with_context(msg, class = "invalid_formula_length")
  }

  invisible(NULL)
}

#' Validate variable exists in data with enhanced error
#'
#' Checks if a variable exists in a data frame with helpful error message.
#' Uses optional rlang for better error context.
#'
#' @param var_name Character string with variable name
#' @param data Data frame to check
#' @param context Description of context (for error messages)
#'
#' @return Invisible NULL if valid
#'
#' @keywords internal
validate_var_in_data <- function(var_name, data, context = "Variable") {
  if (!var_name %in% colnames(data)) {
    available <- paste(colnames(data), collapse = ", ")
    msg <- sprintf(
      "%s '%s' not found in data.\nAvailable variables: %s",
      context,
      var_name,
      available
    )
    abort_with_context(msg, class = "variable_not_found")
  }

  invisible(NULL)
}

#' Validate variable is of expected type
#'
#' Checks variable type and provides helpful error message.
#'
#' @param var_name Character string with variable name
#' @param data Data frame containing the variable
#' @param expected_class Expected class(es)
#' @param context Description of context (for error messages)
#'
#' @return Invisible NULL if valid
#'
#' @keywords internal
validate_var_type <- function(var_name, data, expected_class, context = "Variable") {
  if (!var_name %in% colnames(data)) {
    return(invisible(NULL))  # Let validate_var_in_data handle this
  }

  actual_class <- class(data[[var_name]])[1]

  if (!actual_class %in% expected_class) {
    msg <- sprintf(
      "%s '%s' must be %s, not %s",
      context,
      var_name,
      paste(expected_class, collapse = " or "),
      actual_class
    )
    abort_with_context(msg, class = "invalid_variable_type")
  }

  invisible(NULL)
}

#' Get enhanced error message with optional rlang trace
#'
#' Provides error messages with optional stack trace information.
#' Uses rlang::trace_back() if available for better debugging.
#'
#' @param message Error message
#' @param include_trace Logical, whether to include stack trace
#'
#' @return Character string with error message and optional trace
#'
#' @keywords internal
get_error_message <- function(message, include_trace = FALSE) {
  if (!include_trace || !has_rlang()) {
    return(message)
  }

  # Get stack trace if rlang is available
  tryCatch(
    {
      trace <- rlang::trace_back(top = -2)
      paste0(message, "\n\nStack trace:\n", format(trace))
    },
    error = function(e) message
  )
}

#' Create safe data subsetting expression (with optional rlang)
#'
#' Creates safe expressions for subsetting data with variables.
#' If rlang is available, uses tidy evaluation for safer handling.
#'
#' @param data Data frame to subset
#' @param var_name Variable name to extract
#'
#' @return Vector from data[[var_name]]
#'
#' @keywords internal
safe_extract_var <- function(data, var_name) {
  validate_var_in_data(var_name, data, context = "Variable")

  # Use direct extraction for safety
  tryCatch(
    {
      data[[var_name]]
    },
    error = function(e) {
      msg <- sprintf("Error extracting variable '%s': %s", var_name, conditionMessage(e))
      abort_with_context(msg, class = "extraction_error")
    }
  )
}

#' Warn user about behavior (with optional rlang)
#'
#' Issues a warning with optional rlang formatting.
#'
#' @param message Warning message
#' @param class Warning class (for rlang)
#'
#' @keywords internal
warn_behavior <- function(message, class = NULL) {
  if (has_rlang()) {
    # Use rlang for formatted warning
    rlang::warn(message, class = class)
  } else {
    # Fallback to base R
    warning(message, call. = FALSE)
  }
}

#' Suggest possible solutions to user
#'
#' Provides helpful suggestions for common errors.
#' If rlang is available, formats suggestions nicely.
#'
#' @param error_class Error class to suggest solutions for
#' @param details Additional context about the error
#'
#' @return Character vector with suggestions
#'
#' @keywords internal
get_error_suggestion <- function(error_class, details = NULL) {
  suggestions <- switch(error_class,
    "invalid_formula" = c(
      "Use format: ~ variables (one-sided)",
      "Or: group ~ variables (two-sided)"
    ),
    "variable_not_found" = c(
      "Check variable names with: names(data)",
      "Variable names are case-sensitive",
      if (!is.null(details)) sprintf("Did you mean '%s'?", details) else NULL
    ),
    "invalid_variable_type" = c(
      "Use appropriate conversion: factor(), as.numeric(), etc.",
      "Check variable class with: class(data$variable)"
    ),
    c(
      "Review error message above",
      "Check function documentation with: ?table1"
    )
  )

  # Filter out NULLs
  suggestions[!sapply(suggestions, is.null)]
}

# Export error handling utilities for developers
# These can be used by other functions in the package for consistent error handling
