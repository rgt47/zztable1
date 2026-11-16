# Regression test: register_theme() and unregister_theme() failed on any
# installed copy with "cannot change value of locked binding for
# '.theme_registry'", and create_custom_theme() kept the base theme's
# theme_name, so the documented example registered nothing. Under
# R CMD check these assertions run against the installed package.
# See docs/pack_review_2026-08-15.md section 3.1.

key <- 'ZztRegressionTheme'
builtin <- c('console', 'nejm', 'lancet', 'jama', 'bmj', 'simple')
suppressMessages(unregister_theme(key))

custom <- create_custom_theme(key, base_theme = 'nejm', decimal_places = 3)

expect_equal(custom$theme_name, key,
  info = 'locked registry: create_custom_theme() keys the theme by name')
expect_equal(custom$css_class, 'table1-zztregressiontheme',
  info = 'locked registry: css_class lowercases before stripping')

reg <- tryCatch(suppressMessages(register_theme(custom)),
  error = function(e) e)
expect_false(inherits(reg, 'error'),
  info = 'locked registry: register_theme() does not error when installed')
expect_true(key %in% list_available_themes(),
  info = 'locked registry: registered theme is listed')
expect_true(key %in% list_custom_themes(),
  info = 'locked registry: registered theme is listed as custom')
expect_true(all(builtin %in% list_available_themes()),
  info = 'locked registry: built-in themes survive registration')

expect_message(register_theme(custom), 'already registered',
  info = 'locked registry: re-registration without overwrite is refused')
expect_equal(get_theme(key)$decimal_places, 3,
  info = 'locked registry: refused re-registration keeps the stored theme')

custom5 <- create_custom_theme(key, base_theme = 'nejm', decimal_places = 5)
ow <- tryCatch(suppressMessages(register_theme(custom5, overwrite = TRUE)),
  error = function(e) e)
expect_false(inherits(ow, 'error'),
  info = 'locked registry: overwrite = TRUE does not error when installed')
expect_equal(get_theme(key)$decimal_places, 5,
  info = 'locked registry: overwrite = TRUE replaces the stored theme')
suppressMessages(register_theme(custom, overwrite = TRUE))

d <- data.frame(arm = rep(c('A', 'B'), each = 4), x = c(1:4, 11:14))
expect_silent(table1(arm ~ x, data = d, theme = key),
  info = 'locked registry: table1() finds the theme without a fallback warning')
bp <- suppressWarnings(table1(arm ~ x, data = d, theme = key))
expect_equal(bp$metadata$theme$theme_name, key,
  info = 'locked registry: table1() resolves the registered theme by name')
out <- paste(utils::capture.output(print(bp)), collapse = '\n')
expect_true(grepl('1.291', out, fixed = TRUE),
  info = 'locked registry: table1() applies the registered decimal_places')

unreg <- tryCatch(suppressMessages(unregister_theme(key)),
  error = function(e) e)
expect_false(inherits(unreg, 'error'),
  info = 'locked registry: unregister_theme() does not error when installed')
expect_false(key %in% list_available_themes(),
  info = 'locked registry: unregistered theme is removed')
expect_true(all(builtin %in% list_available_themes()),
  info = 'locked registry: built-in themes survive unregistration')
expect_error(unregister_theme('nejm'), 'built-in',
  info = 'locked registry: built-in themes cannot be unregistered')
