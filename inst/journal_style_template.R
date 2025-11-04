# =============================================================================
# Journal Style Template
# =============================================================================
# Template for creating new journal style definitions
# Copy this file and modify to create styles for new journals

#' [JOURNAL NAME] style template
#' 
#' To create a new journal style:
#' 1. Copy this template
#' 2. Replace [JOURNAL NAME] with the actual journal name
#' 3. Replace [SHORT_NAME] with a short identifier (e.g., "plos", "cell", "science")
#' 4. Modify the configuration parameters based on journal requirements
#' 5. Add the function to journal_styles.R
#' 6. Update get_all_journal_styles() to include the new style
#'
#' @return Journal style object
get_[SHORT_NAME]_style <- function() {
  create_journal_style(
    name = "[JOURNAL NAME]",
    short_name = "[SHORT_NAME]",
    
    # LaTeX Configuration
    latex_config = latex_config(
      # Required LaTeX packages (modify as needed)
      packages = c("booktabs", "xcolor", "colortbl", "array"),
      
      # Color definitions (HTML hex codes without #)
      colors = list(
        stripe = "f9f9f9",      # Row striping color
        text = "000000",        # Text color  
        border = "cccccc",      # Border color
        header_bg = "e6e6e6"    # Header background
      ),
      
      # Font specifications
      fonts = list(
        family = "Arial",       # Font family (Times, Arial, etc.)
        size = "10pt",          # Font size
        header_weight = "bold"  # Header font weight
      ),
      
      # Table environment (usually "tabular", sometimes "longtable")
      table_env = "tabular",
      
      # Rule specifications (LaTeX commands for table rules)
      rules = list(
        top = "\\toprule",      # Top rule
        middle = "\\midrule",   # Middle rule (after header)
        bottom = "\\bottomrule" # Bottom rule
      ),
      
      # Spacing configuration
      spacing = list(
        array_stretch = 1.2,    # Row height multiplier
        col_sep = "6pt"         # Column separation
      ),
      
      # Row striping configuration
      striping = list(
        enabled = FALSE,        # Enable/disable row striping
        color = "stripe",       # Color name from colors list
        pattern = "even"        # "even" or "odd" rows
      ),
      
      # Factor level indentation
      indentation = list(
        method = "hspace",      # LaTeX indentation method
        amount = "1em"          # Indentation amount
      )
    ),
    
    # HTML/CSS Configuration  
    html_config = html_config(
      css_class = "table1-[SHORT_NAME]",
      
      # CSS colors (with # prefix)
      colors = list(
        stripe = "#f9f9f9",
        text = "#000000", 
        border = "#cccccc",
        header_bg = "#e6e6e6"
      ),
      
      # CSS font specifications
      fonts = list(
        family = "Arial, sans-serif",
        size = "12px",
        weight = "normal"
      ),
      
      # CSS spacing
      spacing = list(
        padding = "4px 8px",    # Cell padding
        margin = "0"            # Table margin
      ),
      
      # CSS striping rules
      striping = list(
        enabled = FALSE,        # Enable/disable CSS striping
        odd_bg = "#ffffff",     # Odd row background
        even_bg = "#f9f9f9"     # Even row background
      ),
      
      # CSS indentation rules
      indentation = list(
        method = "margin-left", # CSS indentation method
        amount = "1em"          # Indentation amount
      )
    ),
    
    # General formatting preferences
    general_config = general_config(
      decimal_places = 1,                    # Number of decimal places
      p_value_threshold = 0.05,              # P-value significance threshold
      missing_indicator = "Missing",         # How to show missing values
      
      # Factor display preferences
      factor_display = list(
        show_n = TRUE,                       # Show counts
        show_percent = TRUE,                 # Show percentages
        format = "n (%)"                     # Format string
      ),
      
      # Default statistical tests
      statistical_tests = list(
        continuous = "t.test",               # Test for continuous variables
        categorical = "chisq.test"           # Test for categorical variables
      )
    )
  )
}

# =============================================================================
# Journal-Specific Configuration Examples
# =============================================================================

# Example 1: High-impact journal with strict formatting
# - Small fonts (8-9pt)
# - Minimal spacing
# - No colors/striping
# - Precise decimal places
get_high_impact_example <- function() {
  create_journal_style(
    name = "High Impact Example",
    short_name = "high_impact",
    latex_config = latex_config(
      packages = c("booktabs", "array"),
      fonts = list(family = "Arial", size = "8pt"),
      spacing = list(array_stretch = 1.0, col_sep = "4pt"),
      striping = list(enabled = FALSE)
    ),
    html_config = html_config(
      css_class = "table1-high-impact",
      fonts = list(family = "Arial, sans-serif", size = "10px")
    ),
    general_config = general_config(decimal_places = 2)
  )
}

# Example 2: Clinical journal with readable formatting
# - Larger fonts (10-11pt)
# - Row striping for readability
# - Clear spacing
get_clinical_example <- function() {
  create_journal_style(
    name = "Clinical Example",
    short_name = "clinical",
    latex_config = latex_config(
      colors = list(stripe = "f0f8ff"),
      fonts = list(family = "Times", size = "11pt"),
      spacing = list(array_stretch = 1.3),
      striping = list(enabled = TRUE, color = "stripe")
    ),
    html_config = html_config(
      css_class = "table1-clinical",
      striping = list(enabled = TRUE, even_bg = "#f0f8ff")
    ),
    general_config = general_config(decimal_places = 1)
  )
}

# =============================================================================
# Journal Requirements Reference
# =============================================================================

# Common journal formatting patterns:
#
# 1. NEJM, Lancet, JAMA: 
#    - Simple, clean tables
#    - Minimal colors
#    - Standard statistical formatting
#
# 2. Nature family (Nature, Nature Medicine, etc.):
#    - Compact formatting
#    - Small fonts
#    - High information density
#
# 3. PLOS family:
#    - Open, accessible formatting
#    - Clear visual hierarchy
#    - Good contrast
#
# 4. Specialty journals:
#    - Often follow major journal patterns
#    - May have specific color schemes
#    - Institutional branding considerations
#
# 5. Regional journals:
#    - May prefer local typography
#    - Different statistical conventions
#    - Language-specific formatting

# =============================================================================
# Integration Instructions
# =============================================================================

# To add a new journal style to the package:
#
# 1. Create the style function using this template
# 2. Add it to R/journal_styles.R
# 3. Update get_all_journal_styles() to include it:
#    ```r
#    get_all_journal_styles <- function() {
#      list(
#        nejm = get_nejm_style(),
#        lancet = get_lancet_style(),
#        # ... existing styles ...
#        your_journal = get_your_journal_style()  # Add here
#      )
#    }
#    ```
# 4. Update documentation
# 5. Add tests for the new style
# 6. Update vignettes with examples

# Testing your new style:
# ```r
# # Test basic functionality
# style <- get_your_journal_style()
# bp <- table1(group ~ var1 + var2, data = your_data, theme = style)
# 
# # Test LaTeX output
# latex_out <- render_latex(bp)
# 
# # Test HTML output  
# html_out <- render_html(bp)
# 
# # Check specific features
# expect_true(style_has_striping(style, "latex"))
# expect_equal(get_stripe_color(style, "latex"), "yourjournalstripe")
# ```