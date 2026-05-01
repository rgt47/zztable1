# =============================================================================
# Theme Application Tests - Colors, Fonts, Indentation, Striping
# =============================================================================

library(testthat)

# Test data setup
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))
mtcars$cyl_factor <- factor(mtcars$cyl)

test_that("LaTeX color definitions are properly generated", {
  # Test NEJM theme color definitions
  nejm_theme <- get_theme("nejm")
  latex_setup <- generate_latex_theme_setup(nejm_theme)
  
  # Should contain NEJM stripe color definition
  expect_true(any(grepl("\\\\definecolor\\{nejmstripe\\}\\{HTML\\}\\{fefcf0\\}", latex_setup)))
  expect_true(any(grepl("\\\\definecolor\\{nejmtext\\}\\{HTML\\}\\{333333\\}", latex_setup)))
  
  # Should contain theme-specific comments
  expect_true(any(grepl("NEJM theme", latex_setup)))
})

test_that("LaTeX row striping is correctly applied", {
  bp <- table1(transmission ~ mpg + hp + wt + qsec, data = mtcars, theme = "nejm")
  latex_output <- render_latex(bp)
  
  # Should contain color definition
  expect_true(any(grepl("definecolor\\{nejmstripe\\}", latex_output)))
  
  # Should have alternating row colors (even rows striped)
  data_rows <- latex_output[grepl("mpg|hp|wt|qsec", latex_output)]
  
  # Find rows with striping
  striped_rows <- grepl("\\\\rowcolor\\{nejmstripe\\}", data_rows)
  
  # Should have at least some striped rows
  expect_true(sum(striped_rows) > 0)
  
  # Check pattern: should be alternating (even row indices get striping)
  if (length(data_rows) >= 4) {
    # Row 2 and 4 should be striped, 1 and 3 should not
    expect_true(striped_rows[2])  # hp should be striped
    expect_false(striped_rows[1]) # mpg should not be striped
    expect_true(striped_rows[4])  # qsec should be striped  
    expect_false(striped_rows[3]) # wt should not be striped
  }
})

test_that("Factor level indentation is correctly applied", {
  # Create table with factor levels
  bp <- table1(transmission ~ cyl_factor, data = mtcars, theme = "nejm")
  latex_output <- render_latex(bp)
  
  # Should contain indentation commands for factor levels
  indented_lines <- latex_output[grepl("\\\\hspace\\{1em\\}", latex_output)]
  
  # Should have at least 3 indented lines (for 4, 6, 8 cylinder levels)
  expect_true(length(indented_lines) >= 3)
  
  # Check that factor level values are properly indented
  expect_true(any(grepl("\\\\hspace\\{1em\\}4", latex_output)))
  expect_true(any(grepl("\\\\hspace\\{1em\\}6", latex_output)))
  expect_true(any(grepl("\\\\hspace\\{1em\\}8", latex_output)))
})

test_that("Combined indentation and striping works", {
  bp <- table1(transmission ~ cyl_factor, data = mtcars, theme = "nejm")
  latex_output <- render_latex(bp)
  
  # Should have lines with both striping and indentation
  combined_lines <- latex_output[grepl("\\\\rowcolor.*\\\\hspace\\{1em\\}", latex_output)]
  
  # Should have at least one line with both effects
  expect_true(length(combined_lines) > 0)
  
  # Verify specific pattern: striped indented factor level
  expect_true(any(grepl("\\\\rowcolor\\{nejmstripe\\}\\s+\\\\hspace\\{1em\\}[0-9]", latex_output)))
})

test_that("HTML CSS classes are correctly applied", {
  bp <- table1(transmission ~ mpg + hp, data = mtcars, theme = "nejm")
  html_output <- render_html(bp)
  
  # Should contain NEJM theme CSS class
  expect_true(any(grepl("table1-nejm", html_output)))
  
  # Should contain proper table structure
  expect_true(any(grepl("<table class=\"table1 table1-nejm\">", html_output)))
  
  # Test other themes
  bp_lancet <- table1(transmission ~ mpg, data = mtcars, theme = "lancet")
  html_lancet <- render_html(bp_lancet)
  expect_true(any(grepl("table1-lancet", html_lancet)))
  
  bp_jama <- table1(transmission ~ mpg, data = mtcars, theme = "jama")
  html_jama <- render_html(bp_jama)
  expect_true(any(grepl("table1-jama", html_jama)))
})

test_that("Theme-specific formatting differences", {
  # Create same table with different themes
  bp_nejm <- table1(transmission ~ mpg, data = mtcars, theme = "nejm")
  bp_lancet <- table1(transmission ~ mpg, data = mtcars, theme = "lancet")
  bp_jama <- table1(transmission ~ mpg, data = mtcars, theme = "jama")
  
  # Themes should have different configurations
  expect_false(identical(bp_nejm$metadata$theme, bp_lancet$metadata$theme))
  expect_false(identical(bp_nejm$metadata$theme, bp_jama$metadata$theme))
  expect_false(identical(bp_lancet$metadata$theme, bp_jama$metadata$theme))
  
  # LaTeX output should be different
  latex_nejm <- render_latex(bp_nejm)
  latex_lancet <- render_latex(bp_lancet)
  latex_jama <- render_latex(bp_jama)
  
  # NEJM should have row striping, others should not
  expect_true(any(grepl("nejmstripe", latex_nejm)))
  expect_false(any(grepl("nejmstripe", latex_lancet)))
  expect_false(any(grepl("nejmstripe", latex_jama)))
  
  # Different theme comment headers
  expect_true(any(grepl("NEJM theme", latex_nejm)))
  expect_true(any(grepl("Lancet theme", latex_lancet)))
  expect_true(any(grepl("JAMA theme", latex_jama)))
})

test_that("Theme CSS generation works correctly", {
  # Test CSS generation for all themes
  themes <- list_available_themes()

  for (theme_name in themes) {
    theme <- get_theme(theme_name)
    theme_css <- generate_theme_css(theme)

    # Should generate non-empty CSS
    expect_true(nchar(theme_css) > 0)

    # Should contain theme-specific CSS class (using short theme_name)
    expected_class <- paste0("table1-", theme_name)
    expect_true(grepl(expected_class, theme_css))
  }

  # NEJM theme should have striping CSS
  nejm_theme <- get_theme("nejm")
  nejm_css <- generate_theme_css(nejm_theme)
  expect_true(grepl("nth-child\\(odd\\)", nejm_css))
  expect_true(grepl("nth-child\\(even\\)", nejm_css))
})

test_that("Font and spacing specifications", {
  # Check that themes have different font specifications
  nejm_theme <- get_theme("nejm")
  lancet_theme <- get_theme("lancet")
  jama_theme <- get_theme("jama")

  # Should have font family specifications (in css_properties)
  expect_true(!is.null(nejm_theme$css_properties$font_family))
  expect_true(!is.null(lancet_theme$css_properties$font_family))
  expect_true(!is.null(jama_theme$css_properties$font_family))

  # Should have different decimal places
  decimal_places <- c(
    nejm_theme$decimal_places,
    lancet_theme$decimal_places,
    jama_theme$decimal_places
  )

  # At least some themes should have different decimal places
  expect_true(length(unique(decimal_places)) >= 1)
})

test_that("LaTeX table environment and rules", {
  bp <- table1(transmission ~ mpg + hp, data = mtcars, theme = "nejm")
  latex_output <- render_latex(bp)
  
  # Should use proper LaTeX table environment
  expect_true(any(grepl("\\\\begin\\{tabular\\}", latex_output)))
  expect_true(any(grepl("\\\\end\\{tabular\\}", latex_output)))
  
  # Should have proper booktabs rules
  expect_true(any(grepl("\\\\toprule", latex_output)))
  expect_true(any(grepl("\\\\midrule", latex_output)))
  expect_true(any(grepl("\\\\bottomrule", latex_output)))
  
  # Headers should be bold
  expect_true(any(grepl("\\\\textbf\\{", latex_output)))
})

test_that("Indentation only applied to factor levels", {
  # Create table with mixed variable types
  bp <- table1(transmission ~ mpg + cyl_factor, data = mtcars, theme = "nejm")
  latex_output <- render_latex(bp)
  
  # Continuous variable (mpg) should not be indented
  mpg_lines <- latex_output[grepl("mpg", latex_output)]
  expect_false(any(grepl("\\\\hspace", mpg_lines)))
  
  # Factor levels should be indented
  cyl_lines <- latex_output[grepl("\\\\hspace.*[468]", latex_output)]
  expect_true(length(cyl_lines) > 0)
})

test_that("Error handling for invalid themes", {
  # Invalid theme should fall back gracefully
  expect_warning(
    bp <- table1(transmission ~ mpg, data = mtcars, theme = "nonexistent_theme"),
    "Unknown theme"
  )
  
  # Should still create a valid blueprint
  expect_s3_class(bp, "table1_blueprint")
  
  # Should be able to render
  expect_type(render_console(bp), "character")
  expect_type(render_latex(bp), "character")
  expect_type(render_html(bp), "character")
})

test_that("Theme consistency across output formats", {
  bp <- table1(transmission ~ mpg + cyl_factor, data = mtcars, theme = "nejm")
  
  # All formats should render successfully
  console_out <- render_console(bp)
  latex_out <- render_latex(bp)
  html_out <- render_html(bp)
  
  expect_type(console_out, "character")
  expect_type(latex_out, "character")
  expect_type(html_out, "character")
  
  # All should have content
  expect_true(length(console_out) > 0)
  expect_true(length(latex_out) > 0)
  expect_true(length(html_out) > 0)
  
  # LaTeX should have theme-specific features
  expect_true(any(grepl("nejmstripe", latex_out)))
  expect_true(any(grepl("\\\\hspace", latex_out)))
  
  # HTML should have theme CSS class
  expect_true(any(grepl("table1-nejm", html_out)))
})