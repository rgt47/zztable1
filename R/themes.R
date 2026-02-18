# ============================================================================
# Unified Theme System (Consolidated)
# ============================================================================
#
# Manages all theme definitions and configuration for the table1 package.
# Themes control formatting for different output formats and medical journals.
#
# Architecture:
# - Theme registry loaded in package environment via .onLoad()
# - Immutable theme definitions
# - Factory functions for creating custom themes
# - Application functions for rendering with theme specifications
#

# Null coalescing operator (needed for theme defaults)
# @noRd to prevent Rd file generation (pipe character in name causes issues)
`%||%` <- function(x, y) if (is.null(x)) y else x

# ============================================================================
# Core Theme Definition Factory
# ============================================================================

#' Create Theme Configuration
#'
#' Internal factory function for creating consistent theme objects.
#' Used to define all built-in themes.
#'
#' @param name Display name of the theme
#' @param decimal_places Decimal places for numeric formatting
#' @param variable_indent Indentation for variables
#' @param level_indent Indentation for factor levels
#' @param stratum_separator Separator type between strata
#' @param factor_separator Separator type between factors
#' @param dimension_rules List of dimension calculation rules
#' @param rendering_rules List of rendering functions
#' @param css_properties Named list of CSS properties
#'
#' @return Theme object (list with class "table1_theme")
#' @keywords internal
create_theme <- function(name, decimal_places = 1, variable_indent = 2,
                        level_indent = 4, stratum_separator = "text",
                        factor_separator = "text", dimension_rules = list(),
                        rendering_rules = list(), css_properties = list()) {

  # Default dimension rules if not provided
  if (length(dimension_rules) == 0) {
    dimension_rules <- list(
      factor_separator = factor_separator,
      stratum_separator = stratum_separator,
      variable_grouping = "compact",
      missing_presentation = "inline",
      summary_style = "combined",
      footnote_style = "numbered",
      strip_empty_rows = FALSE,
      factor_level_grouping = "indented"
    )
  }

  # Default CSS properties if not provided
  if (length(css_properties) == 0) {
    css_properties <- list(
      background_color = "#ffffff",
      border_color = "#cccccc",
      font_family = "'Arial', sans-serif",
      font_size = "12px"
    )
  }

  theme <- structure(
    list(
      name = name,
      decimal_places = decimal_places,
      padding = if (decimal_places == 0) 0 else 1,
      variable_indent = variable_indent,
      level_indent = level_indent,
      stratum_separator = stratum_separator,
      factor_separator = factor_separator,
      dimension_rules = dimension_rules,
      rendering_rules = rendering_rules,
      css_properties = css_properties,
      css_class = paste0("table1-", tolower(gsub("[^a-z0-9]", "", name)))
    ),
    class = c("table1_theme", "list")
  )

  return(theme)
}

# ============================================================================
# Built-in Theme Definitions
# ============================================================================
# These are created during package load via .onLoad()
# See R/zzz.R for initialization

.create_builtin_themes <- function() {
  list(
    console = create_theme(
      name = "Console",
      decimal_places = 1,
      variable_indent = 2,
      level_indent = 4,
      stratum_separator = "text",
      factor_separator = "text",
      css_properties = list(
        background_color = "#f8f9fa",
        border_color = "#dee2e6",
        font_family = "'Consolas', 'Monaco', monospace",
        font_size = "14px"
      )
    ),
    nejm = create_theme(
      name = "New England Journal of Medicine",
      decimal_places = 1,
      variable_indent = 0,
      level_indent = 1,
      stratum_separator = "line",
      factor_separator = "none",
      dimension_rules = list(
        factor_separator = "none",
        stratum_separator = "line",
        variable_grouping = "compact",
        missing_presentation = "inline",
        summary_style = "combined",
        footnote_style = "numbered",
        strip_empty_rows = TRUE,
        factor_level_grouping = "flat"
      ),
      rendering_rules = list(
        format_numeric = function(x, digits = 1) {
          paste0(round(mean(x, na.rm = TRUE), digits), " \u00b1 ",
                 round(sd(x, na.rm = TRUE), digits))
        },
        format_categorical = function(x, total = NULL) {
          n <- length(x)
          if (is.null(total)) total <- n
          paste0(n, " (", round(100 * n / total, 1), ")")
        }
      ),
      css_properties = list(
        background_color = "#ffffff",
        stripe_color = "#fefcf0",
        border_color = "transparent",
        font_family = "'Arial', Helvetica, sans-serif",
        font_size = "10px",
        line_height = "1.2"
      )
    ),
    lancet = create_theme(
      name = "The Lancet",
      decimal_places = 1,
      variable_indent = 2,
      level_indent = 3,
      stratum_separator = "space",
      factor_separator = "space",
      dimension_rules = list(
        factor_separator = "space",
        stratum_separator = "space",
        variable_grouping = "spaced",
        missing_presentation = "separate_row",
        summary_style = "combined",
        footnote_style = "lettered",
        strip_empty_rows = FALSE,
        factor_level_grouping = "indented"
      ),
      rendering_rules = list(
        format_numeric = function(x, digits = 1) {
          paste0(round(mean(x, na.rm = TRUE), digits), " (",
                 round(sd(x, na.rm = TRUE), digits), ")")
        },
        format_categorical = function(x, total = NULL) {
          n <- length(x)
          if (is.null(total)) total <- n
          paste0(n, " (", round(100 * n / total, 1), "%)")
        }
      ),
      css_properties = list(
        background_color = "#ffffff",
        border_color = "transparent",
        font_family = "'Arial', Helvetica, sans-serif",
        font_size = "10px"
      )
    ),
    jama = create_theme(
      name = "JAMA",
      decimal_places = 1,
      variable_indent = 2,
      level_indent = 4,
      stratum_separator = "text",
      factor_separator = "text",
      dimension_rules = list(
        factor_separator = "none",
        stratum_separator = "text",
        variable_grouping = "compact",
        missing_presentation = "inline",
        summary_style = "combined",
        footnote_style = "lettered",
        strip_empty_rows = TRUE,
        factor_level_grouping = "indented"
      ),
      rendering_rules = list(
        format_numeric = function(x, digits = 1) {
          paste0(round(mean(x, na.rm = TRUE), digits), " (",
                 round(sd(x, na.rm = TRUE), digits), ")")
        },
        format_categorical = function(x, total = NULL) {
          n <- length(x)
          if (is.null(total)) total <- n
          paste0(n, " (", round(100 * n / total, 1), ")")
        }
      ),
      css_properties = list(
        background_color = "#ffffff",
        border_color = "transparent",
        font_family = "'Arial', sans-serif",
        font_size = "10px"
      )
    ),
    bmj = create_theme(
      name = "BMJ",
      decimal_places = 2,
      variable_indent = 2,
      level_indent = 4,
      stratum_separator = "line",
      factor_separator = "none",
      css_properties = list(
        background_color = "#ffffff",
        header_background = "#e6f3ff",
        border_color = "#999999",
        font_family = "'Arial', sans-serif",
        font_size = "11px"
      )
    ),
    simple = create_theme(
      name = "Simple",
      decimal_places = 2,
      variable_indent = 2,
      level_indent = 4,
      stratum_separator = "line",
      factor_separator = "none"
    )
  )
}

# ============================================================================
# Theme Registry Access Functions
# ============================================================================

#' Get Theme Configuration
#'
#' Retrieves a theme configuration by name. Falls back to console theme
#' if the requested theme is not found.
#'
#' @param theme_name Character string specifying theme name (e.g., "nejm", "lancet")
#'
#' @return Theme object (list with class "table1_theme")
#'
#' @details
#' Available themes: "console", "nejm", "lancet", "jama", "bmj", "simple"
#'
#' @examples
#' theme <- get_theme("nejm")
#' cat(theme$name)
#'
#' @export
get_theme <- function(theme_name = "console") {
  if (is.null(theme_name)) {
    theme_name <- "console"
  }

  # Get theme from package registry
  theme_registry <- get_theme_registry()

  if (!theme_name %in% names(theme_registry)) {
    warning("Unknown theme '", theme_name, "', using 'console'", call. = FALSE)
    theme_name <- "console"
  }

  theme <- theme_registry[[theme_name]]
  theme$theme_name <- theme_name

  return(theme)
}

#' Get Theme Registry
#'
#' Internal function to retrieve the theme registry from package environment.
#'
#' @return Named list of all registered themes
#'
#' @keywords internal
get_theme_registry <- function() {
  ns <- getNamespace("zztable1")
  registry <- get0(".theme_registry", envir = ns, inherits = FALSE)

  # Fallback to creating themes if registry not initialized
  if (is.null(registry)) {
    registry <- .create_builtin_themes()
  }

  return(registry)
}

#' List Available Themes
#'
#' Returns names of all available themes in the package.
#'
#' @return Character vector of theme names
#'
#' @examples
#' list_available_themes()
#'
#' @export
list_available_themes <- function() {
  names(get_theme_registry())
}

# ============================================================================
# Theme Application
# ============================================================================

#' Apply Theme to Blueprint
#'
#' Applies a theme configuration to a table1_blueprint object.
#' Updates metadata with theme information.
#'
#' @param blueprint Table1Blueprint object
#' @param theme Theme name (character) or theme object (list)
#'
#' @return Modified blueprint with theme applied
#'
#' @export
apply_theme <- function(blueprint, theme) {
  if (!inherits(blueprint, "table1_blueprint")) {
    stop("First argument must be a table1_blueprint", call. = FALSE)
  }

  # Convert character theme name to theme object if needed
  if (is.character(theme)) {
    theme <- get_theme(theme)
  } else if (!inherits(theme, "table1_theme")) {
    stop("Theme must be a character string or theme object", call. = FALSE)
  }

  # Validate required theme fields
  required_fields <- c("name", "decimal_places", "css_properties")
  missing_fields <- setdiff(required_fields, names(theme))
  if (length(missing_fields) > 0) {
    stop("Theme missing required fields: ",
         paste(missing_fields, collapse = ", "),
         call. = FALSE)
  }

  # Store theme in blueprint metadata
  if (is.null(blueprint$metadata)) {
    blueprint$metadata <- list()
  }
  blueprint$metadata$theme <- theme

  return(blueprint)
}

# ============================================================================
# Theme Customization
# ============================================================================

#' Create Custom Theme
#'
#' Creates a new custom theme based on specified parameters.
#' Can be used as a starting point for modifications.
#'
#' @param name Display name for the theme
#' @param base_theme Base theme to inherit from (default: "console")
#' @param decimal_places Number of decimal places
#' @param font_family Font family for CSS
#' @param font_size Font size for CSS
#' @param background_color Background color
#' @param border_color Border color
#'
#' @return Custom theme object
#'
#' @examples
#' \dontrun{
#' custom <- create_custom_theme("MyTheme", base_theme = "nejm")
#' }
#'
#' @export
create_custom_theme <- function(name = "Custom", base_theme = "console",
                               decimal_places = NULL, font_family = NULL,
                               font_size = NULL, background_color = NULL,
                               border_color = NULL) {

  # Start with base theme
  base <- get_theme(base_theme)

  # Create new theme with overrides
  theme <- base
  theme$name <- name
  theme$css_class <- paste0("table1-", tolower(gsub("[^a-z0-9]", "", name)))

  # Apply overrides
  if (!is.null(decimal_places)) {
    theme$decimal_places <- decimal_places
  }
  if (!is.null(font_family)) {
    theme$css_properties$font_family <- font_family
  }
  if (!is.null(font_size)) {
    theme$css_properties$font_size <- font_size
  }
  if (!is.null(background_color)) {
    theme$css_properties$background_color <- background_color
  }
  if (!is.null(border_color)) {
    theme$css_properties$border_color <- border_color
  }

  return(theme)
}

#' Customize Theme
#'
#' Modifies an existing theme's properties.
#'
#' @param theme_name Name of base theme to customize
#' @param decimal_places Number of decimal places
#' @param css_properties Named list of CSS properties to override
#'
#' @return Modified theme object
#'
#' @export
customize_theme <- function(theme_name, decimal_places = NULL,
                           css_properties = NULL) {
  theme <- get_theme(theme_name)

  if (!is.null(decimal_places)) {
    theme$decimal_places <- decimal_places
  }

  if (!is.null(css_properties)) {
    for (prop_name in names(css_properties)) {
      theme$css_properties[[prop_name]] <- css_properties[[prop_name]]
    }
  }

  return(theme)
}

# ============================================================================
# Theme-Aware Dimension Calculation
# ============================================================================

#' Calculate Theme-Specific Separator Rows
#'
#' Determines additional rows needed for separators based on theme
#' configuration and dimension analysis.
#'
#' @param analyses Dimension analysis results
#' @param theme Theme object
#'
#' @return Integer number of separator rows
#'
#' @keywords internal
calculate_theme_separator_rows <- function(analyses, theme) {
  separator_rows <- 0L

  if (is.null(theme$dimension_rules)) {
    return(separator_rows)
  }

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

  return(separator_rows)
}

#' Calculate Theme-Specific Missing Value Rows
#'
#' Determines if separate rows are needed for missing values
#' based on theme configuration.
#'
#' @param analyses Dimension analysis results
#' @param theme Theme object
#' @param missing Logical indicating if missing should be shown
#'
#' @return Integer number of missing value rows
#'
#' @keywords internal
calculate_theme_missing_rows <- function(analyses, theme, missing) {
  if (!missing || is.null(theme$dimension_rules)) {
    return(0L)
  }

  missing_style <- theme$dimension_rules$missing_presentation

  if (missing_style == "separate_row") {
    # Each variable with missing values gets a dedicated row
    sum(analyses$variables$missing_counts > 0)
  } else if (missing_style %in% c("inline", "footnote")) {
    # No additional rows needed
    0L
  } else {
    # Default
    sum(analyses$variables$missing_counts > 0)
  }
}

# ============================================================================
# Formatting Helpers
# ============================================================================

#' Format Cell Content
#'
#' Applies theme-specific formatting to cell content.
#'
#' @param content Cell content to format
#' @param theme Theme configuration
#' @param cell_type Type of cell ("content", "computation", "separator")
#'
#' @return Formatted content string
#'
#' @export
format_cell_content <- function(content, theme, cell_type = "content") {
  if (is.null(content) || is.na(content) || content == "") {
    return("")
  }

  switch(cell_type,
    "content" = as.character(content),
    "computation" = as.character(content),
    "separator" = paste0(rep("-", 3), collapse = ""),
    as.character(content)
  )
}

#' Get Theme Decimal Places
#'
#' Retrieves the decimal place setting for a theme.
#'
#' @param theme_name Character theme name
#'
#' @return Integer number of decimal places
#'
#' @keywords internal
get_theme_decimal_places <- function(theme_name) {
  theme <- get_theme(theme_name)
  theme$decimal_places %||% 1
}

# ============================================================================
# CSS Generation
# ============================================================================

#' Generate CSS for Theme Styling
#'
#' Generate Theme CSS
#'
#' Generates CSS for themes. If a specific theme is provided, generates CSS
#' for that theme only. Otherwise generates comprehensive CSS for all themes.
#'
#' @param theme Optional theme object. If NULL, generates CSS for all themes.
#' @return CSS string
#'
#' @keywords internal
generate_theme_css <- function(theme = NULL) {
  # If a specific theme is provided, generate CSS for just that theme

  if (!is.null(theme)) {
    return(generate_single_theme_css(theme))
  }

  # Otherwise generate CSS for all themes
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

  # Theme-specific CSS
  theme_registry <- get_theme_registry()
  for (theme_name in names(theme_registry)) {
    theme <- theme_registry[[theme_name]]
    css_class <- theme$css_class
    css_props <- theme$css_properties

    if (!is.null(css_class) && !is.null(css_props)) {
      theme_css <- paste0("/* ", theme$name, " theme */\n")
      theme_css <- paste0(theme_css, ".", css_class, " {\n")

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
        theme_css <- paste0(theme_css, "  ", css_property, ": ",
                           prop_value, ";\n")
      }
      theme_css <- paste0(theme_css, "}\n")

      css_parts <- c(css_parts, theme_css)
    }
  }

  paste(css_parts, collapse = "\n")
}

#' Generate CSS for a Single Theme
#'
#' Internal helper to generate CSS for a specific theme object.
#'
#' @param theme Theme object
#' @return CSS string for the theme
#' @keywords internal
generate_single_theme_css <- function(theme) {
  # Use theme_name for short CSS class if available
  css_class <- if (!is.null(theme$theme_name)) {
    paste0("table1-", theme$theme_name)
  } else {
    theme$css_class
  }
  css_props <- theme$css_properties

  if (is.null(css_class)) {
    return("")
  }

  theme_css <- paste0("/* ", theme$name, " theme */\n")
  theme_css <- paste0(theme_css, ".", css_class, " {\n")

  if (!is.null(css_props)) {
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
  }

  # Add NEJM-specific striping if this is NEJM theme
  theme_name <- theme$theme_name %||% theme$name
  if (theme_name %in% c("nejm", "New England Journal of Medicine")) {
    theme_css <- paste0(theme_css, "}\n\n")
    theme_css <- paste0(theme_css, ".", css_class, " tr:nth-child(odd) td {\n")
    theme_css <- paste0(theme_css, "  background-color: #ffffff;\n")
    theme_css <- paste0(theme_css, "}\n\n")
    theme_css <- paste0(theme_css, ".", css_class, " tr:nth-child(even) td {\n")
    theme_css <- paste0(theme_css, "  background-color: #fefcf0;\n")
    theme_css <- paste0(theme_css, "}\n")
  } else {
    theme_css <- paste0(theme_css, "}\n")
  }

  theme_css
}
