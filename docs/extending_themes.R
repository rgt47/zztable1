## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE,
  message = FALSE,
  results = 'asis'
)

# Load package
library(devtools)
load_all()

## ----theme-css, results='asis', echo=FALSE------------------------------------
# Generate and inject CSS for theme styling
theme_css <- generate_theme_css()
cat("<style>\n")
cat(theme_css)
cat("\n</style>")

## ----list-themes--------------------------------------------------------------
available_themes <- list_available_themes()
cat("Available themes:", paste(available_themes, collapse = ", "), "\n")

# Get details on NEJM theme
nejm_theme <- get_theme("nejm")
cat("\nNEJM Theme Details:\n")
cat("- Name:", nejm_theme$name, "\n")
cat("- Decimal places:", nejm_theme$decimal_places, "\n")
cat("- CSS class:", nejm_theme$css_class, "\n")

## ----custom-theme-basic-------------------------------------------------------
# Create a custom theme starting from NEJM
my_theme <- create_custom_theme(
  name = "MyCustom",
  base_theme = "nejm",
  decimal_places = 2
)

cat("Custom theme created:\n")
cat("- Name:", my_theme$name, "\n")
cat("- Decimal places:", my_theme$decimal_places, "\n")
cat("- CSS class:", my_theme$css_class, "\n")

## ----custom-theme-advanced----------------------------------------------------
# Create a highly customized theme using individual parameters
corporate_theme <- create_custom_theme(
  name = "Corporate",
  base_theme = "console",
  decimal_places = 1,
  font_family = "Arial, sans-serif",
  font_size = "11pt",
  background_color = "#e8f4f8",
  border_color = "#003366"
)

cat("Corporate theme created with custom properties:\n")
str(corporate_theme[c("name", "decimal_places")])

## ----customize-theme----------------------------------------------------------
# Modify an existing theme
modified_lancet <- customize_theme(
  "lancet",
  decimal_places = 3,
  css_properties = list(
    font_size = "12pt"
  )
)

cat("Modified Lancet theme:\n")
cat("- Decimal places:", modified_lancet$decimal_places, "\n")
cat("- Font size:", modified_lancet$css_properties$font_size, "\n")

## ----example-custom-theme-----------------------------------------------------
# Sample data
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
mtcars$engine <- factor(ifelse(mtcars$vs == 1, "V-Engine", "Straight"))

# Create table with custom theme
bp <- table1(
  transmission ~ mpg + hp + wt,
  data = mtcars,
  theme = "nejm",
  pvalue = TRUE
)

# Display the table (format depends on output format)
cat("Table 1: Vehicle Characteristics by Transmission Type\n")
print(bp)

## ----apply-theme--------------------------------------------------------------
# Create blueprint without theme
bp_unthemed <- table1(
  transmission ~ mpg + hp,
  data = mtcars
)

# Apply theme afterward
bp_themed <- apply_theme(bp_unthemed, "lancet")

cat("Theme applied to existing blueprint\n")

## ----theme-structure----------------------------------------------------------
# Examine theme structure
nejm_theme <- get_theme("nejm")

cat("NEJM Theme Structure:\n")
cat("- name:", nejm_theme$name, "\n")
cat("- theme_name:", nejm_theme$theme_name, "\n")
cat("- decimal_places:", nejm_theme$decimal_places, "\n")
cat("- css_class:", nejm_theme$css_class, "\n")
cat("- header_separator:", nejm_theme$header_separator, "\n")
cat("\nCSS Properties:\n")
for (prop in names(nejm_theme$css_properties)) {
  cat("  -", prop, ":", nejm_theme$css_properties[[prop]], "\n")
}

## ----dimension-rules----------------------------------------------------------
# Get dimension rules from a theme
theme <- get_theme("nejm")

if (!is.null(theme$dimension_rules)) {
  cat("Dimension Rules:\n")
  str(theme$dimension_rules)
} else {
  cat("No custom dimension rules defined\n")
}

## ----format-specific----------------------------------------------------------
# Advanced theme with format-specific properties
publication_theme <- create_custom_theme(
  name = "Publication",
  base_theme = "nejm",
  decimal_places = 1,
  font_family = "Georgia, serif",
  background_color = "#fefcf0"
)

# This theme works across all formats automatically
# Format-specific rendering adjusts appearance
cat("Publication theme created\n")

## ----test-theme---------------------------------------------------------------
# Test theme with different data types
test_data <- mtcars[1:10, ]
test_data$group <- factor(c(rep("A", 5), rep("B", 5)))

bp_test <- table1(
  group ~ mpg + hp + wt + cyl,
  data = test_data,
  theme = "nejm"
)

# Verify appearance
cat("Testing custom theme...\n")

## ----error-example-eval, eval = FALSE-----------------------------------------
# # This will use console as fallback
# my_table <- table1(x ~ y, data = df, theme = "nonexistent")

## ----css-formats--------------------------------------------------------------
# CSS only applies to HTML/LaTeX output
bp <- table1(transmission ~ mpg, data = mtcars, theme = "nejm")

# Console: plain text, no CSS
console_output <- render_console(bp)

# HTML: CSS applied
html_output <- render_html(bp)

# LaTeX: LaTeX formatting applied
latex_output <- render_latex(bp)

