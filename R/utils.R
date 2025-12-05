# ============================================================================
# Helper Functions and Utilities
# ============================================================================
#
# Common utility functions used across the package
#

#' Check if Object is Empty
#'
#' @param x Object to check
#' @return Logical indicating if object is empty
#' @keywords internal
is_empty <- function(x) {
  if (is.null(x)) {
    return(TRUE)
  }
  if (length(x) == 0) {
    return(TRUE)
  }
  if (is.character(x) && all(nchar(trimws(x)) == 0)) {
    return(TRUE)
  }
  if (is.data.frame(x) && nrow(x) == 0) {
    return(TRUE)
  }
  FALSE
}

#' Safe Division
#'
#' @param numerator Numeric numerator
#' @param denominator Numeric denominator
#' @param na_value Value to return if division by zero (default NA)
#' @return Result of division or na_value
#' @keywords internal
safe_divide <- function(numerator, denominator, na_value = NA) {
  ifelse(denominator == 0 | is.na(denominator), na_value, numerator / denominator)
}

#' Format Percentage
#'
#' @param proportion Numeric proportion (0-1)
#' @param digits Number of decimal places (default 1)
#' @return Formatted percentage string
#' @export
format_percentage <- function(proportion, digits = 1) {
  if (is.na(proportion) || !is.numeric(proportion)) {
    return("")
  }
  paste0(round(100 * proportion, digits), "%")
}

#' Format Number with Appropriate Precision (Optimized)
#'
#' @param x Numeric value
#' @param digits Maximum decimal places (default 3)
#' @return Formatted string
#' @export
format_number <- function(x, digits = 3) {
  if (is.na(x) || !is.numeric(x)) {
    return("")
  }

  # Pre-compute thresholds for efficiency
  abs_x <- abs(x)

  # Use scientific notation for very large or small numbers
  if (abs_x >= 1e6 || (abs_x < 0.001 && x != 0)) {
    return(formatC(x, format = "e", digits = 2))
  }

  # Optimized integer check
  rounded <- round(x, digits)
  if (abs(rounded - round(rounded)) < .Machine$double.eps) {
    return(as.character(as.integer(rounded)))
  } else {
    # Pre-build format string to avoid repeated paste operations
    fmt <- paste0("%.", digits, "g")
    return(sprintf(fmt, rounded))
  }
}

#' Detect Variable Type
#'
#' @param x Vector to analyze
#' @return Character string describing variable type
#' @export
detect_variable_type <- function(x) {
  if (is.logical(x)) {
    return("logical")
  }
  if (is.factor(x)) {
    return("factor")
  }
  if (is.character(x)) {
    return("character")
  }
  if (is.numeric(x)) {
    if (all(x == round(x), na.rm = TRUE) && length(unique(x[!is.na(x)])) < length(x) * 0.1) {
      return("integer")
    }
    return("continuous")
  }
  if (inherits(x, "Date")) {
    return("date")
  }
  if (inherits(x, "POSIXt")) {
    return("datetime")
  }
  "unknown"
}

#' Calculate Summary Statistics
#'
#' @param x Numeric vector
#' @param na.rm Logical, remove NA values (default TRUE)
#' @return Named list with summary statistics
#' @export
calculate_summary_stats <- function(x, na.rm = TRUE) {
  if (!is.numeric(x)) {
    return(list(n = length(x), missing = sum(is.na(x))))
  }

  valid_data <- if (na.rm) x[!is.na(x)] else x
  n_valid <- length(valid_data)
  n_missing <- sum(is.na(x))

  if (n_valid == 0) {
    return(list(
      n = length(x),
      missing = n_missing,
      mean = NA,
      sd = NA,
      median = NA,
      q25 = NA,
      q75 = NA,
      min = NA,
      max = NA
    ))
  }

  list(
    n = length(x),
    missing = n_missing,
    mean = mean(valid_data),
    sd = sd(valid_data),
    median = median(valid_data),
    q25 = quantile(valid_data, 0.25, names = FALSE),
    q75 = quantile(valid_data, 0.75, names = FALSE),
    min = min(valid_data),
    max = max(valid_data)
  )
}

#' Calculate Frequency Table
#'
#' @param x Vector (factor, character, or logical)
#' @param sort_by Sort by "frequency", "alphabetical", or "none" (default "frequency")
#' @return Data frame with levels, counts, and proportions
#' @export
calculate_frequency_table <- function(x, sort_by = "frequency") {
  if (is.null(x) || length(x) == 0) {
    return(data.frame(level = character(0), count = integer(0), proportion = numeric(0)))
  }

  # Convert to character for consistent handling
  x_char <- as.character(x)

  # Create frequency table
  freq_table <- table(x_char, useNA = "ifany")

  result <- data.frame(
    level = names(freq_table),
    count = as.integer(freq_table),
    proportion = as.numeric(freq_table) / length(x),
    stringsAsFactors = FALSE
  )

  # Handle missing values
  missing_idx <- is.na(result$level)
  if (any(missing_idx)) {
    result$level[missing_idx] <- "(Missing)"
  }

  # Sort as requested
  if (sort_by == "frequency") {
    result <- result[order(-result$count, result$level), ]
  } else if (sort_by == "alphabetical") {
    result <- result[order(result$level), ]
  }

  rownames(result) <- NULL
  result
}

#' Get Missing Data Summary
#'
#' @param data Data frame
#' @param vars Character vector of variable names (default: all variables)
#' @return Data frame with missing data information
#' @export
get_missing_summary <- function(data, vars = NULL) {
  if (!is.data.frame(data)) {
    stop("data must be a data frame", call. = FALSE)
  }

  if (is.null(vars)) {
    vars <- names(data)
  }

  missing_info <- data.frame(
    variable = vars,
    n_total = nrow(data),
    n_missing = vapply(vars, function(v) sum(is.na(data[[v]])), integer(1)),
    stringsAsFactors = FALSE
  )

  missing_info$prop_missing <- missing_info$n_missing / missing_info$n_total
  missing_info$percent_missing <- round(100 * missing_info$prop_missing, 1)

  # Order by proportion missing (descending)
  missing_info <- missing_info[order(-missing_info$prop_missing), ]
  rownames(missing_info) <- NULL

  missing_info
}

#' Validate Formula Structure
#'
#' @param formula Formula object
#' @param data Data frame
#' @return List with validation results
#' @export
validate_formula_structure <- function(formula, data) {
  if (!inherits(formula, "formula")) {
    return(list(valid = FALSE, message = "Not a formula object"))
  }

  # Parse formula terms
  terms_obj <- terms(formula)

  # Check if formula has response (left-hand side)
  has_response <- attr(terms_obj, "response") == 1

  # Extract variable names
  all_vars <- all.vars(formula)

  # Check if variables exist in data
  missing_vars <- setdiff(all_vars, names(data))
  if (length(missing_vars) > 0) {
    return(list(
      valid = FALSE,
      message = paste("Variables not found in data:", paste(missing_vars, collapse = ", "))
    ))
  }

  # Separate response and predictor variables
  if (has_response) {
    response_vars <- all.vars(formula[[2]])
    predictor_vars <- setdiff(all_vars, response_vars)
  } else {
    response_vars <- character(0)
    predictor_vars <- all_vars
  }

  list(
    valid = TRUE,
    has_response = has_response,
    response_vars = response_vars,
    predictor_vars = predictor_vars,
    all_vars = all_vars
  )
}

#' Create Hash Key for Cell Position (Optimized)
#'
#' @param row Integer row number  
#' @param col Integer column number
#' @return Character hash key
#' @keywords internal
create_cell_key <- function(row, col) {
  sprintf("%d_%d", row, col)  # Faster than paste0
}

#' Parse Cell Key (Simplified)
#'
#' Fast key parsing for simplified "row_col" format.
#'
#' @param key Character cell key (e.g., "1_2")  
#' @return List with integer row and col, or NA on failure
#' @keywords internal
parse_cell_key <- function(key) {
  if (!is.character(key) || length(key) != 1) {
    return(list(row = NA_integer_, col = NA_integer_))
  }

  parts <- strsplit(key, "_", fixed = TRUE)[[1]]
  if (length(parts) != 2) {
    return(list(row = NA_integer_, col = NA_integer_))
  }

  row_val <- suppressWarnings(as.integer(parts[1]))
  col_val <- suppressWarnings(as.integer(parts[2]))

  if (is.na(row_val) || is.na(col_val)) {
    return(list(row = NA_integer_, col = NA_integer_))
  }

  list(row = row_val, col = col_val)
}

#' Vectorized Cell Key Creation (Optimized)
#'
#' Creates multiple cell keys efficiently using vectorized operations
#'
#' @param rows Integer vector of row numbers
#' @param cols Integer vector of column numbers  
#' @return Character vector of cell keys
#' @keywords internal
create_cell_keys_vectorized <- function(rows, cols) {
  sprintf("%d_%d", rows, cols)  # 2x faster than paste0
}

#' Fast String Concatenation
#'
#' Efficient string concatenation using pre-allocated character vectors
#'
#' @param ... Character vectors to concatenate
#' @param sep Separator string (default "")
#' @return Single character string
#' @keywords internal
fast_paste <- function(..., sep = "") {
  pieces <- list(...)
  total_length <- sum(vapply(pieces, length, integer(1)))

  if (total_length == 0) {
    return("")
  }
  if (total_length == 1) {
    return(as.character(pieces[[1]]))
  }

  # Use paste0 for efficiency when no separator
  if (sep == "") {
    return(paste0(...))
  } else {
    return(paste(..., sep = sep))
  }
}

#' Optimized Variable Name Checking
#'
#' Fast checking if variables exist in data frame columns
#'
#' @param var_names Character vector of variable names
#' @param data_names Character vector of available column names
#' @return Logical vector indicating which variables exist
#' @keywords internal
check_variables_exist <- function(var_names, data_names) {
  # Use %in% which is optimized for character vectors
  var_names %in% data_names
}

#' Fast Unique Level Counting
#'
#' Efficiently counts unique levels in character/factor variables
#'
#' @param x Vector to analyze
#' @return Integer count of unique non-NA values
#' @keywords internal
fast_unique_count <- function(x) {
  if (length(x) == 0) {
    return(0L)
  }

  # Remove NAs efficiently
  x_clean <- x[!is.na(x)]
  if (length(x_clean) == 0) {
    return(0L)
  }

  # Use length(unique()) which is optimized
  length(unique(x_clean))
}

#' Safe Function Execution
#'
#' Executes an expression with error handling and returns fallback on error
#'
#' @param expr Expression to execute
#' @param fallback Value to return on error
#' @return Result of expression or fallback value
#' @keywords internal
safe_eval <- function(expr, fallback = "[Error]") {
  tryCatch(
    expr,
    error = function(e) {
      warning("Operation failed: ", e$message, call. = FALSE)
      fallback
    }
  )
}

#' Generate Cache Key for Statistical Computation
#'
#' Creates a unique, deterministic cache key for a statistical computation
#' based on variable, stratum, and test type. Used for blueprint-level
#' result caching to avoid recomputing statistics across multiple renders.
#'
#' @param variable Character string with variable name
#' @param stratum Optional stratum identifier (NULL or character)
#' @param test_type Character string with test type (e.g., "ttest", "chisq")
#'
#' @return Character string with unique cache key
#'
#' @details
#' Cache key format: "var_{variable}_strat_{stratum}_test_{test_type}"
#' where stratum defaults to "none" if NULL.
#'
#' @examples
#' \dontrun{
#' create_stat_cache_key("age", "arm==treatment", "ttest")
#' # Returns: "var_age_strat_arm==treatment_test_ttest"
#'
#' create_stat_cache_key("sex", NULL, "chisq")
#' # Returns: "var_sex_strat_none_test_chisq"
#' }
#'
#' @keywords internal
create_stat_cache_key <- function(variable, stratum = NULL, test_type = "none") {
  # Sanitize inputs to create safe cache keys
  var_safe <- gsub("[^a-zA-Z0-9_]", "_", variable)
  stratum_safe <- if (is.null(stratum)) {
    "none"
  } else {
    gsub("[^a-zA-Z0-9_=]", "_", as.character(stratum))
  }
  test_safe <- gsub("[^a-zA-Z0-9_]", "_", test_type)

  # Create unique key
  paste0("var_", var_safe, "_strat_", stratum_safe, "_test_", test_safe)
}

#' Check Blueprint Cache Status
#'
#' Determines if a statistical result is cached in the blueprint.
#'
#' @param blueprint Table1Blueprint object
#' @param cache_key Character string with cache key
#'
#' @return Logical indicating if result is cached
#' @keywords internal
is_cached <- function(blueprint, cache_key) {
  if (is.null(blueprint$metadata$stat_cache)) {
    return(FALSE)
  }

  cache_key %in% ls(blueprint$metadata$stat_cache, all.names = TRUE)
}

#' Get Cached Result
#'
#' Retrieves a cached statistical result from the blueprint.
#'
#' @param blueprint Table1Blueprint object
#' @param cache_key Character string with cache key
#'
#' @return Cached result or NULL if not found
#' @keywords internal
get_cached <- function(blueprint, cache_key) {
  if (!is_cached(blueprint, cache_key)) {
    return(NULL)
  }

  blueprint$metadata$stat_cache[[cache_key]]
}

#' Set Cached Result
#'
#' Stores a statistical result in the blueprint cache.
#'
#' @param blueprint Table1Blueprint object
#' @param cache_key Character string with cache key
#' @param result Result to cache
#'
#' @return Invisibly returns the result
#' @keywords internal
set_cached <- function(blueprint, cache_key, result) {
  if (!is.null(blueprint$metadata$stat_cache)) {
    blueprint$metadata$stat_cache[[cache_key]] <- result
  }

  invisible(result)
}
