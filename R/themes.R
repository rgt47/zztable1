# ============================================================================
# Simplified Theme System
# ============================================================================

# Simple theme storage
.theme_list <- list(
  console = list(
    name = "Console",
    padding = 2,
    decimal_places = 1,
    css_class = "table1-console",
    # Indentation and separator settings
    variable_indent = 2,
    level_indent = 4,
    stratum_separator = "text",  # "text", "line", "space", or "none"
    factor_separator = "text",   # "text", "line", "space", or "none"
    
    # NEW: Dimension-affecting rules
    dimension_rules = list(
      factor_separator = "text",           # text|space|line|none
      stratum_separator = "text",          # text|space|line|none  
      variable_grouping = "compact",       # compact|spaced|separated
      missing_presentation = "inline",     # inline|separate_row|footnote
      summary_style = "combined",          # combined|split_rows
      footnote_style = "numbered",         # numbered|lettered|symbol
      strip_empty_rows = FALSE,            # Remove empty factor level rows
      factor_level_grouping = "indented"   # flat|nested|indented
    ),
    
    css_properties = list(
      background_color = "#f8f9fa",
      border_color = "#dee2e6",
      font_family = "'Consolas', 'Monaco', monospace",
      font_size = "14px"
    )
  ),
  nejm = list(
    name = "New England Journal of Medicine",
    padding = 0,
    decimal_places = 1,
    css_class = "table1-nejm",
    # NEJM style: minimal indentation, clean horizontal lines only
    variable_indent = 0,     # No indentation - clean, flat structure
    level_indent = 1,       # Minimal indentation for factor levels
    stratum_separator = "line",  # horizontal line between strata
    factor_separator = "none",   # no separator between factors  
    
    # NEJM-specific dimension rules
    dimension_rules = list(
      factor_separator = "none",           # No separators between factors
      stratum_separator = "line",          # Horizontal lines between strata
      variable_grouping = "compact",       # Compact layout like NEJM
      missing_presentation = "inline",     # Missing values shown inline
      summary_style = "combined",          # mean ± SD format
      footnote_style = "numbered",         # Numbered footnotes
      strip_empty_rows = TRUE,             # Remove empty factor level rows
      factor_level_grouping = "flat"       # Flat structure, minimal nesting
    ),
    
    # Rendering rules for NEJM format
    rendering_rules = list(
      format_numeric = function(x, digits = 1) {
        paste0(round(mean(x, na.rm=TRUE), digits), " ± ", round(sd(x, na.rm=TRUE), digits))
      },
      format_categorical = function(x, total = NULL) {
        n <- length(x)
        if (is.null(total)) total <- n
        paste0(n, " (", round(100*n/total, 1), ")")
      },
      header_style = "bold",
      stripe_rows = TRUE
    ),
    
    css_properties = list(
      background_color = "#ffffff",
      stripe_color = "#fefcf0",    # Light yellow/cream stripe like actual NEJM tables
      border_color = "transparent", 
      font_family = "'Arial', Helvetica, sans-serif",
      font_size = "10px",          # Smaller font like actual NEJM tables
      line_height = "1.2"          # Tighter line spacing
    )
  ),
  lancet = list(
    name = "The Lancet",
    padding = 0,
    decimal_places = 1,
    css_class = "table1-lancet",
    # Lancet style: clean minimal formatting like actual Lancet tables
    variable_indent = 2,
    level_indent = 3,
    stratum_separator = "space",  # blank row between strata
    factor_separator = "space",   # blank row between factors
    
    # Lancet-specific dimension rules
    dimension_rules = list(
      factor_separator = "space",          # Blank rows between factors
      stratum_separator = "space",         # Blank rows between strata
      variable_grouping = "spaced",        # More generous spacing
      missing_presentation = "separate_row", # Dedicated missing value rows
      summary_style = "combined",          # mean (SD) format
      footnote_style = "lettered",         # Lettered footnotes (a,b,c)
      strip_empty_rows = FALSE,            # Keep structure visible
      factor_level_grouping = "indented"   # Clear indentation hierarchy
    ),
    
    # Rendering rules for Lancet format
    rendering_rules = list(
      format_numeric = function(x, digits = 1) {
        paste0(round(mean(x, na.rm=TRUE), digits), " (", round(sd(x, na.rm=TRUE), digits), ")")
      },
      format_categorical = function(x, total = NULL) {
        n <- length(x)
        if (is.null(total)) total <- n
        paste0(n, " (", round(100*n/total, 1), "%)")
      },
      header_style = "bold",
      stripe_rows = FALSE
    ),
    
    css_properties = list(
      background_color = "#ffffff",  # Clean white background
      border_color = "transparent",  # Minimal borders like NEJM
      font_family = "'Arial', Helvetica, sans-serif",
      font_size = "10px",
      header_background = "#ffffff"  # Clean white header
    )
  ),
  jama = list(
    name = "JAMA",
    padding = 0,
    decimal_places = 1,
    footnote_style = "lettered",
    css_class = "table1-jama",
    # JAMA style: clean minimal formatting like actual JAMA tables
    variable_indent = 2,
    level_indent = 4,
    stratum_separator = "text",  # text indicators between strata
    factor_separator = "text",   # text indicators between factors
    
    # JAMA-specific dimension rules (based on actual JAMA Neurology tables)
    dimension_rules = list(
      factor_separator = "none",           # Clean compact layout like JAMA
      stratum_separator = "text",          # Text separators for strata groups
      variable_grouping = "compact",       # Tight spacing like medical journals
      missing_presentation = "inline",     # Missing values shown inline with stats
      summary_style = "combined",          # mean (SD) format like JAMA
      footnote_style = "lettered",         # Lettered footnotes (a,b,c)
      strip_empty_rows = TRUE,             # Clean presentation
      factor_level_grouping = "indented"   # Clear hierarchy with indentation
    ),
    
    # Rendering rules for JAMA format
    rendering_rules = list(
      format_numeric = function(x, digits = 1) {
        paste0(round(mean(x, na.rm=TRUE), digits), " (", round(sd(x, na.rm=TRUE), digits), ")")
      },
      format_categorical = function(x, total = NULL) {
        n <- length(x)
        if (is.null(total)) total <- n
        paste0(n, " (", round(100*n/total, 1), ")")
      },
      header_style = "bold",
      stripe_rows = FALSE  # JAMA uses clean white tables
    ),
    
    css_properties = list(
      background_color = "#ffffff",  # Clean white background
      border_color = "transparent",  # Minimal borders like NEJM/Lancet
      font_family = "'Arial', Helvetica, sans-serif",
      font_size = "10px",
      line_height = "1.3"
    )
  ),
  simple = list(
    name = "Simple",
    padding = 1,
    decimal_places = 2,
    css_class = "table1-simple",
    # Simple style: basic indentation, line separators
    variable_indent = 2,
    level_indent = 4,
    stratum_separator = "line",  # simple line between strata
    factor_separator = "none",   # no separator between factors
    
    # Simple theme dimension rules
    dimension_rules = list(
      factor_separator = "none",           # No separators between factors
      stratum_separator = "line",          # Simple lines between strata
      variable_grouping = "compact",       # Standard spacing
      missing_presentation = "separate_row", # Dedicated missing value rows
      summary_style = "combined",          # Standard combined format
      footnote_style = "numbered",         # Numbered footnotes
      strip_empty_rows = FALSE,            # Keep all structure visible
      factor_level_grouping = "indented"   # Clear indentation
    ),
    
    # Rendering rules for simple format
    rendering_rules = list(
      format_numeric = function(x, digits = 2) {
        paste0(round(mean(x, na.rm=TRUE), digits), " (", round(sd(x, na.rm=TRUE), digits), ")")
      },
      format_categorical = function(x, total = NULL) {
        n <- length(x)
        if (is.null(total)) total <- n
        paste0(n, " (", round(100*n/total, 1), "%)")
      },
      header_style = "bold",
      stripe_rows = FALSE
    ),
    
    css_properties = list(
      background_color = "#ffffff",
      border_color = "#000000",
      font_family = "'Times', serif",
      font_size = "12px"
    )
  )
)

#' Get Theme Configuration (Simplified)
#'
#' @param theme_name Character, theme name
#' @return List with theme configuration
#' @export
get_theme <- function(theme_name = "console") {
  if (is.null(theme_name)) {
    theme_name <- "console"
  }
  
  theme <- .theme_list[[theme_name]]
  if (is.null(theme)) {
    warning("Unknown theme '", theme_name, "', using 'console'", call. = FALSE)
    theme <- .theme_list[["console"]]
  }
  
  theme$theme_name <- theme_name
  theme
}

#' Apply Theme to Blueprint
#'
#' @param blueprint Table1Blueprint object
#' @param theme Theme configuration list
#' @return Modified blueprint with theme applied
#' @export
apply_theme <- function(blueprint, theme) {
  if (!inherits(blueprint, "table1_blueprint")) {
    stop("First argument must be a table1_blueprint", call. = FALSE)
  }

  if (!is.list(theme)) {
    stop("Theme must be a list", call. = FALSE)
  }

  # Validate required theme fields
  required_fields <- c("name", "padding", "decimal_places", "css_class", 
                       "variable_indent", "level_indent", "stratum_separator", 
                       "factor_separator", "css_properties")
  missing_fields <- setdiff(required_fields, names(theme))
  if (length(missing_fields) > 0) {
    stop("Theme missing required fields: ", paste(missing_fields, collapse = ", "), call. = FALSE)
  }

  # Store theme in metadata
  if (is.null(blueprint$metadata)) {
    blueprint$metadata <- list()
  }
  blueprint$metadata$theme <- theme

  blueprint
}

#' Get Available Themes
#' @return Character vector of available theme names
#' @export
list_available_themes <- function() {
  names(.theme_list)
}

#' Null coalescing operator
`%||%` <- function(x, y) if (is.null(x)) y else x

# ============================================================================
# Theme-Aware Dimension Calculation Functions
# ============================================================================

#' Calculate theme-specific separator rows
#' @param analyses Dimension analysis results
#' @param theme Theme object with dimension_rules
#' @return Integer number of additional separator rows needed
calculate_theme_separator_rows <- function(analyses, theme) {
  separator_rows <- 0L
  
  if (is.null(theme$dimension_rules)) return(separator_rows)
  
  # Factor separators
  if (theme$dimension_rules$factor_separator == "space") {
    n_factors <- sum(analyses$variables$types == "factor")
    if (n_factors > 1) {
      separator_rows <- separator_rows + (n_factors - 1L)
    }
  }
  
  # Stratum separators  
  if (!is.null(analyses$strata)) {
    sep_type <- theme$dimension_rules$stratum_separator
    if (sep_type %in% c("space", "line")) {
      n_strata <- analyses$strata$n_strata
      if (n_strata > 1) {
        separator_rows <- separator_rows + (n_strata - 1L)
      }
    }
  }
  
  # Variable grouping separators
  if (theme$dimension_rules$variable_grouping == "separated") {
    n_vars <- length(analyses$variables$variables)
    if (n_vars > 1) {
      separator_rows <- separator_rows + (n_vars - 1L)
    }
  }
  
  separator_rows
}

#' Calculate theme-specific missing value rows  
#' @param analyses Dimension analysis results
#' @param theme Theme object with dimension_rules
#' @param missing Logical indicating if missing values should be shown
#' @return Integer number of additional missing value rows
calculate_theme_missing_rows <- function(analyses, theme, missing) {
  if (!missing || is.null(theme$dimension_rules)) return(0L)
  
  missing_style <- theme$dimension_rules$missing_presentation
  
  if (missing_style == "separate_row") {
    # Each variable with missing values gets a dedicated row
    sum(analyses$variables$missing_counts > 0)
  } else if (missing_style == "inline") {
    # No additional rows - missing shown inline with regular stats
    0L
  } else if (missing_style == "footnote") {
    # Missing values mentioned in footnotes - no extra table rows
    0L
  } else {
    # Default behavior
    sum(analyses$variables$missing_counts > 0)
  }
}

#' Format Cell Content
#'
#' @param content Cell content to format
#' @param theme Theme configuration 
#' @param cell_type Cell type for formatting
#' @return Formatted content string
#' @export
format_cell_content <- function(content, theme, cell_type = "content") {
  if (is.null(content) || is.na(content) || content == "") {
    return("")
  }
  
  # Apply theme-specific formatting based on cell type
  switch(cell_type,
    "content" = as.character(content),
    "computation" = as.character(content),
    "separator" = paste0(rep("-", 3), collapse = ""),
    as.character(content) # default
  )
}

#' Generate CSS for Theme Styling
#'
#' @return CSS string for all themes
#' @export
generate_theme_css <- function() {
  css_parts <- character()
  
  # Base table styling
  base_css <- paste0(
    "/* Base table styling for all themes */\n",
    ".table1 {\n",
    "  border-collapse: collapse;\n",
    "  margin: 20px 0;\n",
    "  width: 100%;\n",
    "  max-width: 100%;\n",
    "}\n",
    "\n",
    ".table1 th, .table1 td {\n",
    "  padding: 8px 12px;\n",
    "  vertical-align: middle;\n",
    "  border: 1px solid #ddd;\n",
    "}\n",
    "\n",
    ".table1 td:not(:first-child) {\n",
    "  white-space: nowrap;\n",
    "}\n",
    "\n",
    ".table1 th {\n",
    "  text-align: center;\n",
    "  font-weight: bold;\n",
    "  background-color: #f8f9fa;\n",
    "}\n",
    "\n",
    ".table1 th:first-child {\n",
    "  text-align: left;\n",
    "}\n",
    "\n",
    ".table1 td {\n",
    "  text-align: center;\n",
    "}\n",
    "\n",
    ".table1 td:first-child {\n",
    "  text-align: left;\n",
    "  padding-left: 8px;\n",
    "  white-space: pre;\n",
    "  vertical-align: middle;\n",
    "}\n",
    "\n",
    "/* General indentation classes */\n",
    ".table1-indent-variable {\n",
    "  font-style: italic;\n",
    "}\n",
    "\n",
    ".table1-indent-level {\n",
    "  font-weight: normal;\n",
    "}\n"
  )
  css_parts <- c(css_parts, base_css)
  
  for (theme_name in names(.theme_list)) {
    theme <- .theme_list[[theme_name]]
    css_class <- theme$css_class
    css_props <- theme$css_properties
    
    if (!is.null(css_class) && !is.null(css_props)) {
      # Create comprehensive CSS rules for this theme
      theme_css <- paste0("/* ", theme$name, " theme */\n")
      theme_css <- paste0(theme_css, ".", css_class, " {\n")
      
      # Add basic properties
      for (prop_name in names(css_props)) {
        prop_value <- css_props[[prop_name]]
        css_property <- switch(prop_name,
          "font_family" = "font-family",
          "font_size" = "font-size",
          "background_color" = "background-color",
          "border_color" = "border-color",
          "line_height" = "line-height",
          prop_name
        )
        theme_css <- paste0(theme_css, "  ", css_property, ": ", prop_value, ";\n")
      }
      theme_css <- paste0(theme_css, "}\n")
      
      # Add theme-specific cell and header styling
      theme_css <- paste0(theme_css, "\n.", css_class, " th, .", css_class, " td {\n")
      theme_css <- paste0(theme_css, "  font-family: ", css_props$font_family %||% "'Arial', sans-serif", ";\n")
      theme_css <- paste0(theme_css, "  font-size: ", css_props$font_size %||% "12px", ";\n")
      
      # Theme-specific border styling - medical journals use minimal borders
      if (theme_name %in% c("nejm", "lancet", "jama")) {
        theme_css <- paste0(theme_css, "  border-top: 2px solid #000;\n")
        theme_css <- paste0(theme_css, "  border-bottom: 1px solid #000;\n")
        theme_css <- paste0(theme_css, "  border-left: none;\n")
        theme_css <- paste0(theme_css, "  border-right: none;\n")
      } else {
        theme_css <- paste0(theme_css, "  border: 1px solid ", css_props$border_color %||% "#ddd", ";\n")
      }
      
      theme_css <- paste0(theme_css, "  padding: 8px 12px;\n")
      theme_css <- paste0(theme_css, "}\n")
      
      # Header-specific styling
      theme_css <- paste0(theme_css, "\n.", css_class, " th {\n")
      theme_css <- paste0(theme_css, "  font-weight: bold;\n")
      theme_css <- paste0(theme_css, "  background-color: ", css_props$header_background %||% css_props$background_color %||% "#f8f9fa", ";\n")
      
      if (theme_name %in% c("nejm", "lancet", "jama")) {
        theme_css <- paste0(theme_css, "  border-top: 2px solid #000;\n")
        theme_css <- paste0(theme_css, "  border-bottom: 2px solid #000;\n")
      }
      
      theme_css <- paste0(theme_css, "}\n")
      
      # Add theme-specific indentation CSS
      variable_indent <- theme$variable_indent %||% 2
      level_indent <- theme$level_indent %||% 4
      
      # Calculate padding values (base 8px + 8px per indent level)
      variable_padding <- 8 + (variable_indent * 8)
      level_padding <- 8 + (level_indent * 8)
      
      indentation_css <- paste0(
        "\n/* ", theme$name, " indentation */\n",
        ".", css_class, " td.table1-indent-variable {\n",
        "  padding-left: ", variable_padding, "px !important;\n",
        "  font-style: italic;\n",
        "}\n",
        "\n.",
        css_class, " td.table1-indent-level {\n",
        "  padding-left: ", level_padding, "px !important;\n",
        "}\n"
      )
      
      # Add row striping for NEJM theme
      stripe_css <- ""
      if (theme_name == "nejm" && !is.null(css_props$stripe_color)) {
        stripe_css <- paste0(
          "\n/* ", theme$name, " row striping */\n",
          ".", css_class, " tbody tr:nth-child(odd) {\n",
          "  background-color: ", css_props$stripe_color, ";\n",
          "}\n",
          "\n.", css_class, " tbody tr:nth-child(even) {\n",
          "  background-color: ", css_props$background_color, ";\n",
          "}\n"
        )
      }
      
      css_parts <- c(css_parts, theme_css, indentation_css, stripe_css)
    }
  }
  
  paste(css_parts, collapse = "\n")
}

#' Override Theme Fonts
#'
#' @param theme_name Theme name or theme object to modify
#' @param font_family New font family 
#' @param font_size New font size
#' @param header_font_weight New header font weight
#' @return Modified theme object
#' @export
override_theme_fonts <- function(theme_name, font_family = NULL, font_size = NULL, header_font_weight = NULL) {
  # Get theme object if theme_name is a string
  if (is.character(theme_name)) {
    theme <- get_theme(theme_name)
  } else {
    theme <- theme_name
  }
  
  if (!is.null(font_family)) {
    theme$css_properties$font_family <- font_family
  }
  if (!is.null(font_size)) {
    theme$css_properties$font_size <- font_size
  }
  if (!is.null(header_font_weight)) {
    theme$css_properties$header_font_weight <- header_font_weight
  }
  theme
}

#' Override Theme Colors
#'
#' @param theme_name Theme name or theme object to modify
#' @param background_color New background color
#' @param border_color New border color
#' @param stripe_color New stripe color
#' @param header_background New header background color
#' @return Modified theme object
#' @export
override_theme_colors <- function(theme_name, background_color = NULL, border_color = NULL, 
                                  stripe_color = NULL, header_background = NULL) {
  # Get theme object if theme_name is a string
  if (is.character(theme_name)) {
    theme <- get_theme(theme_name)
  } else {
    theme <- theme_name
  }
  
  if (!is.null(background_color)) {
    theme$css_properties$background_color <- background_color
  }
  if (!is.null(border_color)) {
    theme$css_properties$border_color <- border_color
  }
  if (!is.null(stripe_color)) {
    theme$css_properties$stripe_color <- stripe_color
  }
  if (!is.null(header_background)) {
    theme$css_properties$header_background <- header_background
  }
  theme
}

#' Customize Theme
#'
#' @param theme_name Theme name to customize
#' @param decimal_places Number of decimal places
#' @param css_properties List of CSS properties to override
#' @return Modified theme object
#' @export
customize_theme <- function(theme_name, decimal_places = NULL, css_properties = NULL) {
  theme <- get_theme(theme_name)
  
  if (!is.null(decimal_places)) {
    theme$decimal_places <- decimal_places
  }
  
  if (!is.null(css_properties)) {
    for (prop_name in names(css_properties)) {
      theme$css_properties[[prop_name]] <- css_properties[[prop_name]]
    }
  }
  
  theme
}

# =============================================================================
# Integration with Extensible Journal Style System  
# =============================================================================

#' Convert legacy theme to new journal style format
#' @param theme_name Legacy theme name
#' @return Journal style object
legacy_to_journal_style <- function(theme_name) {
  # This function bridges the old theme system with the new journal style system
  # Eventually, this can be deprecated once all themes are migrated
  
  legacy_theme <- get_theme(theme_name)
  
  # Map legacy theme to journal style structure
  # This is a transitional function
  list(
    name = legacy_theme$name,
    short_name = theme_name,
    legacy_theme = legacy_theme  # Preserve original for compatibility
  )
}

#' Get extended theme information
#' @param style_name Style name (supports both legacy and new styles)
#' @return Enhanced theme/style object
get_extended_theme <- function(style_name) {
  # Try new journal style system first
  if (file.exists("R/journal_styles.R")) {
    tryCatch({
      source("R/journal_styles.R", local = TRUE)
      return(get_journal_style(style_name))
    }, error = function(e) {
      # Fall back to legacy system
      return(get_theme(style_name))
    })
  } else {
    # Use legacy system
    return(get_theme(style_name))
  }
}

#' Future integration point for journal styles
#' This will eventually replace the current theme system entirely
migrate_to_journal_styles <- function() {
  # Placeholder for future migration
  # Will convert all legacy themes to journal style format
  # and update all rendering functions to use the new system
  message("Journal style migration not yet implemented")
}

#' Create Custom Theme
#'
#' @param name Theme display name
#' @param decimal_places Number of decimal places
#' @param font_family Font family
#' @param font_size Font size
#' @param background_color Background color
#' @param border_color Border color
#' @param stripe_color Stripe color
#' @param header_background Header background color
#' @param header_font_weight Header font weight
#' @param cell_font_weight Cell font weight
#' @return Custom theme object
#' @export
create_custom_theme <- function(name = "Custom", decimal_places = 2, 
                                font_family = "'Arial', sans-serif",
                                font_size = "12px", 
                                background_color = "#ffffff",
                                border_color = "#cccccc",
                                stripe_color = "#f9f9f9",
                                header_background = "#f0f0f0",
                                header_font_weight = "bold",
                                cell_font_weight = "normal") {
  
  list(
    name = name,
    theme_name = "custom",
    padding = 1,
    decimal_places = decimal_places,
    css_class = "table1-custom",
    css_properties = list(
      font_family = font_family,
      font_size = font_size,
      background_color = background_color,
      border_color = border_color,
      stripe_color = stripe_color,
      header_background = header_background,
      header_font_weight = header_font_weight,
      cell_font_weight = cell_font_weight
    )
  )
}