# ============================================================================
# Optimized Cell System with Proper S3 Classes
# ============================================================================
#
# This module provides a complete rewrite of the cell system using modern
# R best practices including:
# - Proper S3 class hierarchy with validation
# - Type safety and input validation
# - Memory-efficient storage patterns
# - Enhanced error handling
# - Performance optimizations
#
# Key improvements:
# - Validated constructors preventing invalid states
# - Memory-efficient cell types
# - Enhanced error messages
# - Type safety throughout
# - Better performance through specialized methods
#
# ============================================================================

#' Create Cell Object with Validation (User Interface)
#'
#' User-facing constructor that provides comprehensive input validation
#' and creates properly validated Cell objects.
#'
#' @param type Character string specifying cell type. Must be one of:
#'   "content", "computation", "separator"
#' @param content Static text content (required for "static" type)
#' @param data_subset R expression for data subsetting (required for "computation")
#' @param computation R expression for calculation (required for "computation")
#' @param dependencies Character vector of variable dependencies
#' @param format Named list of formatting options
#' @param cached_result Cached computation result (for performance)
#' @param footnote_number Integer footnote number (for footnote cells)
#' @param footnote_text Character footnote text (for footnote cells)
#'
#' @return Validated Cell object of class "cell"
#'
#' @examples
#' # Static cell
#' Cell(type = "static", content = "Age (years)")
#'
#' # Computation cell
#' Cell(
#'   type = "computation",
#'   data_subset = expression(data$age[data$group == "Treatment"]),
#'   computation = expression(paste0(round(mean(x), 1), " +/- ", round(sd(x), 1))),
#'   dependencies = c("data", "age", "group")
#' )
#'
#' # Footnote cell
#' Cell(
#'   type = "footnote", footnote_number = 1,
#'   footnote_text = "Age measured at baseline"
#' )
#'
#' @export
Cell <- function(type, content = NULL, data_subset = NULL, computation = NULL,
                 dependencies = NULL, format = list(), cached_result = NULL,
                 footnote_number = NULL, footnote_text = NULL) {
  # Comprehensive input validation
  validate_cell_inputs(
    type, content, data_subset, computation,
    dependencies, format, cached_result,
    footnote_number, footnote_text
  )

  # Create cell using internal constructor
  new_cell(
    type = type, content = content, data_subset = data_subset,
    computation = computation, dependencies = dependencies,
    format = format, cached_result = cached_result,
    footnote_number = footnote_number, footnote_text = footnote_text
  )
}

#' Internal Cell Constructor
#'
#' Low-level constructor that creates cell objects after validation.
#' Used internally after input validation has been performed.
#'
#' @param type Validated cell type
#' @param content Content (validated)
#' @param data_subset Data subset expression (validated)
#' @param computation Computation expression (validated)
#' @param dependencies Dependencies vector (validated)
#' @param format Format list (validated)
#' @param cached_result Cached result (validated)
#' @param footnote_number Footnote number (validated)
#' @param footnote_text Footnote text (validated)
#'
#' @return Cell object (not yet validated)
#' @keywords internal
new_cell <- function(type, content = NULL, data_subset = NULL,
                     computation = NULL, dependencies = NULL,
                     format = list(), cached_result = NULL,
                     footnote_number = NULL, footnote_text = NULL) {
  # Create optimized cell structure based on type
  cell_data <- create_cell_data_by_type(
    type, content, data_subset, computation,
    dependencies, format, cached_result,
    footnote_number, footnote_text
  )

  # Add class and validate
  cell <- structure(cell_data, class = c(paste0("cell_", type), "cell"))
  validate_cell(cell)

  return(cell)
}

#' Validate Cell Inputs
#'
#' Comprehensive validation of all cell constructor inputs with
#' informative error messages for each validation failure.
#'
#' @param type Cell type
#' @param content Content parameter
#' @param data_subset Data subset parameter
#' @param computation Computation parameter
#' @param dependencies Dependencies parameter
#' @param format Format parameter
#' @param cached_result Cached result parameter
#' @param footnote_number Footnote number parameter
#' @param footnote_text Footnote text parameter
#'
#' @keywords internal
validate_cell_inputs <- function(type, content, data_subset, computation,
                                 dependencies, format, cached_result,
                                 footnote_number, footnote_text) {
  # Type validation
  if (!is.character(type) || length(type) != 1) {
    stop("'type' must be a single character string", call. = FALSE)
  }

  valid_types <- c("content", "computation", "separator")
  if (!type %in% valid_types) {
    stop("'type' must be one of: ", paste(valid_types, collapse = ", "), call. = FALSE)
  }

  # Type-specific validation
  if (type == "content") {
    if (is.null(content)) {
      stop("Content cells require 'content' parameter", call. = FALSE)
    }
    if (!is.character(content) || length(content) != 1) {
      stop("Content cell 'content' must be a single character string", call. = FALSE)
    }
  } else if (type == "computation") {
    if (is.null(data_subset) || is.null(computation)) {
      stop("Computation cells require both 'data_subset' and 'computation' parameters",
        call. = FALSE
      )
    }

    if (!is.expression(data_subset) && !is.call(data_subset)) {
      stop("'data_subset' must be an expression or call", call. = FALSE)
    }

    if (!is.expression(computation) && !is.call(computation) && !is.function(computation)) {
      stop("'computation' must be an expression, call, or function", call. = FALSE)
    }
  } else if (type == "separator") {
    # No additional validation needed for separators
  }

  # General parameter validation
  if (!is.null(dependencies)) {
    if (!is.character(dependencies)) {
      stop("'dependencies' must be a character vector", call. = FALSE)
    }
  }

  if (!is.list(format)) {
    stop("'format' must be a list", call. = FALSE)
  }
}

#' Create Cell Data by Type
#'
#' Creates optimized cell data structures tailored to each cell type.
#' This eliminates memory waste by only storing relevant fields.
#'
#' @param type Cell type
#' @param ... All other parameters
#'
#' @return Optimized cell data list
#' @keywords internal
create_cell_data_by_type <- function(type, content, data_subset, computation,
                                     dependencies, format, cached_result,
                                     footnote_number, footnote_text) {
  # Base structure (minimal)
  base <- list(type = type, created = Sys.time())

  # Type-specific optimized structures
  switch(type,
    "content" = c(base, list(
      content = content,
      format = if (length(format) > 0) format else NULL
    )),
    "computation" = c(base, list(
      data_subset = data_subset,
      computation = computation,
      dependencies = dependencies,
      format = if (length(format) > 0) format else NULL,
      cached_result = cached_result,
      cache_timestamp = if (!is.null(cached_result)) Sys.time() else NULL
    )),
    "separator" = c(base, list(
      content = content %||% "|",
      format = if (length(format) > 0) format else NULL
    )),
    stop("Unknown cell type: ", type)
  )
}

#' Validate Cell Object
#'
#' Comprehensive validation of constructed cell objects ensuring
#' structural integrity and type consistency.
#'
#' @param x Cell object to validate
#' @param strict Logical indicating whether to perform expensive checks
#'
#' @return Validated cell object (invisibly) or stops with error
#' @keywords internal
validate_cell <- function(x, strict = FALSE) {
  errors <- character()

  # Class validation
  if (!inherits(x, "cell")) {
    errors <- c(errors, "Object must inherit from 'cell' class")
  }

  # Required fields
  if (is.null(x$type)) {
    errors <- c(errors, "Cell must have 'type' field")
  } else if (!is.character(x$type) || length(x$type) != 1) {
    errors <- c(errors, "Cell 'type' must be single character string")
  }

  # Type-specific validation
  if (!is.null(x$type)) {
    type_errors <- validate_cell_by_type(x, strict)
    errors <- c(errors, type_errors)
  }

  # Report errors
  if (length(errors) > 0) {
    stop("Invalid cell object:\n",
      paste("  *", errors, collapse = "\n"),
      call. = FALSE
    )
  }

  invisible(x)
}

#' Validate Cell by Type
#'
#' Type-specific validation logic.
#'
#' @param x Cell object
#' @param strict Logical for strict validation
#'
#' @return Character vector of errors (empty if valid)
#' @keywords internal
validate_cell_by_type <- function(x, strict) {
  errors <- character()

  switch(x$type,
    "content" = {
      if (is.null(x$content) || !is.character(x$content)) {
        errors <- c(errors, "Content cells must have character 'content'")
      }
    },
    "computation" = {
      if (is.null(x$data_subset)) {
        errors <- c(errors, "Computation cells must have 'data_subset'")
      }
      if (is.null(x$computation)) {
        errors <- c(errors, "Computation cells must have 'computation'")
      }

      # Strict validation for expressions
      if (strict) {
        if (!is.null(x$data_subset) &&
          !is.expression(x$data_subset) && !is.call(x$data_subset)) {
          errors <- c(errors, "Invalid data_subset expression")
        }
        if (!is.null(x$computation) &&
          !is.expression(x$computation) && !is.call(x$computation) &&
          !is.function(x$computation)) {
          errors <- c(errors, "Invalid computation expression/function")
        }
      }
    },
    "separator" = {
      # Separators are simple, minimal validation
    }
  )

  return(errors)
}

#' Enhanced Cell Evaluation
#'
#' Optimized cell evaluation with better error handling, caching,
#' and performance monitoring.
#'
#' @param cell Cell object to evaluate
#' @param data Data frame for computation context
#' @param env Evaluation environment
#' @param force_recalc Logical to force cache invalidation
#'
#' @return Evaluated cell result
#' @export
evaluate_cell <- function(cell, data, env = parent.frame(),
                                    force_recalc = FALSE) {
  # Input validation
  validate_cell(cell)
  if (!is.data.frame(data)) {
    stop("'data' must be a data.frame", call. = FALSE)
  }

  # Wrap evaluation in error handling
  tryCatch(
    {
      # Direct dispatch based on cell type
      switch(cell$type,
        "content" = evaluate_cell.content(NULL, cell, data, env, force_recalc),
        "computation" = evaluate_cell.computation(NULL, cell, data, env, force_recalc),
        "separator" = evaluate_cell.separator(NULL, cell, data, env, force_recalc),
        evaluate_cell.default(NULL, cell, data, env, force_recalc)
      )
    },
    error = function(e) {
      warning("Cell evaluation failed: ", e$message, call. = FALSE)
      "[Error]"
    }
  )
}

#' S3 Method for Content Cells
#' @keywords internal
evaluate_cell.content <- function(x, cell, data, env, force_recalc) {
  cell$content %||% ""
}

#' S3 Method for Computation Cells  
#' @keywords internal
evaluate_cell.computation <- function(x, cell, data, env, force_recalc) {
  evaluate_computation_cell(cell, data, env, force_recalc)
}

#' S3 Method for Separator Cells
#' @keywords internal
evaluate_cell.separator <- function(x, cell, data, env, force_recalc) {
  cell$content %||% "|"
}

#' Default S3 Method
#' @keywords internal
evaluate_cell.default <- function(x, cell, data, env, force_recalc) {
  "[Unknown Type]"
}

#' Evaluate Computation Cell (Optimized)
#'
#' Streamlined evaluation with reduced overhead
#'
#' @param cell Computation cell object
#' @param data Data frame
#' @param env Evaluation environment
#' @param force_recalc Force recalculation flag
#'
#' @return Computed result
#' @keywords internal
evaluate_computation_cell <- function(cell, data, env, force_recalc) {
  # Check cache first
  if (!force_recalc && !is.null(cell$cached_result)) {
    return(cell$cached_result)
  }

  # Simplified computation with minimal error handling overhead
  result <- safe_eval({
    # Evaluate data subset
    data_subset <- eval(cell$data_subset, list(data = data))
    
    if (is.null(data_subset)) {
      return("[No Data]")
    }

    # Execute computation
    comp_env <- list(
      x = data_subset,
      n = length(data_subset),
      data = data
    )
    
    computation_result <- if (is.function(cell$computation)) {
      cell$computation(data_subset)
    } else {
      eval(cell$computation, comp_env)
    }

    format_computation_result(computation_result)
  }, "[Error]")

  # Cache successful results
  if (!identical(result, "[Error]") && !identical(result, "[No Data]")) {
    cell$cached_result <- result
    cell$cache_timestamp <- Sys.time()
  }

  result
}

#' Format Computation Result
#'
#' Ensures computation results are properly formatted for display.
#'
#' @param result Raw computation result
#'
#' @return Formatted character result
#' @keywords internal
format_computation_result <- function(result) {
  if (is.character(result)) {
    return(result)
  } else if (is.numeric(result)) {
    if (length(result) == 1) {
      return(as.character(result))
    } else {
      return(paste(result, collapse = ", "))
    }
  } else if (is.logical(result)) {
    return(as.character(result))
  } else {
    # Try to convert to character
    return(as.character(result))
  }
}

#' Evaluate Separator Cell
#'
#' Simple evaluation for separator cells.
#'
#' @param cell Separator cell
#'
#' @return Separator content
#' @keywords internal
evaluate_separator_cell <- function(cell) {
  cell$content %||% "|"
}


#' Print Method for Cell Objects
#'
#' Informative display of cell objects showing type and key content.
#'
#' @param x Cell object
#' @param ... Additional arguments
#'
#' @export
print.cell <- function(x, ...) {
  cat("Cell [", x$type, "]\n", sep = "")

  switch(x$type,
    "content" = cat("Content: '", substr(x$content %||% "", 1, 50), "'\n", sep = ""),
    "computation" = {
      cat("Data subset: ", deparse(x$data_subset)[1], "\n")
      cat("Computation: ", deparse(x$computation)[1], "\n")
      if (!is.null(x$cached_result)) {
        cat("Cached result: '", substr(as.character(x$cached_result), 1, 30), "'\n", sep = "")
      }
    },
    cat("Content: '", substr(x$content %||% "", 1, 50), "'\n", sep = "")
  )

  invisible(x)
}

#' Summary Method for Cell Objects
#'
#' Detailed summary of cell objects including metadata.
#'
#' @param object Cell object
#' @param ... Additional arguments
#'
#' @export
summary.cell <- function(object, ...) {
  cat("Cell Summary\n")
  cat("============\n")
  cat("Type: ", object$type, "\n")
  cat("Class: ", paste(class(object), collapse = ", "), "\n")
  cat("Created: ", format(object$created %||% "Unknown"), "\n")

  if (object$type == "computation") {
    cat("Dependencies: ", paste(object$dependencies %||% "None", collapse = ", "), "\n")
    cat("Cached: ", !is.null(object$cached_result), "\n")
    if (!is.null(object$cache_timestamp)) {
      cat("Cache timestamp: ", format(object$cache_timestamp), "\n")
    }
  }

  if (!is.null(object$format) && length(object$format) > 0) {
    cat("Format options: ", length(object$format), "\n")
  }

  invisible(object)
}


#' Clear Cell Cache
#' @param cell Cell object
#' @keywords internal
clear_cell_cache <- function(cell) {
  if (inherits(cell, "cell")) {
    cell$cached_result <- NULL
  }
  invisible(cell)
}

#' Vectorized Cell Evaluation
#' @param cells List of cell objects
#' @param data Data frame
#' @param parallel Logical, use parallel processing
#' @return List of evaluated results
#' @keywords internal
evaluate_cells_vectorized <- function(cells, data, parallel = FALSE) {
  if (!is.list(cells)) {
    return(list())
  }

  eval_func <- function(cell) {
    evaluate_cell(cell, data)
  }

  if (parallel && requireNamespace("parallel", quietly = TRUE)) {
    parallel::mclapply(cells, eval_func, mc.cores = parallel::detectCores() - 1)
  } else {
    lapply(cells, eval_func)
  }
}

#' Safe NULL-coalescing operator
#'
#' @param x First value
#' @param y Second value (used if x is NULL)
#' @keywords internal
`%||%` <- function(x, y) if (is.null(x)) y else x

#' Format Footnote Marker
#'
#' Creates footnote markers in different formats.
#'
#' @param number Footnote number
#' @param format Output format ("console", "latex", "html")
#'
#' @return Formatted marker string
#' @keywords internal
format_footnote_marker <- function(number, format = "console") {
  # Unicode superscript characters for 1-9
  superscripts <- c("¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹")
  
  switch(format,
    "console" = if (number <= 9) superscripts[number] else sprintf("(%d)", number),
    "latex" = sprintf("$^{%d}$", number), 
    "html" = sprintf("<sup>%d</sup>", number),
    if (number <= 9) superscripts[number] else sprintf("(%d)", number) # default
  )
}
