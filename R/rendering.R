# ============================================================================
# Output Format Rendering System
# ============================================================================
#
# Multi-format rendering for console, LaTeX, HTML, and other outputs
#

#' Base Rendering Pipeline (Format-Agnostic)
#'
#' Internal function that provides the common rendering flow for all formats.
#' Handles theme resolution, headers, table content, and footnotes.
#'
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration (optional) - will be resolved if character
#' @param format Output format ("console", "latex", "html", etc.)
#' @param default_theme Default theme name if none specified
#' @return Character vector with rendered output
#'
#' @keywords internal
render_pipeline <- function(blueprint, theme = NULL, format, default_theme = "console") {
  # Validate input
  if (!inherits(blueprint, "table1_blueprint")) {
    stop("First argument must be a table1_blueprint", call. = FALSE)
  }

  # Resolve theme
  if (is.null(theme)) {
    theme <- get_theme(default_theme)
  } else if (is.character(theme)) {
    theme <- get_theme(theme)
  }

  # Initialize output
  output_lines <- character(0)

  # Step 1: Add title/header if present
  if (!is.null(blueprint$metadata$title)) {
    output_lines <- c(output_lines, blueprint$metadata$title, "")
  }

  # Step 2: Format-specific setup (LaTeX packages, HTML tags, etc.)
  setup_lines <- get_format_setup(theme, format)
  if (length(setup_lines) > 0) {
    output_lines <- c(output_lines, setup_lines, "")
  }

  # Step 3: Add table headers with footnote markers
  header_lines <- render_table_headers(blueprint, theme, format)
  if (length(header_lines) > 0) {
    output_lines <- c(output_lines, header_lines)
  }

  # Step 4: Render table content (lazy evaluation of cells)
  table_lines <- render_table_content(blueprint, theme, format)
  if (length(table_lines) > 0) {
    output_lines <- c(output_lines, table_lines)
  }

  # Step 5: Add footnotes if present
  footnote_lines <- render_footnotes(blueprint, theme, format)
  if (length(footnote_lines) > 0) {
    output_lines <- c(output_lines, footnote_lines)
  }

  # Step 6: Format-specific cleanup (closing tags, etc.)
  cleanup_lines <- get_format_cleanup(theme, format)
  if (length(cleanup_lines) > 0) {
    output_lines <- c(output_lines, cleanup_lines)
  }

  output_lines
}

#' Get format-specific setup lines
#'
#' @param theme Theme configuration
#' @param format Output format
#' @return Character vector with setup commands
#'
#' @keywords internal
get_format_setup <- function(theme, format) {
  switch(format,
    "latex" = generate_latex_theme_setup(theme),
    "html" = character(0),  # HTML setup handled in render_html
    "console" = character(0),
    character(0)
  )
}

#' Get format-specific cleanup lines
#'
#' @param theme Theme configuration
#' @param format Output format
#' @return Character vector with cleanup commands
#'
#' @keywords internal
get_format_cleanup <- function(theme, format) {
  # Cleanup is typically handled at end of render_* functions
  character(0)
}

#' Render Table Headers (Format-Agnostic)
#'
#' Renders column headers with proper footnote markers for the specified format.
#'
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration
#' @param format Output format
#' @return Character vector with rendered headers
#'
#' @keywords internal
render_table_headers <- function(blueprint, theme, format) {
  if (length(blueprint$col_names) == 0) {
    return(character(0))
  }

  # Apply footnote markers to column names
  col_headers <- character(length(blueprint$col_names))
  for (i in seq_along(blueprint$col_names)) {
    col_name <- blueprint$col_names[i]
    marker_key <- paste0("col_", col_name)
    col_headers[i] <- apply_footnote_marker(col_name, marker_key,
                                           blueprint$metadata$footnote_markers,
                                           format)
  }

  # Format headers based on output format
  switch(format,
    "latex" = {
      formatted_headers <- apply_latex_header_formatting(col_headers, theme)
      header_line <- paste0(paste(formatted_headers, collapse = " & "), " \\\\")

      # Add middle rule after headers
      mid_rule <- get_latex_rule(theme, "middle")
      c(header_line, mid_rule)
    },
    "html" = {
      header_cells <- paste0("  <th>", col_headers, "</th>")
      header_line <- paste0("<tr>\n", paste(header_cells, collapse = "\n"), "\n</tr>")
      c(header_line)
    },
    "console" = {
      # Console headers are handled by render_table_content
      character(0)
    },
    character(0)
  )
}

#' Render Blueprint to Console
#'
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration (optional)
#' @return Character vector for console output
#' @export
render_console <- function(blueprint, theme = NULL) {
  render_pipeline(blueprint, theme, "console", default_theme = "console")
}

#' Render Blueprint to LaTeX
#'
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration (optional)
#' @return Character vector with LaTeX code
#' @export
render_latex <- function(blueprint, theme = NULL) {
  if (!inherits(blueprint, "table1_blueprint")) {
    stop("First argument must be a table1_blueprint", call. = FALSE)
  }

  if (is.null(theme)) {
    theme <- get_theme("nejm") # Default to journal theme for LaTeX
  } else if (is.character(theme)) {
    theme <- get_theme(theme)
  }

  # Check for footnotes (needed for threeparttable)
  has_footnotes <- !is.null(blueprint$metadata$footnote_list) &&
                   length(blueprint$metadata$footnote_list) > 0

  output_lines <- character(0)

  # Use pipeline for common rendering
  pipeline_output <- render_pipeline(blueprint, theme, "latex", "nejm")
  output_lines <- c(output_lines, pipeline_output)

  # Insert LaTeX table environment setup (before headers if added by pipeline)
  # Find where pipeline output ends before headers
  col_spec <- generate_latex_column_spec(blueprint$ncols, theme)
  table_env <- get_latex_table_environment(theme)

  # Handle threeparttable wrapping
  if (has_footnotes) {
    output_lines <- c("\\begin{threeparttable}", output_lines)
  }

  # Insert table environment start after title (if present)
  title_end <- if (!is.null(blueprint$metadata$title)) 1 else 0
  table_start <- paste0("\\begin{", table_env, "}{", col_spec, "}")
  top_rule <- get_latex_rule(theme, "top")

  output_lines <- c(
    output_lines[1:title_end],
    table_start,
    top_rule,
    output_lines[(title_end + 1):length(output_lines)]
  )

  # Add bottom rule before table end
  bottom_rule <- get_latex_rule(theme, "bottom")
  output_lines <- c(output_lines, bottom_rule, paste0("\\end{", table_env, "}"))

  # Close threeparttable if opened
  if (has_footnotes) {
    output_lines <- c(output_lines, "\\end{threeparttable}")
  }

  output_lines
}

# NOTE: LaTeX helper functions have been consolidated to avoid duplication.
# See lines 759-865 for the unified theme-aware implementations.
# The simple versions that were here have been removed to eliminate code duplication.

#' Render table content based on output format
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration
#' @param format Output format ("console", "latex", "html")
#' @return Character vector with formatted table content
render_table_content <- function(blueprint, theme, format) {
  if (format == "latex") {
    render_table_content_latex(blueprint, theme)
  } else if (format == "html") {
    render_table_content_html(blueprint, theme)
  } else {
    render_table_content_console(blueprint, theme)
  }
}

#' Render table content for LaTeX with theme-specific styling
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration
#' @return Character vector with LaTeX table rows
render_table_content_latex <- function(blueprint, theme) {
  content_lines <- character(0)
  
  # Use the blueprint's built-in cell access and evaluation
  for (row_idx in 1:blueprint$nrows) {
    row_data <- character(blueprint$ncols)
    row_type <- "data" # Default row type
    
    # Extract data for each cell in the row using blueprint accessor
    for (col_idx in 1:blueprint$ncols) {
      cell_content <- ""
      
      # Use blueprint's [] accessor to get cell
      cell <- blueprint[row_idx, col_idx]
      if (!is.null(cell) && !is.null(cell$content)) {
        cell_content <- as.character(cell$content)
      } else {
        # Fallback to row/column names for structure
        if (col_idx == 1 && row_idx <= length(blueprint$row_names)) {
          cell_content <- blueprint$row_names[row_idx]
          # Detect if this is a factor level (starts with spaces or dashes)
          if (grepl("^\\s+|^-", cell_content)) {
            row_type <- "factor_level"
          }
        } else if (row_idx == 1 && col_idx <= length(blueprint$col_names)) {
          cell_content <- blueprint$col_names[col_idx]
          row_type <- "header"
        }
      }
      
      row_data[col_idx] <- cell_content
    }
    
    # Apply theme-specific row formatting with striping
    row_line <- format_latex_table_row(row_data, row_idx, theme, row_type)
    if (length(row_line) > 0) {
      content_lines <- c(content_lines, row_line)
    }
  }
  
  content_lines
}

#' Format a LaTeX table row with theme-specific styling
#' @param row_data Character vector of cell values
#' @param row_index Row number (for striping)
#' @param theme Theme configuration  
#' @param row_type Type of row ("data", "factor_level", "header")
#' @return Character string with formatted LaTeX row
format_latex_table_row <- function(row_data, row_index, theme, row_type = "data") {
  if (length(row_data) == 0 || all(row_data == "")) {
    return(character(0))
  }
  
  # Apply factor level indentation
  if (row_type == "factor_level") {
    row_data[1] <- paste0("\\indent{", gsub("^\\s+|^-\\s*", "", row_data[1]), "}")
  }
  
  # Escape LaTeX special characters
  row_data <- sapply(row_data, function(x) {
    x <- gsub("&", "\\\\&", x)
    x <- gsub("%", "\\\\%", x)
    x <- gsub("\\$", "\\\\\\$", x)
    x <- gsub("_", "\\\\_", x)
    x <- gsub("\\^", "\\\\textasciicircum{}", x)
    return(x)
  })
  
  # Create basic row
  row_line <- paste0(paste(row_data, collapse = " & "), " \\\\")
  
  # Apply theme-specific row formatting
  theme_name <- theme$theme_name %||% theme$name %||% "console"
  
  if (theme_name == "nejm" || theme_name == "New England Journal of Medicine") {
    # NEJM theme: alternating row colors using rowcolor directly
    if (row_index %% 2 == 0) {
      row_line <- paste0("\\rowcolor{nejmstripe} ", row_line)
    }
  }
  
  return(row_line)
}

#' Placeholder for console content rendering
render_table_content_console <- function(blueprint, theme) {
  # Simplified placeholder - would need full implementation
  character(0)
}

#' Placeholder for HTML content rendering
render_table_content_html <- function(blueprint, theme) {
  # Simplified placeholder - would need full implementation
  character(0)
}

# Placeholder footnote function removed - see actual implementation below

#' Render Blueprint to HTML
#'
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration (optional)
#' @return Character vector with HTML code
#' @export
render_html <- function(blueprint, theme = NULL) {
  if (!inherits(blueprint, "table1_blueprint")) {
    stop("First argument must be a table1_blueprint", call. = FALSE)
  }

  if (is.null(theme)) {
    # Use theme from blueprint if available, otherwise default to console
    theme <- blueprint$metadata$theme %||% get_theme("console")
  } else if (is.character(theme)) {
    theme <- get_theme(theme)
  }

  # Get HTML table CSS class
  css_class <- if (!is.null(theme$css_class)) {
    paste("table1", theme$css_class)
  } else {
    "table1"
  }

  # Start with opening table tag
  output_lines <- c(paste0("<table class=\"", css_class, "\">"))

  # Use pipeline for content (headers, content, footnotes)
  pipeline_output <- render_pipeline(blueprint, theme, "html", "console")

  # Combine and close table
  output_lines <- c(output_lines, pipeline_output, "</table>")

  output_lines
}

#' Render Table Content (Optimized)
#'
#' Optimized rendering logic that iterates over existing cells rather than
#' all possible grid positions. This is much more efficient for the sparse
#' tables generated by this package.
#'
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration
#' @param format Output format (console, latex, html)
#' @return Character vector with table content
render_table_content <- function(blueprint, theme, format) {
  # 1. Pre-allocate a matrix to hold evaluated cell content.
  content_matrix <- matrix("", nrow = blueprint$nrows, ncol = blueprint$ncols)

  # 2. Get all existing cell keys once.
  cell_keys <- ls(blueprint$cells, all.names = TRUE)

  # 3. Iterate over existing cells, evaluate them, and place content in the matrix.
  #    This avoids iterating over millions of empty cells in large, sparse tables.
  for (key in cell_keys) {
    pos <- parse_cell_key(key)
    if (is.na(pos$row) || is.na(pos$col)) next # Skip invalid keys

    cell <- blueprint$cells[[key]]
    content <- evaluate_cell(cell, blueprint$metadata$data, blueprint = blueprint)
    content <- format_cell_content(content, theme, cell$type)
    content <- format_content_for_output(content, format, pos$row, pos$col, theme)

    content_matrix[pos$row, pos$col] <- content
  }

  # 4. Efficiently format the pre-populated matrix into output lines.
  #    Pre-allocating the list is much faster than growing a vector with c().
  output_lines <- vector("list", blueprint$nrows)
  for (i in 1:blueprint$nrows) {
    output_lines[[i]] <- combine_row_content(content_matrix[i, ], format, theme, i)
  }

  # Add separators if needed (after initial lines are generated)
  if (format == "console" && blueprint$nrows > 0 && !is.null(theme$header_separator)) {
    # Calculate width based on the header row for accurate alignment
    header_width <- nchar(output_lines[[1]])
    sep_line <- strrep(theme$header_separator, header_width)
    # Insert the separator line after the header
    final_lines <- c(output_lines[[1]], sep_line, unlist(output_lines[-1], use.names = FALSE))
    return(final_lines)
  }

  return(unlist(output_lines, use.names = FALSE))
}

#' Format Content for Output Format
#' @param content Cell content
#' @param format Output format
#' @param row Row number
#' @param col Column number
#' @param theme Theme configuration
#' @return Formatted content
format_content_for_output <- function(content, format, row, col, theme) {
  switch(format,
    "console" = content, # Already formatted by theme
    "latex" = escape_latex(content),
    "html" = escape_html(content),
    content
  )
}

#' Combine Row Content
#' @param row_content Character vector of cell contents
#' @param format Output format
#' @param theme Theme configuration
#' @return Single character string for the row
combine_row_content <- function(row_content, format, theme, row_index = 1) {
  switch(format,
    "console" = {
      # Pad columns to align properly
      max_widths <- pmax(nchar(row_content), 8) # Minimum 8 chars per column
      formatted <- mapply(function(content, width) {
        format(content, width = width, justify = "left")
      }, row_content, max_widths)
      paste(formatted, collapse = "  ")
    },
    "latex" = {
      # Apply factor level indentation to first column if it has leading spaces
      if (length(row_content) > 0 && grepl("^\\s+", row_content[1])) {
        # This is a factor level - apply indentation
        clean_content <- gsub("^\\s+", "", row_content[1])
        row_content[1] <- paste0("\\hspace{1em}", clean_content)
      }
      
      # Create basic row
      row_line <- paste0(paste(row_content, collapse = " & "), " \\\\")
      
      # Apply theme-specific row formatting (striping)
      theme_name <- theme$theme_name %||% theme$name %||% "console"
      
      if (theme_name == "nejm" || theme_name == "New England Journal of Medicine") {
        # NEJM theme: alternating row colors
        if (row_index %% 2 == 0) {
          row_line <- paste0("\\rowcolor{nejmstripe} ", row_line)
        }
      }
      
      row_line
    },
    "html" = {
      # Add CSS classes for indentation using theme settings
      variable_indent <- theme$variable_indent %||% 2
      level_indent <- theme$level_indent %||% 4
      
      cells <- character(length(row_content))
      for (i in seq_along(row_content)) {
        content <- row_content[i]
        css_class <- ""
        
        # For first column, add CSS class based on leading spaces and theme settings
        if (i == 1) {
          leading_spaces <- nchar(content) - nchar(sub("^\\s+", "", content))
          content_text <- trimws(content)
          
          if (leading_spaces == variable_indent) {
            css_class <- ' class="table1-indent-variable"'
          } else if (leading_spaces == level_indent) {
            css_class <- ' class="table1-indent-level"'
          }
          
          content <- content_text
        }
        
        cells[i] <- paste0("  <td", css_class, ">", content, "</td>")
      }
      paste0("<tr>\n", paste(cells, collapse = "\n"), "\n</tr>")
    },
    paste(row_content, collapse = "\t") # Default: tab-separated
  )
}

#' Render Footnotes
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration
#' @param format Output format
#' @return Character vector with footnotes
render_footnotes <- function(blueprint, theme, format) {
  if (is.null(blueprint$metadata$footnote_list) || length(blueprint$metadata$footnote_list) == 0) {
    return(character(0))
  }

  footnotes <- blueprint$metadata$footnote_list
  markers <- blueprint$metadata$footnote_markers
  output_lines <- character(0)

  # Determine which footnotes have markers (variable/column) vs general
  n_with_markers <- length(markers)
  
  switch(format,
    "console" = {
      output_lines <- c(output_lines, "Footnotes:")
      
      # First, numbered footnotes (those with markers)
      if (n_with_markers > 0) {
        for (i in 1:min(n_with_markers, length(footnotes))) {
          output_lines <- c(output_lines, paste0(i, ". ", footnotes[[i]]))
        }
      }
      
      # Then, general footnotes (no numbers, just bullets or dashes)
      if (length(footnotes) > n_with_markers) {
        for (i in (n_with_markers + 1):length(footnotes)) {
          output_lines <- c(output_lines, paste0("• ", footnotes[[i]]))
        }
      }
    },
    "latex" = {
      if (length(footnotes) > 0) {
        output_lines <- c(output_lines, "\\begin{tablenotes}")
        output_lines <- c(output_lines, "\\small")
        
        # Numbered footnotes
        if (n_with_markers > 0) {
          for (i in 1:min(n_with_markers, length(footnotes))) {
            output_lines <- c(output_lines, paste0("\\item[", i, "] ", escape_latex(footnotes[[i]])))
          }
        }
        
        # General footnotes without numbers
        if (length(footnotes) > n_with_markers) {
          for (i in (n_with_markers + 1):length(footnotes)) {
            output_lines <- c(output_lines, paste0("\\item[\\textbullet] ", escape_latex(footnotes[[i]])))
          }
        }
        
        output_lines <- c(output_lines, "\\end{tablenotes}")
      }
    },
    "html" = {
      output_lines <- c(output_lines, "<div class=\"footnotes\">")
      
      # Numbered footnotes 
      if (n_with_markers > 0) {
        for (i in 1:min(n_with_markers, length(footnotes))) {
          output_lines <- c(output_lines, paste0("<p><sup>", i, "</sup> ", footnotes[[i]], "</p>"))
        }
      }
      
      # General footnotes without numbers
      if (length(footnotes) > n_with_markers) {
        for (i in (n_with_markers + 1):length(footnotes)) {
          output_lines <- c(output_lines, paste0("<p>• ", footnotes[[i]], "</p>"))
        }
      }
      
      output_lines <- c(output_lines, "</div>")
    }
  )

  output_lines
}

#' Escape LaTeX Special Characters
#' @param text Character string
#' @return LaTeX-escaped string
escape_latex <- function(text) {
  if (!is.character(text)) {
    # Handle special cases
    if (is.function(text)) {
      return("[Function]")
    }
    if (is.null(text)) {
      return("")
    }
    # Try to convert to character safely
    return(tryCatch(as.character(text), error = function(e) "[Error]"))
  }

  # Standard LaTeX escaping (except $, which we'll use for math)
  text <- gsub("\\", "\\textbackslash{}", text, fixed = TRUE)
  text <- gsub("{", "\\{", text, fixed = TRUE)
  text <- gsub("}", "\\}", text, fixed = TRUE)
  
  # Handle Unicode characters with math mode (after other escaping, before $ escaping)
  text <- gsub("±", "$\\pm$", text, fixed = TRUE)          # Plus-minus symbol
  text <- gsub("×", "$\\times$", text, fixed = TRUE)       # Multiplication symbol  
  text <- gsub("•", "$\\bullet$", text, fixed = TRUE)      # Bullet symbol
  text <- gsub("⋅", "$\\cdot$", text, fixed = TRUE)        # Dot operator
  
  # Now escape remaining $ symbols (but not the ones we just added for math)
  # This is tricky - let's use a placeholder approach
  text <- gsub("$\\pm$", "PMPLACEHOLDER", text, fixed = TRUE)
  text <- gsub("$\\times$", "TIMESPLACEHOLDER", text, fixed = TRUE)
  text <- gsub("$\\bullet$", "BULLETPLACEHOLDER", text, fixed = TRUE)
  text <- gsub("$\\cdot$", "CDOTPLACEHOLDER", text, fixed = TRUE)
  
  text <- gsub("$", "\\$", text, fixed = TRUE)
  
  # Restore math mode
  text <- gsub("PMPLACEHOLDER", "$\\pm$", text, fixed = TRUE)
  text <- gsub("TIMESPLACEHOLDER", "$\\times$", text, fixed = TRUE)
  text <- gsub("BULLETPLACEHOLDER", "$\\bullet$", text, fixed = TRUE)
  text <- gsub("CDOTPLACEHOLDER", "$\\cdot$", text, fixed = TRUE)
  text <- gsub("&", "\\&", text, fixed = TRUE)
  text <- gsub("%", "\\%", text, fixed = TRUE)
  text <- gsub("#", "\\#", text, fixed = TRUE)
  text <- gsub("^", "\\textasciicircum{}", text, fixed = TRUE)
  text <- gsub("_", "\\_", text, fixed = TRUE)
  text <- gsub("~", "\\textasciitilde{}", text, fixed = TRUE)

  text
}

#' Escape HTML Special Characters
#' @param text Character string
#' @return HTML-escaped string
escape_html <- function(text) {
  if (!is.character(text)) {
    # Handle special cases
    if (is.function(text)) {
      return("[Function]")
    }
    if (is.null(text)) {
      return("")
    }
    # Try to convert to character safely
    return(tryCatch(as.character(text), error = function(e) "[Error]"))
  }

  # First, preserve allowed HTML tags by temporarily replacing them with placeholders
  text <- gsub("<sup>", "§SUP_START§", text, fixed = TRUE)
  text <- gsub("</sup>", "§SUP_END§", text, fixed = TRUE)
  
  # Now escape general HTML characters
  text <- gsub("&", "&amp;", text, fixed = TRUE)
  text <- gsub("<", "&lt;", text, fixed = TRUE)
  text <- gsub(">", "&gt;", text, fixed = TRUE)
  text <- gsub("\"", "&quot;", text, fixed = TRUE)
  text <- gsub("'", "&#39;", text, fixed = TRUE)
  
  # Restore the allowed HTML tags
  text <- gsub("§SUP_START§", "<sup>", text, fixed = TRUE)
  text <- gsub("§SUP_END§", "</sup>", text, fixed = TRUE)

  text
}

#' Display Blueprint as Formatted Table
#'
#' Convenience function that evaluates the blueprint and displays it as
#' a nicely formatted table. This provides the "Table 1" output that
#' users expect.
#'
#' @param blueprint A table1_blueprint object
#' @param data Data frame containing the source data
#' @param format Output format ("console", "latex", "html")
#' @param ... Additional arguments passed to print methods
#'
#' @return Invisibly returns the rendered output
#'
#' @examples
#' \dontrun{
#' data(mtcars)
#' mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Auto"))
#' blueprint <- table1_nextgen(transmission ~ mpg + hp, data = mtcars)
#' display_table(blueprint, mtcars)
#' }
#'
#' @export
display_table <- function(blueprint, data, format = "console", ...) {
  if (!inherits(blueprint, "table1_blueprint")) {
    stop("First argument must be a table1_blueprint object", call. = FALSE)
  }

  if (!is.data.frame(data)) {
    stop("Data must be a data frame", call. = FALSE)
  }

  # Store data in metadata if not already there
  if (is.null(blueprint$metadata$data)) {
    blueprint$metadata$data <- data
  }

  # Render based on format
  output <- switch(format,
    "console" = render_console(blueprint),
    "latex" = render_latex(blueprint),
    "html" = render_html(blueprint),
    stop("Unknown format: ", format, call. = FALSE)
  )

  # Display output
  cat(paste(output, collapse = "\n"))
  cat("\n")

  invisible(output)
}

#' Generate LaTeX Theme Setup
#'
#' @param theme Theme configuration
#' @return Character vector with LaTeX setup commands
generate_latex_theme_setup <- function(theme) {
  # For R Markdown, we should not include preamble commands in the body
  # These should be handled through the YAML header instead
  setup_lines <- character(0)
  
  # Get theme name from either theme_name or name field
  theme_name <- theme$theme_name %||% theme$name %||% "console"
  
  if (theme_name == "nejm" || theme_name == "New England Journal of Medicine") {
    setup_lines <- c(setup_lines,
      "% NEJM theme colors and formatting",
      "\\definecolor{nejmstripe}{HTML}{fefcf0}",
      "\\definecolor{nejmtext}{HTML}{333333}"
    )
  } else if (theme_name == "lancet" || theme_name == "The Lancet") {
    setup_lines <- c(setup_lines,
      "% Lancet theme formatting"
    )
  } else if (theme_name == "jama" || theme_name == "JAMA") {
    setup_lines <- c(setup_lines,
      "% JAMA theme formatting"
    )
  }
  
  return(setup_lines)
}

#' Generate LaTeX Column Specification
#'
#' @param ncols Number of columns
#' @param theme Theme configuration
#' @return Character string with column specification
generate_latex_column_spec <- function(ncols, theme) {
  # Different themes might prefer different column alignments
  switch(theme$theme_name,
    "console" = paste0("l", strrep("r", ncols - 1)), # Console: left + right-aligned
    "nejm" = paste0("l", strrep("c", ncols - 1)),    # NEJM: left + centered
    "lancet" = paste0("l", strrep("c", ncols - 1)),  # Lancet: left + centered
    "jama" = paste0("l", strrep("c", ncols - 1)),    # JAMA: left + centered  
    "bmj" = paste0("l", strrep("c", ncols - 1)),     # BMJ: left + centered
    paste0("l", strrep("c", ncols - 1)) # Default: left + centered
  )
}

#' Get LaTeX Table Environment
#'
#' @param theme Theme configuration
#' @return Character string with table environment name
get_latex_table_environment <- function(theme) {
  # Different themes might use different table environments
  switch(theme$theme_name,
    "console" = "tabular",
    "nejm" = "tabular",
    "lancet" = "tabular", 
    "jama" = "tabular",
    "bmj" = "tabular",
    "tabular" # Default
  )
}

#' Get LaTeX Rule Command
#'
#' @param theme Theme configuration
#' @param position Rule position ("top", "middle", "bottom")
#' @return Character string with LaTeX rule command
get_latex_rule <- function(theme, position = "middle") {
  # Different themes use different rule styles
  switch(theme$theme_name,
    "console" = {
      switch(position,
        "top" = "\\hline",
        "middle" = "\\hline", 
        "bottom" = "\\hline",
        "\\hline"
      )
    },
    "nejm" = {
      switch(position,
        "top" = "\\toprule",
        "middle" = "\\midrule",
        "bottom" = "\\bottomrule",
        "\\midrule"
      )
    },
    "lancet" = {
      switch(position,
        "top" = "\\toprule",
        "middle" = "\\midrule", 
        "bottom" = "\\bottomrule",
        "\\midrule"
      )
    },
    "jama" = {
      switch(position,
        "top" = "\\toprule",
        "middle" = "\\midrule",
        "bottom" = "\\bottomrule", 
        "\\midrule"
      )
    },
    "bmj" = {
      switch(position,
        "top" = "\\hline\\hline", # Double line for BMJ
        "middle" = "\\hline",
        "bottom" = "\\hline\\hline",
        "\\hline"
      )
    },
    # Default
    switch(position,
      "top" = "\\toprule",
      "middle" = "\\midrule", 
      "bottom" = "\\bottomrule",
      "\\midrule"
    )
  )
}

#' Apply LaTeX Header Formatting
#'
#' @param headers Character vector of header names
#' @param theme Theme configuration
#' @return Character vector with formatted headers
apply_latex_header_formatting <- function(headers, theme) {
  # Different themes might apply different header formatting
  switch(theme$theme_name,
    "console" = headers, # No special formatting for console
    "nejm" = paste0("\\textbf{", headers, "}"), # Bold for NEJM
    "lancet" = paste0("\\textbf{", headers, "}"), # Bold for Lancet
    "jama" = paste0("\\textbf{", headers, "}"), # Bold for JAMA
    "bmj" = paste0("\\textbf{", headers, "}"), # Bold for BMJ
    headers # Default: no formatting
  )
}

#' Convert Blueprint to Data Frame
#'
#' Converts a table1_blueprint to a data frame for further processing
#'
#' @param x A table1_blueprint object
#' @param row.names Row names (ignored)
#' @param optional Logical (ignored)
#' @param ... Additional arguments (ignored)
#'
#' @return Data frame with evaluated cell contents
#' @export
as.data.frame.table1_blueprint <- function(x, row.names = NULL, optional = FALSE, ...) {
  # Get data from blueprint metadata
  data <- x$metadata$data
  if (is.null(data)) {
    stop("Data not available in blueprint metadata", call. = FALSE)
  }

  # Create result data frame
  result_df <- data.frame(matrix("", nrow = x$nrows, ncol = x$ncols),
    stringsAsFactors = FALSE
  )

  # Set column names
  if (length(x$col_names) > 0) {
    names(result_df) <- x$col_names
  } else {
    names(result_df) <- paste0("V", 1:x$ncols)
  }

  # Evaluate each cell
  for (i in 1:x$nrows) {
    for (j in 1:x$ncols) {
      cell <- x[i, j]
      if (!is.null(cell)) {
        result_df[i, j] <- as.character(evaluate_cell(cell, data, blueprint = x))
      }
    }
  }

  # Set row names if available
  if (length(x$row_names) == x$nrows) {
    rownames(result_df) <- x$row_names
  }

  return(result_df)
}
