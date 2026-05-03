# ============================================================================
# Theme Integration Tests - Comprehensive Coverage
# ============================================================================
#
# This test suite verifies:
# 1. Theme system works correctly across all output formats
# 2. Theme switching produces expected output
# 3. Theme customization works as intended
# 4. All built-in themes render without errors
# 5. Theme metadata is preserved through pipeline
#


# ============================================================================
# Setup: Sample Data
# ============================================================================

# Prepare test data
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
mtcars$engine <- factor(ifelse(mtcars$vs == 1, "V-Engine", "Straight"))

test_data <- mtcars[1:20, ]  # Small subset for faster tests

# ============================================================================
# Test Suite 1: Theme Availability and Registration
# ============================================================================

themes <- list_available_themes()

expect_is(themes, "character")
expect_length(themes, 6)  # console, nejm, lancet, jama, bmj, simple
expect_true("console" %in% themes)
expect_true("nejm" %in% themes)


themes <- list_available_themes()

for (theme_name in themes) {
  theme <- get_theme(theme_name)
  expect_is(theme, "table1_theme")
  expect_equal(theme$theme_name, theme_name)
}


# ============================================================================
# Test Suite 2: Theme Retrieval and Fallback
# ============================================================================

theme_nejm <- get_theme("nejm")

expect_is(theme_nejm, "table1_theme")
expect_equal(theme_nejm$name, "New England Journal of Medicine")
expect_equal(theme_nejm$decimal_places, 1)


theme_unknown <- get_theme("unknown_theme_xyz")

# Should return console theme as fallback
expect_is(theme_unknown, "table1_theme")
expect_equal(theme_unknown$theme_name, "console")


theme_default <- get_theme(NULL)

expect_is(theme_default, "table1_theme")
expect_equal(theme_default$theme_name, "console")


# ============================================================================
# Test Suite 3: Theme Application to Blueprints
# ============================================================================

bp <- table1(transmission ~ mpg, data = test_data, theme = "nejm")

expect_is(bp, "table1_blueprint")
expect_is(bp$metadata$theme, "table1_theme")
expect_equal(bp$metadata$theme$name, "New England Journal of Medicine")


# Create blueprint without explicit theme
bp <- table1(transmission ~ mpg, data = test_data)

# Apply theme after creation
bp_themed <- apply_theme(bp, "lancet")

expect_is(bp_themed$metadata$theme, "table1_theme")
expect_equal(bp_themed$metadata$theme$name, "The Lancet")


bp <- table1(transmission ~ mpg, data = test_data)

# Invalid blueprint should error
expect_error(apply_theme("not_a_blueprint", "nejm"))

# Invalid theme should error
expect_error(apply_theme(bp, 123))


# ============================================================================
# Test Suite 4: Theme Properties and Structure
# ============================================================================

required_fields <- c("name", "decimal_places", "css_properties", "dimension_rules")
themes <- list_available_themes()

for (theme_name in themes) {
  theme <- get_theme(theme_name)
  for (field in required_fields) {
    expect_true(field %in% names(theme),
               info = paste("Theme", theme_name, "missing field", field))
  }
}


themes <- list_available_themes()

for (theme_name in themes) {
  theme <- get_theme(theme_name)
  css_props <- theme$css_properties

  expect_is(css_props, "list")
  expect_true(all(sapply(css_props, is.character)),
             info = paste("Theme", theme_name, "has non-character CSS properties"))
}


themes <- list_available_themes()
valid_separators <- c("text", "line", "space", "none")
valid_presentations <- c("inline", "separate_row", "footnote")

for (theme_name in themes) {
  theme <- get_theme(theme_name)
  rules <- theme$dimension_rules

  if (!is.null(rules)) {
    if (!is.null(rules$factor_separator)) {
      expect_true(rules$factor_separator %in% valid_separators,
                 info = paste("Theme", theme_name, "has invalid factor_separator"))
    }
    if (!is.null(rules$missing_presentation)) {
      expect_true(rules$missing_presentation %in% valid_presentations,
                 info = paste("Theme", theme_name, "has invalid missing_presentation"))
    }
  }
}


# ============================================================================
# Test Suite 5: Theme Customization
# ============================================================================

custom <- create_custom_theme("Custom1", base_theme = "nejm")

expect_is(custom, "table1_theme")
expect_equal(custom$name, "Custom1")


custom <- create_custom_theme(
  "Custom2",
  base_theme = "lancet",
  decimal_places = 3,
  font_family = "Courier"
)

expect_equal(custom$decimal_places, 3)
expect_equal(custom$css_properties$font_family, "Courier")


theme <- get_theme("nejm")
customized <- customize_theme("nejm",
                             decimal_places = 2,
                             css_properties = list(font_size = "14px"))

expect_equal(customized$decimal_places, 2)
expect_equal(customized$css_properties$font_size, "14px")


# ============================================================================
# Test Suite 6: Theme Rendering Across Formats
# ============================================================================

themes <- list_available_themes()

for (theme_name in themes) {
  bp <- table1(transmission ~ mpg, data = test_data, theme = theme_name)
  output <- render_console(bp)

  expect_is(output, "character")
  expect_length(output, nrow(bp))
}


themes <- list_available_themes()

for (theme_name in themes) {
  bp <- table1(transmission ~ mpg, data = test_data, theme = theme_name)
  output <- render_latex(bp)

  expect_is(output, "character")
  # LaTeX output should be non-empty and contain content
  expect_true(nchar(paste(output, collapse = " ")) > 0)
}


themes <- list_available_themes()

for (theme_name in themes) {
  bp <- table1(transmission ~ mpg, data = test_data, theme = theme_name)
  output <- render_html(bp)

  expect_is(output, "character")
  expect_true(any(grepl("<table", output)))
  expect_true(any(grepl("</table>", output)))
}


# ============================================================================
# Test Suite 7: Theme Interaction with Table Options
# ============================================================================

bp_pval <- table1(transmission ~ mpg + hp,
                 data = test_data,
                 theme = "nejm",
                 pvalue = TRUE)

expect_is(bp_pval$metadata$theme, "table1_theme")
output <- render_console(bp_pval)
# pvalue option should create output
expect_is(output, "character")
expect_true(length(output) > 0)


bp_totals <- table1(transmission ~ mpg + hp,
                   data = test_data,
                   theme = "lancet",
                   totals = TRUE)

expect_is(bp_totals$metadata$theme, "table1_theme")
output <- render_console(bp_totals)
# totals option should create output
expect_is(output, "character")
expect_true(length(output) > 0)


test_data_missing <- test_data
test_data_missing$mpg[1:3] <- NA

bp_missing <- table1(transmission ~ mpg,
                    data = test_data_missing,
                    theme = "jama",
                    missing = TRUE)

expect_is(bp_missing$metadata$theme, "table1_theme")
output <- render_console(bp_missing)
expect_is(output, "character")


# ============================================================================
# Test Suite 8: Theme Interaction with Stratification
# ============================================================================

bp_strata <- table1(transmission ~ mpg + hp,
                   data = test_data,
                   strata = "engine",
                   theme = "nejm")

expect_is(bp_strata$metadata$theme, "table1_theme")
output <- render_console(bp_strata)
expect_true(any(grepl("Engine", output)))


themes <- list_available_themes()

for (theme_name in themes) {
  bp <- table1(transmission ~ mpg,
              data = test_data,
              strata = "engine",
              theme = theme_name)

  console_out <- render_console(bp)
  latex_out <- render_latex(bp)
  html_out <- render_html(bp)

  expect_is(console_out, "character")
  expect_true(length(console_out) > 0)
  expect_true(any(grepl("Engine", console_out)))
}


# ============================================================================
# Test Suite 9: Theme Decimal Place Handling
# ============================================================================

# NEJM uses 1 decimal place
bp_nejm <- table1(transmission ~ mpg, data = test_data, theme = "nejm")
# BMJ uses 2 decimal places
bp_bmj <- table1(transmission ~ mpg, data = test_data, theme = "bmj")

expect_equal(bp_nejm$metadata$theme$decimal_places, 1)
expect_equal(bp_bmj$metadata$theme$decimal_places, 2)


# ============================================================================
# Test Suite 10: CSS Generation and Theme CSS
# ============================================================================

css <- generate_theme_css()

expect_is(css, "character")
expect_true(nchar(css) > 0)
expect_true(any(grepl("\\.table1", css)))
expect_true(any(grepl("font-family:", css)))


css <- generate_theme_css()
themes <- list_available_themes()

for (theme_name in themes) {
  theme <- get_theme(theme_name)
  css_class <- theme$css_class

  expect_true(grepl(css_class, css),
             info = paste("CSS missing class for theme", theme_name))
}


# ============================================================================
# Test Suite 11: Edge Cases and Error Handling
# ============================================================================

custom <- create_custom_theme("NoCSS")

expect_is(custom$css_properties, "list")
expect_true("font_family" %in% names(custom$css_properties))


empty_data <- test_data[0, ]

expect_error(
  table1(transmission ~ mpg, data = empty_data, theme = "nejm"),
  "empty"
)


bp_nejm <- table1(transmission ~ mpg, data = test_data, theme = "nejm")
bp_lancet <- table1(transmission ~ mpg, data = test_data, theme = "lancet")

# Apply different themes to same blueprint structure
output_nejm <- render_console(bp_nejm)
output_lancet <- render_console(bp_lancet)

# Outputs should be different
expect_false(identical(output_nejm, output_lancet))


# ============================================================================
# Test Suite 12: Theme Performance
# ============================================================================

bp <- table1(transmission ~ mpg, data = test_data)

timing <- system.time({
  for (i in 1:10) {
    apply_theme(bp, "nejm")
  }
})

# Should complete in under 1 second for 10 applications
expect_true(timing["elapsed"] < 1.0)


# ============================================================================
# Summary
# ============================================================================
# This comprehensive test suite verifies:
# ✓ Theme system initialization and registration
# ✓ Theme retrieval and fallback mechanisms
# ✓ Theme application to blueprints
# ✓ Theme properties and structure validation
# ✓ Theme customization capabilities
# ✓ Cross-format rendering (console, LaTeX, HTML)
# ✓ Interaction with table options (pvalue, totals, missing)
# ✓ Interaction with stratified analysis
# ✓ Decimal place and formatting rules
# ✓ CSS generation and styling
# ✓ Edge cases and error conditions
# ✓ Performance characteristics
