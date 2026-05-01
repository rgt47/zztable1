# ============================================================================
# Parallel Processing Framework for Large Tables
# ============================================================================
#
# This module provides optional parallel processing capabilities for
# evaluating cells in large tables. Automatically uses parallel computing
# when beneficial (large tables), and falls back to serial for small tables.
#
# Supports both Unix/Linux/Mac (mclapply) and Windows (parLapply).
#
# @keywords internal

#' Check if parallel processing is available
#'
#' Determines if the parallel package is available and if parallel
#' processing should be used.
#'
#' @param num_cells Number of cells to process
#' @param threshold Minimum cells for parallel overhead to be worthwhile
#'
#' @return Logical indicating if parallel processing should be used
#'
#' @keywords internal
can_use_parallel <- function(num_cells, threshold = 1000) {
  # Only use parallel if:
  # 1. parallel package is available
  # 2. Enough cells to justify overhead (>1000)
  # 3. Multiple cores available
  if (!requireNamespace("parallel", quietly = TRUE)) {
    return(FALSE)
  }

  num_cores <- detect_cores()
  if (num_cores <= 1) {
    return(FALSE)
  }

  num_cells >= threshold
}

#' Detect number of available CPU cores
#'
#' Platform-aware core detection with sensible defaults.
#' Respects environment variables for cluster environments.
#'
#' @return Integer number of cores (minimum 1)
#'
#' @keywords internal
detect_cores <- function() {
  # Check for cluster environment variables first
  if (Sys.getenv("SLURM_CPUS_ON_NODE") != "") {
    return(as.integer(Sys.getenv("SLURM_CPUS_ON_NODE")))
  }

  if (Sys.getenv("OMP_NUM_THREADS") != "") {
    return(as.integer(Sys.getenv("OMP_NUM_THREADS")))
  }

  # Use parallel::detectCores() if available
  tryCatch(
    {
      cores <- parallel::detectCores()
      if (is.na(cores) || cores < 1) {
        return(1)
      }
      # Don't use more than 75% of available cores
      max(1, floor(cores * 0.75))
    },
    error = function(e) 1
  )
}

#' Evaluate blueprint cells in parallel (if beneficial)
#'
#' Evaluates cells in a blueprint, using parallel processing for
#' large tables if beneficial. Automatically determines whether to
#' use serial or parallel evaluation.
#'
#' @param blueprint Table1Blueprint object
#' @param force_parallel Logical, force parallel even for small tables
#'
#' @return Data frame with evaluated cell contents
#'
#' @keywords internal
evaluate_cells_smart <- function(blueprint, force_parallel = FALSE) {
  num_cells <- blueprint$nrows * blueprint$ncols
  use_parallel <- force_parallel || can_use_parallel(num_cells)

  if (use_parallel) {
    evaluate_cells_parallel(blueprint)
  } else {
    evaluate_cells_serial(blueprint)
  }
}

#' Evaluate cells using parallel processing
#'
#' Evaluates cells across multiple cores using platform-appropriate
#' parallelization (mclapply for Unix/Linux/Mac, parLapply for Windows).
#'
#' @param blueprint Table1Blueprint object
#'
#' @return Data frame with evaluated cell contents
#'
#' @keywords internal
evaluate_cells_parallel <- function(blueprint) {
  if (!requireNamespace("parallel", quietly = TRUE)) {
    # Fall back to serial if parallel not available
    return(evaluate_cells_serial(blueprint))
  }

  # Determine platform
  is_windows <- .Platform$OS.type == "windows"

  # Get available cores
  num_cores <- detect_cores()

  # Create cluster
  if (is_windows) {
    cluster <- parallel::makeCluster(num_cores, type = "PSOCK")
    on.exit(parallel::stopCluster(cluster))
  } else {
    # Use mclapply on Unix/Linux/Mac for better efficiency
    cluster <- NULL
  }

  # Get cell keys
  cell_keys <- ls(blueprint$cells, all.names = TRUE)

  if (is.null(cluster)) {
    # Unix/Linux/Mac: use mclapply
    results <- parallel::mclapply(
      cell_keys,
      function(key) {
        evaluate_single_cell(blueprint, key)
      },
      mc.cores = num_cores,
      mc.preschedule = TRUE
    )
  } else {
    # Windows: use parLapply
    # Export blueprint to cluster
    parallel::clusterExport(cluster, "blueprint", envir = environment())

    results <- parallel::parLapply(
      cluster,
      cell_keys,
      function(key) {
        evaluate_single_cell(blueprint, key)
      }
    )
  }

  # Convert results to matrix format
  convert_results_to_matrix(results, blueprint)
}

#' Evaluate cells serially (default method)
#'
#' Evaluates cells one at a time in the main process.
#' This is the default when parallel processing is not beneficial.
#'
#' @param blueprint Table1Blueprint object
#'
#' @return Data frame with evaluated cell contents
#'
#' @keywords internal
evaluate_cells_serial <- function(blueprint) {
  # Get cell keys
  cell_keys <- ls(blueprint$cells, all.names = TRUE)

  # Evaluate each cell serially
  results <- lapply(
    cell_keys,
    function(key) {
      evaluate_single_cell(blueprint, key)
    }
  )

  # Convert results to matrix format
  convert_results_to_matrix(results, blueprint)
}

#' Evaluate a single cell
#'
#' Internal function to evaluate one cell. Exported for use in
#' parallel clusters.
#'
#' @param blueprint Table1Blueprint object
#' @param key Cell key (format: "r1_c1")
#'
#' @return List with cell position and evaluated content
#'
#' @keywords internal
evaluate_single_cell <- function(blueprint, key) {
  # Parse key to get position
  parts <- strsplit(key, "_")[[1]]
  if (length(parts) != 2) {
    return(list(row = NA, col = NA, content = ""))
  }

  row_idx <- as.integer(sub("r", "", parts[1]))
  col_idx <- as.integer(sub("c", "", parts[2]))

  if (is.na(row_idx) || is.na(col_idx)) {
    return(list(row = NA, col = NA, content = ""))
  }

  # Get cell
  cell <- blueprint$cells[[key]]
  if (is.null(cell)) {
    return(list(row = row_idx, col = col_idx, content = ""))
  }

  # Evaluate cell (simplified - actual code more complex)
  content <- tryCatch(
    {
      if (is.null(cell$content)) {
        ""
      } else {
        as.character(cell$content)
      }
    },
    error = function(e) "[Error]"
  )

  list(row = row_idx, col = col_idx, content = content)
}

#' Convert parallel results to matrix
#'
#' Takes results from parallel/serial evaluation and converts
#' to matrix format for rendering.
#'
#' @param results List of cell results
#' @param blueprint Table1Blueprint object
#'
#' @return Matrix with evaluated cell contents
#'
#' @keywords internal
convert_results_to_matrix <- function(results, blueprint) {
  # Create matrix
  matrix_content <- matrix("", nrow = blueprint$nrows, ncol = blueprint$ncols)

  # Fill matrix from results
  for (result in results) {
    if (!is.na(result$row) && !is.na(result$col)) {
      if (result$row >= 1 && result$row <= blueprint$nrows &&
          result$col >= 1 && result$col <= blueprint$ncols) {
        matrix_content[result$row, result$col] <- result$content
      }
    }
  }

  # Convert to data frame
  as.data.frame(matrix_content, stringsAsFactors = FALSE)
}

#' Get parallel processing statistics
#'
#' Provides information about parallel processing capabilities
#' and configuration.
#'
#' @return List with parallel processing information
#'
#' @keywords internal
get_parallel_stats <- function() {
  list(
    available = requireNamespace("parallel", quietly = TRUE),
    detected_cores = detect_cores(),
    platform = .Platform$OS.type,
    can_use_parallel = requireNamespace("parallel", quietly = TRUE) && detect_cores() > 1
  )
}

#' Estimate speedup from parallel processing
#'
#' Estimates the potential speedup for a given number of cells.
#' Takes into account parallel overhead and diminishing returns.
#'
#' @param num_cells Number of cells to process
#' @param num_cores Number of cores available
#'
#' @return Estimated speedup factor (1.0 = no benefit, 2.0 = 2x faster)
#'
#' @keywords internal
estimate_parallel_speedup <- function(num_cells, num_cores = NULL) {
  if (is.null(num_cores)) {
    num_cores <- detect_cores()
  }

  if (num_cores <= 1) {
    return(1.0)
  }

  # Overhead estimate: ~100 cells
  overhead_cells <- 100

  # Useful cells = total - overhead
  useful_cells <- max(0, num_cells - overhead_cells)

  # Efficiency decreases with more cores (diminishing returns)
  # With perfect parallelization: speedup = num_cores
  # But we lose some efficiency: multiply by 0.8-0.9
  theoretical_speedup <- num_cores * 0.85

  # If we don't have enough useful cells, speedup is lower
  if (useful_cells < num_cores * 100) {
    theoretical_speedup <- theoretical_speedup * (useful_cells / (num_cores * 100))
  }

  # Cap at theoretical maximum
  min(theoretical_speedup, num_cores)
}

#' Benchmark parallel vs serial processing
#'
#' Runs a quick benchmark to determine if parallel processing
#' would be beneficial for the current system.
#'
#' @param num_test_cells Number of test cells (default: 1000)
#'
#' @return List with benchmark results
#'
#' @keywords internal
benchmark_parallel <- function(num_test_cells = 1000) {
  if (!requireNamespace("parallel", quietly = TRUE)) {
    return(list(
      available = FALSE,
      reason = "parallel package not installed"
    ))
  }

  num_cores <- detect_cores()
  if (num_cores <= 1) {
    return(list(
      available = FALSE,
      reason = "only 1 core available",
      cores = num_cores
    ))
  }

  # Quick benchmark
  test_data <- list(row = 1, col = 1, content = "test")

  # Serial benchmark
  serial_time <- system.time({
    for (i in 1:100) {
      lapply(1:100, function(x) test_data)
    }
  })[3]

  # Parallel benchmark (if available)
  parallel_time <- tryCatch(
    {
      system.time({
        parallel::mclapply(
          1:100,
          function(x) test_data,
          mc.cores = num_cores
        )
      })[3]
    },
    error = function(e) NA
  )

  list(
    available = TRUE,
    cores = num_cores,
    serial_time = serial_time,
    parallel_time = parallel_time,
    speedup = if (!is.na(parallel_time)) serial_time / parallel_time else NA,
    recommended = !is.na(parallel_time) && parallel_time < serial_time
  )
}
