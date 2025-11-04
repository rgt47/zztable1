# =============================================================================
# Journal-Specific Style System
# =============================================================================
# Support for multiple medical journal formatting requirements

#' Create a new journal style definition
#' @param name Full journal name
#' @param short_name Short identifier (e.g., "nejm", "lancet") 
#' @param latex_config LaTeX-specific formatting rules
#' @param html_config HTML/CSS-specific formatting rules
#' @param general_config General formatting preferences
#' @return Journal style object
create_journal_style <- function(name, short_name, latex_config, html_config, general_config) {
  structure(list(
    name = name,
    short_name = short_name,
    latex = latex_config,
    html = html_config,
    general = general_config,
    created = Sys.time()
  ), class = "journal_style")
}

#' LaTeX configuration for journal styles
#' @param packages Required LaTeX packages
#' @param colors Named list of color definitions (HTML hex codes)
#' @param fonts Font specifications
#' @param table_env Table environment to use
#' @param rules Rule specifications (toprule, midrule, bottomrule)
#' @param spacing Row and column spacing
#' @param striping Row striping configuration
#' @param indentation Factor level indentation rules
#' @return LaTeX configuration object
latex_config <- function(packages = c("booktabs", "xcolor", "colortbl"), 
                        colors = list(), 
                        fonts = list(),
                        table_env = "tabular",
                        rules = list(top = "\\toprule", middle = "\\midrule", bottom = "\\bottomrule"),
                        spacing = list(array_stretch = 1.2, col_sep = "6pt"),
                        striping = list(enabled = FALSE, color = NULL, pattern = "even"),
                        indentation = list(method = "hspace", amount = "1em")) {
  list(
    packages = packages,
    colors = colors,
    fonts = fonts,
    table_env = table_env,
    rules = rules,
    spacing = spacing,
    striping = striping,
    indentation = indentation
  )
}

#' HTML/CSS configuration for journal styles  
#' @param css_class CSS class name for tables
#' @param colors Named list of CSS color values
#' @param fonts CSS font specifications
#' @param spacing CSS spacing rules
#' @param striping CSS striping rules
#' @param indentation CSS indentation rules
#' @return HTML configuration object
html_config <- function(css_class,
                       colors = list(),
                       fonts = list(family = "Arial, sans-serif", size = "12px"),
                       spacing = list(padding = "4px 8px", margin = "0"),
                       striping = list(enabled = FALSE, odd_bg = "#ffffff", even_bg = "#f9f9f9"),
                       indentation = list(method = "margin-left", amount = "1em")) {
  list(
    css_class = css_class,
    colors = colors,
    fonts = fonts,
    spacing = spacing,
    striping = striping,
    indentation = indentation
  )
}

#' General formatting configuration
#' @param decimal_places Number of decimal places for continuous variables
#' @param p_value_threshold P-value threshold for significance
#' @param missing_indicator How to display missing values
#' @param factor_display How to display factor levels
#' @param statistical_tests Default statistical tests to use
#' @return General configuration object
general_config <- function(decimal_places = 1,
                          p_value_threshold = 0.05,
                          missing_indicator = "Missing",
                          factor_display = list(show_n = TRUE, show_percent = TRUE),
                          statistical_tests = list(continuous = "t.test", categorical = "chisq.test")) {
  list(
    decimal_places = decimal_places,
    p_value_threshold = p_value_threshold,
    missing_indicator = missing_indicator,
    factor_display = factor_display,
    statistical_tests = statistical_tests
  )
}

# =============================================================================
# Pre-defined Journal Styles
# =============================================================================

#' New England Journal of Medicine style
get_nejm_style <- function() {
  create_journal_style(
    name = "New England Journal of Medicine",
    short_name = "nejm",
    latex_config = latex_config(
      packages = c("booktabs", "xcolor", "colortbl", "array"),
      colors = list(
        stripe = "fefcf0",  # Light cream background
        text = "333333",    # Dark gray text
        border = "cccccc"   # Light gray borders
      ),
      fonts = list(
        family = "Times",
        size = "10pt",
        header_weight = "bold"
      ),
      spacing = list(array_stretch = 1.2, col_sep = "8pt"),
      striping = list(enabled = TRUE, color = "stripe", pattern = "even"),
      indentation = list(method = "hspace", amount = "1em")
    ),
    html_config = html_config(
      css_class = "table1-nejm",
      colors = list(
        stripe = "#fefcf0",
        text = "#333333",
        border = "#cccccc"
      ),
      fonts = list(family = "Times, serif", size = "12px"),
      striping = list(enabled = TRUE, odd_bg = "#ffffff", even_bg = "#fefcf0")
    ),
    general_config = general_config(
      decimal_places = 1,
      factor_display = list(show_n = TRUE, show_percent = TRUE, format = "n (%)")
    )
  )
}

#' The Lancet Neurology style (authentic formatting from real Lancet papers)
get_lancet_style <- function() {
  create_journal_style(
    name = "The Lancet",
    short_name = "lancet", 
    latex_config = latex_config(
      packages = c("booktabs", "array"),
      colors = list(),  # No special colors - clean white
      fonts = list(
        family = "Times", 
        size = "8pt",  # Smaller, more compact than JAMA
        header_weight = "bold"
      ),
      spacing = list(array_stretch = 1.1, col_sep = "4pt"),  # Tighter spacing
      rules = list(
        top = "\\toprule",
        middle = "",  # No middle rule - distinctive Lancet feature  
        bottom = "\\bottomrule"
      ),
      striping = list(enabled = FALSE),
      indentation = list(method = "hspace", amount = "0.6em")  # Subtle indentation
    ),
    html_config = html_config(
      css_class = "table1-lancet",
      fonts = list(
        family = "Times, serif", 
        size = "9px",  # Compact sizing for web
        weight = "normal"
      ),
      spacing = list(padding = "2px 6px", margin = "0"),  # Tight spacing
      striping = list(enabled = FALSE)
    ),
    general_config = general_config(
      decimal_places = 1,
      factor_display = list(
        show_n = TRUE, 
        show_percent = TRUE, 
        format = "n (%)"  # Standard format
      ),
      statistical_tests = list(
        continuous = "t.test", 
        categorical = "chisq.test"
      )
    )
  )
}

#' JAMA style (authentic formatting from real JAMA papers)
get_jama_style <- function() {
  create_journal_style(
    name = "JAMA",
    short_name = "jama",
    latex_config = latex_config(
      packages = c("booktabs", "array"),
      colors = list(),
      fonts = list(
        family = "Arial", 
        size = "9pt", 
        header_weight = "bold"
      ),
      spacing = list(array_stretch = 1.2, col_sep = "8pt"),
      rules = list(
        top = "\\toprule",
        middle = "\\midrule", 
        bottom = "\\bottomrule"
      ),
      striping = list(enabled = FALSE),
      indentation = list(method = "hspace", amount = "0.8em")
    ),
    html_config = html_config(
      css_class = "table1-jama",
      fonts = list(
        family = "Arial, sans-serif", 
        size = "10px",
        weight = "normal"
      ),
      spacing = list(padding = "4px 8px", margin = "0"),
      striping = list(enabled = FALSE)
    ),
    general_config = general_config(
      decimal_places = 1,
      p_value_threshold = 0.05,
      factor_display = list(
        show_n = TRUE, 
        show_percent = TRUE, 
        format = "n (%)"
      ),
      statistical_tests = list(
        continuous = "t.test", 
        categorical = "chisq.test"
      )
    )
  )
}

#' British Medical Journal style
get_bmj_style <- function() {
  create_journal_style(
    name = "BMJ",
    short_name = "bmj",
    latex_config = latex_config(
      packages = c("booktabs", "xcolor", "colortbl"),
      colors = list(
        header_bg = "e6f3ff",  # Light blue header
        border = "999999"
      ),
      fonts = list(family = "Arial", size = "9pt"),
      spacing = list(array_stretch = 1.1),
      striping = list(enabled = FALSE),
      indentation = list(method = "hspace", amount = "0.8em")
    ),
    html_config = html_config(
      css_class = "table1-bmj",
      colors = list(header_bg = "#e6f3ff", border = "#999999"),
      fonts = list(family = "Arial, sans-serif", size = "11px")
    ),
    general_config = general_config(decimal_places = 2)
  )
}

#' Nature Medicine style
get_nature_style <- function() {
  create_journal_style(
    name = "Nature Medicine",
    short_name = "nature",
    latex_config = latex_config(
      packages = c("booktabs", "array", "xcolor"),
      colors = list(text = "1a1a1a"),
      fonts = list(family = "Arial", size = "8pt"),
      spacing = list(array_stretch = 1.0, col_sep = "4pt"),
      rules = list(
        top = "\\toprule[1pt]",
        middle = "\\midrule[0.5pt]", 
        bottom = "\\bottomrule[1pt]"
      ),
      striping = list(enabled = FALSE),
      indentation = list(method = "hspace", amount = "1em")
    ),
    html_config = html_config(
      css_class = "table1-nature",
      fonts = list(family = "Arial, sans-serif", size = "10px", weight = "400"),
      spacing = list(padding = "3px 6px")
    ),
    general_config = general_config(
      decimal_places = 2,
      factor_display = list(format = "n/N (%)")
    )
  )
}

# =============================================================================
# Journal Style Registry and Management
# =============================================================================

#' Get all available journal styles
#' @return Named list of all journal styles
get_all_journal_styles <- function() {
  list(
    nejm = get_nejm_style(),
    lancet = get_lancet_style(),
    jama = get_jama_style(),
    bmj = get_bmj_style(),
    nature = get_nature_style()
  )
}

#' Get a specific journal style
#' @param style_name Short name of the journal style
#' @return Journal style object
get_journal_style <- function(style_name) {
  all_styles <- get_all_journal_styles()
  
  if (!style_name %in% names(all_styles)) {
    warning("Unknown journal style '", style_name, "'. Available styles: ", 
            paste(names(all_styles), collapse = ", "))
    return(get_console_style()) # Fallback to console
  }
  
  all_styles[[style_name]]
}

#' List available journal styles
#' @return Character vector of available style names
list_journal_styles <- function() {
  names(get_all_journal_styles())
}

#' Console/development style (minimal formatting)
get_console_style <- function() {
  create_journal_style(
    name = "Console",
    short_name = "console",
    latex_config = latex_config(
      packages = c("array"),
      striping = list(enabled = FALSE)
    ),
    html_config = html_config(
      css_class = "table1-console",
      fonts = list(family = "monospace")
    ),
    general_config = general_config(decimal_places = 3)
  )
}

# =============================================================================
# Style Application Functions  
# =============================================================================

#' Apply journal style to LaTeX output
#' @param style Journal style object
#' @return Character vector of LaTeX setup commands
apply_latex_style <- function(style) {
  latex_cfg <- style$latex
  setup_lines <- character(0)
  
  # Add comment header
  setup_lines <- c(setup_lines, paste0("% ", style$name, " style"))
  
  # Add color definitions
  if (length(latex_cfg$colors) > 0) {
    for (color_name in names(latex_cfg$colors)) {
      color_value <- latex_cfg$colors[[color_name]]
      setup_lines <- c(setup_lines, 
        paste0("\\definecolor{", style$short_name, color_name, "}{HTML}{", color_value, "}"))
    }
  }
  
  # Add spacing commands
  if (!is.null(latex_cfg$spacing$array_stretch)) {
    setup_lines <- c(setup_lines,
      paste0("\\renewcommand{\\arraystretch}{", latex_cfg$spacing$array_stretch, "}"))
  }
  
  return(setup_lines)
}

#' Apply journal style to HTML output
#' @param style Journal style object  
#' @return CSS string
apply_html_style <- function(style) {
  html_cfg <- style$html
  css_lines <- character(0)
  
  # Base table styling
  css_class <- html_cfg$css_class
  css_lines <- c(css_lines, paste0(".", css_class, " {"))
  
  # Font styling
  if (!is.null(html_cfg$fonts$family)) {
    css_lines <- c(css_lines, paste0("  font-family: ", html_cfg$fonts$family, ";"))
  }
  if (!is.null(html_cfg$fonts$size)) {
    css_lines <- c(css_lines, paste0("  font-size: ", html_cfg$fonts$size, ";"))
  }
  
  css_lines <- c(css_lines, "}")
  
  # Striping rules
  if (html_cfg$striping$enabled) {
    css_lines <- c(css_lines,
      paste0(".", css_class, " tbody tr:nth-child(odd) {"),
      paste0("  background-color: ", html_cfg$striping$odd_bg, ";"),
      "}",
      paste0(".", css_class, " tbody tr:nth-child(even) {"),
      paste0("  background-color: ", html_cfg$striping$even_bg, ";"),
      "}"
    )
  }
  
  return(paste(css_lines, collapse = "\n"))
}

#' Check if a journal style supports row striping
#' @param style Journal style object
#' @param format Output format ("latex" or "html")
#' @return Logical indicating if striping is enabled
style_has_striping <- function(style, format = "latex") {
  if (format == "latex") {
    return(style$latex$striping$enabled %||% FALSE)
  } else if (format == "html") {
    return(style$html$striping$enabled %||% FALSE)
  }
  return(FALSE)
}

#' Get the stripe color for a journal style
#' @param style Journal style object
#' @param format Output format ("latex" or "html")  
#' @return Color specification
get_stripe_color <- function(style, format = "latex") {
  if (format == "latex" && style$latex$striping$enabled) {
    color_name <- style$latex$striping$color
    if (!is.null(color_name)) {
      return(paste0(style$short_name, color_name))
    }
  } else if (format == "html" && style$html$striping$enabled) {
    return(style$html$striping$even_bg)
  }
  return(NULL)
}