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
  set_theme_registry(.create_builtin_themes())

  # knitr is only in Suggests, so the method cannot be declared with
  # S3method() in NAMESPACE; delayed S3method(knitr::knit_print, ...)
  # needs R >= 3.6.0, above the declared R >= 3.5.0 floor. Exporting
  # the function alone is not enough: since R 4.0.0, S3 dispatch from
  # the knitr namespace no longer searches attached packages.
  register_s3_method(
    "knitr", "knit_print", "table1_blueprint", knit_print.table1_blueprint
  )

  # Optional: Startup message (disabled by default to avoid clutter)
  # Uncomment to show startup message:
  # packageStartupMessage("zztable1 ",
  #                      utils::packageVersion(pkgname),
  #                      " loaded successfully")
}

#' Register an S3 Method for a Generic in a Suggested Package
#'
#' Registers immediately if \code{pkg} is already loaded, and otherwise
#' (or additionally, if it is later reloaded) when \code{pkg} loads.
#'
#' @param pkg Package that defines the generic
#' @param generic Generic function name
#' @param class Class name
#' @param fun Method function
#'
#' @return \code{NULL}, invisibly
#' @keywords internal
register_s3_method <- function(pkg, generic, class, fun) {
  register <- function(...) {
    registerS3method(generic, class, fun, envir = asNamespace(pkg))
  }
  if (isNamespaceLoaded(pkg)) {
    register()
  }
  setHook(packageEvent(pkg, "onLoad"), register)
  invisible(NULL)
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
