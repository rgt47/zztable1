# ============================================================================
# User-Contributed Themes Registry System
# ============================================================================
#
# This module provides functionality for users to register, discover,
# and manage custom themes. Themes can be shared through R packages
# or registered in a central registry.
#
# @keywords internal

#' Register a custom theme globally
#'
#' Registers a custom theme in the package registry, making it available
#' to all subsequent calls in the session.
#'
#' @param theme_obj A theme object (list with required fields)
#' @param overwrite Logical, whether to overwrite existing theme
#'
#' @return Invisibly returns the registered theme
#'
#' @details
#' A valid theme must have:
#' - name: Character string with theme name
#' - decimal_places: Numeric decimal places
#' - css_properties: List of CSS properties
#' - dimension_rules: List of dimension rules (optional)
#'
#' @examples
#' \dontrun{
#' my_theme <- create_custom_theme("MyTheme", base_theme = "nejm")
#' register_theme(my_theme)
#' }
#'
#' @export
register_theme <- function(theme_obj, overwrite = FALSE) {
  # Validate theme structure
  validate_theme_structure(theme_obj)

  # Get registry
  ns <- getNamespace("zztable1")
  registry <- get0(".theme_registry", envir = ns, inherits = FALSE)

  # Check if already registered
  if (!is.null(registry) && theme_obj$theme_name %in% names(registry)) {
    if (!overwrite) {
      message(
        "Theme '", theme_obj$theme_name, "' already registered. ",
        "Use overwrite = TRUE to replace."
      )
      return(invisible(theme_obj))
    }
  }

  # Add to registry (if built-in registry exists)
  if (!is.null(registry)) {
    registry[[theme_obj$theme_name]] <- theme_obj
    assign(".theme_registry", registry, envir = ns)
  }

  message("Theme '", theme_obj$theme_name, "' registered successfully")
  invisible(theme_obj)
}

#' Unregister a custom theme
#'
#' Removes a theme from the registry. Cannot unregister built-in themes.
#'
#' @param theme_name Character string with theme name
#'
#' @return Invisibly returns TRUE if successful
#'
#' @examples
#' \dontrun{
#' unregister_theme("MyCustomTheme")
#' }
#'
#' @export
unregister_theme <- function(theme_name) {
  builtin_themes <- c("console", "nejm", "lancet", "jama", "bmj")

  if (theme_name %in% builtin_themes) {
    stop(
      "Cannot unregister built-in theme '", theme_name, "'",
      call. = FALSE
    )
  }

  ns <- getNamespace("zztable1")
  registry <- get0(".theme_registry", envir = ns, inherits = FALSE)

  if (!is.null(registry) && theme_name %in% names(registry)) {
    registry[[theme_name]] <- NULL
    assign(".theme_registry", registry, envir = ns)
    message("Theme '", theme_name, "' unregistered")
  }

  invisible(TRUE)
}

#' List registered custom themes
#'
#' Lists all custom (non-built-in) themes registered in the session.
#'
#' @return Character vector of custom theme names
#'
#' @examples
#' \dontrun{
#' list_custom_themes()
#' }
#'
#' @export
list_custom_themes <- function() {
  builtin <- c("console", "nejm", "lancet", "jama", "bmj")
  all_themes <- list_available_themes()
  setdiff(all_themes, builtin)
}

#' Get theme metadata
#'
#' Retrieves metadata about a registered theme.
#'
#' @param theme_name Character string with theme name
#'
#' @return List with theme metadata (name, author, version, description)
#'
#' @examples
#' \dontrun{
#' get_theme_metadata("nejm")
#' }
#'
#' @export
get_theme_metadata <- function(theme_name) {
  theme_obj <- get_theme(theme_name)

  # Extract metadata fields if present
  metadata <- list(
    name = theme_obj$name,
    theme_name = theme_obj$theme_name,
    author = theme_obj$author %||% "Unknown",
    version = theme_obj$version %||% "1.0.0",
    description = theme_obj$description %||% "No description",
    decimal_places = theme_obj$decimal_places
  )

  if (!is.null(theme_obj$created)) {
    metadata$created <- theme_obj$created
  }

  metadata
}

#' Validate theme structure
#'
#' Checks that a theme object has all required fields.
#'
#' @param theme_obj Theme object to validate
#'
#' @return Invisibly returns TRUE if valid
#'
#' @keywords internal
validate_theme_structure <- function(theme_obj) {
  # Required fields
  required <- c("name", "decimal_places", "css_properties")

  for (field in required) {
    if (!field %in% names(theme_obj)) {
      stop(
        "Theme missing required field: '", field, "'",
        call. = FALSE
      )
    }
  }

  # Validate types
  if (!is.character(theme_obj$name)) {
    stop("Theme 'name' must be character", call. = FALSE)
  }

  if (!is.numeric(theme_obj$decimal_places)) {
    stop("Theme 'decimal_places' must be numeric", call. = FALSE)
  }

  if (!is.list(theme_obj$css_properties)) {
    stop("Theme 'css_properties' must be a list", call. = FALSE)
  }

  invisible(TRUE)
}

#' Export theme to R package format
#'
#' Creates R code that can be included in a package to register a theme.
#'
#' @param theme_obj Theme object to export
#' @param file Optional file path to write to
#'
#' @return Character string with R code (invisibly if file specified)
#'
#' @details
#' The returned code can be included in an R package's R/ directory
#' to automatically register the theme when the package loads.
#'
#' @examples
#' \dontrun{
#' my_theme <- create_custom_theme("MyTheme")
#' code <- export_theme_to_package(my_theme)
#' cat(code)
#' }
#'
#' @export
export_theme_to_package <- function(theme_obj, file = NULL) {
  # Validate theme first
  validate_theme_structure(theme_obj)

  # Create R code
  code <- sprintf(
    "# Automatically generated theme registration\n\
.register_theme_on_load <- function() {\n\
  theme <- list(\n\
    name = %s,\n\
    theme_name = %s,\n\
    decimal_places = %d,\n\
    css_properties = %s\n\
  )\n\
  if (requireNamespace('zztable1', quietly = TRUE)) {\n\
    zztable1::register_theme(theme)\n\
  }\n\
}\n\
\n\
.onLoad <- function(libname, pkgname) {\n\
  .register_theme_on_load()\n\
}",
    deparse(theme_obj$name),
    deparse(theme_obj$theme_name),
    theme_obj$decimal_places,
    deparse(theme_obj$css_properties)
  )

  if (!is.null(file)) {
    writeLines(code, file)
    message("Theme R code written to: ", file)
    invisible(code)
  } else {
    code
  }
}

#' Create theme bundle
#'
#' Bundles multiple themes for distribution.
#'
#' @param themes List of theme objects
#' @param name Bundle name
#' @param description Bundle description
#' @param author Bundle author
#'
#' @return List with bundle information
#'
#' @details
#' Themes can be bundled together and distributed as an R package
#' or shared directly.
#'
#' @examples
#' \dontrun{
#' themes <- list(
#'   create_custom_theme("Theme1"),
#'   create_custom_theme("Theme2")
#' )
#' bundle <- create_theme_bundle(themes, name = "MyThemes")
#' }
#'
#' @export
create_theme_bundle <- function(themes, name, description = NULL, author = NULL) {
  # Validate all themes
  invisible(lapply(themes, validate_theme_structure))

  # Create bundle
  bundle <- list(
    name = name,
    description = description,
    author = author,
    version = "1.0.0",
    created = Sys.time(),
    themes = themes,
    count = length(themes)
  )

  class(bundle) <- c("theme_bundle", "list")
  bundle
}

#' Print method for theme bundles
#'
#' @param x Theme bundle object
#' @param ... Additional arguments (ignored)
#'
#' @export
print.theme_bundle <- function(x, ...) {
  cat("Theme Bundle: ", x$name, "\n", sep = "")
  cat("  Description: ", x$description %||% "None", "\n", sep = "")
  cat("  Author: ", x$author %||% "Unknown", "\n", sep = "")
  cat("  Version: ", x$version, "\n", sep = "")
  cat("  Themes: ", x$count, "\n", sep = "")
  cat("  Created: ", format(x$created), "\n", sep = "")

  if (x$count > 0) {
    cat("  \n  Included themes:\n")
    for (theme in x$themes) {
      cat("    - ", theme$name, " (", theme$theme_name, ")\n", sep = "")
    }
  }
}

#' Install themes from bundle
#'
#' Registers all themes from a bundle in the current session.
#'
#' @param bundle Theme bundle object
#' @param overwrite Logical, whether to overwrite existing themes
#'
#' @return Invisibly returns the bundle
#'
#' @examples
#' \dontrun{
#' bundle <- load_theme_bundle("path/to/bundle.rds")
#' install_themes_from_bundle(bundle)
#' }
#'
#' @export
install_themes_from_bundle <- function(bundle, overwrite = FALSE) {
  if (!inherits(bundle, "theme_bundle")) {
    stop("Object must be a theme_bundle", call. = FALSE)
  }

  cat("Installing ", bundle$count, " themes from bundle: ", bundle$name, "\n", sep = "")

  for (theme in bundle$themes) {
    register_theme(theme, overwrite = overwrite)
  }

  invisible(bundle)
}

#' Save theme bundle to file
#'
#' Serializes a theme bundle for distribution or storage.
#'
#' @param bundle Theme bundle object
#' @param file Path to save to
#'
#' @return Invisibly returns the file path
#'
#' @examples
#' \dontrun{
#' bundle <- create_theme_bundle(themes, name = "MyThemes")
#' save_theme_bundle(bundle, "mythemes.rds")
#' }
#'
#' @export
save_theme_bundle <- function(bundle, file) {
  if (!inherits(bundle, "theme_bundle")) {
    stop("Object must be a theme_bundle", call. = FALSE)
  }

  saveRDS(bundle, file)
  message("Theme bundle saved to: ", file)
  invisible(file)
}

#' Load theme bundle from file
#'
#' Loads a previously saved theme bundle.
#'
#' @param file Path to bundle file
#'
#' @return Theme bundle object
#'
#' @examples
#' \dontrun{
#' bundle <- load_theme_bundle("mythemes.rds")
#' install_themes_from_bundle(bundle)
#' }
#'
#' @export
load_theme_bundle <- function(file) {
  if (!file.exists(file)) {
    stop("File not found: ", file, call. = FALSE)
  }

  bundle <- readRDS(file)

  if (!inherits(bundle, "theme_bundle")) {
    stop("File does not contain a valid theme bundle", call. = FALSE)
  }

  bundle
}

# Null-coalescing operator (defined in themes.R)
# Kept here for backward compatibility but no roxygen docs to avoid duplicate Rd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
