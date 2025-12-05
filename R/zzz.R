# ============================================================================
# Package Initialization Hook
# ============================================================================
#
# This file contains package initialization code that runs when the package
# is loaded. It sets up the package environment and initializes resources.
#

#' Package Initialization
#'
#' Called when the package is loaded. Initializes package environment with
#' theme registry and other package-level resources.
#'
#' @param libname Library path
#' @param pkgname Package name
#'
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  # Initialize package namespace
  ns <- getNamespace(pkgname)

  # Create and register built-in themes in package environment
  # This ensures themes are immutable and properly scoped
  builtin_themes <- .create_builtin_themes()

  assign(".theme_registry",
    builtin_themes,
    envir = ns)

  # Optional: Startup message (disabled by default to avoid clutter)
  # Uncomment to show startup message:
  # packageStartupMessage("zztable1nextgen ",
  #                      utils::packageVersion(pkgname),
  #                      " loaded successfully")
}

#' Package Unload Hook
#'
#' Called when the package is unloaded. Cleans up resources if needed.
#'
#' @param libpath Library path
#'
#' @keywords internal
.onUnload <- function(libpath) {
  # Clean up any temporary resources if needed
  # Currently no explicit cleanup required
}
