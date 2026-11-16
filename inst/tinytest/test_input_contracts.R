# Regression tests for input-contract defects reported 2026-11-16:
# general footnotes given as a list, unsupported footnote types, invalid
# layout and test names, knit_print registration, list_custom_themes().

library(zztable1)

mt <- mtcars
mt$transmission <- factor(ifelse(mt$am == 1, "Manual", "Auto"))
mt$cyl_f <- factor(mt$cyl)

# Defect 1: footnotes$general as a list was silently dropped
bp_chr <- table1(transmission ~ mpg, data = mt,
                 footnotes = list(general = c("Note A", "Note B")))
bp_lst <- table1(transmission ~ mpg, data = mt,
                 footnotes = list(general = list("Note A", "Note B")))
expect_identical(
  bp_lst$metadata$footnote_list, c("Note A", "Note B"),
  info = "defect 1: general footnotes given as a list are kept"
)
expect_identical(
  bp_lst$metadata$footnote_list, bp_chr$metadata$footnote_list,
  info = "defect 1: list and character general footnotes are equivalent"
)
rendered <- capture.output(display_table(bp_lst, mt))
expect_true(
  any(grepl("Note A", rendered, fixed = TRUE)) &&
    any(grepl("Note B", rendered, fixed = TRUE)),
  info = "defect 1: list general footnotes appear in console output"
)

# Defect 2: footnotes$cells was ignored without notice
expect_warning(
  table1(transmission ~ mpg, data = mt,
         footnotes = list(cells = list("1_2" = "Cell note"))),
  "Unsupported footnote type",
  info = "defect 2: footnotes$cells warns that it is unsupported"
)
expect_silent(
  table1(transmission ~ mpg, data = mt,
         footnotes = list(variables = list(mpg = "Miles per gallon"),
                          general = "Note")),
  info = "defect 2: supported footnote types do not warn"
)

# Defect 3: invalid layout was accepted silently
expect_error(
  table1(transmission ~ mpg, data = mt, layout = "bogus"),
  "'layout' must be one of",
  info = "defect 3: unknown layout is an error"
)
expect_error(
  table1(transmission ~ mpg, data = mt, layout = "c"),
  "'layout' must be one of",
  info = "defect 3: partial layout names are not matched"
)
for (lay in c("console", "latex", "html")) {
  expect_inherits(
    table1(transmission ~ mpg, data = mt, layout = lay),
    "table1_blueprint",
    info = paste("defect 3: valid layout accepted:", lay)
  )
}

# Defect 4: unknown test names were accepted silently
expect_error(
  table1(transmission ~ mpg, data = mt, continuous_test = "wilcox"),
  "'continuous_test' must be one of",
  info = "defect 4: unknown continuous_test is an error"
)
expect_error(
  table1(transmission ~ cyl_f, data = mt, categorical_test = "gtest"),
  "'categorical_test' must be one of",
  info = "defect 4: unknown categorical_test is an error"
)
expect_error(
  table1(transmission ~ cyl_f, data = mt, categorical_test = "kruskal"),
  "'categorical_test' must be one of",
  info = "defect 4: a continuous test is not a valid categorical_test"
)

# Defect 5: knit_print method was exported but not registered
if (requireNamespace("knitr", quietly = TRUE)) {
  bp <- table1(transmission ~ mpg, data = mt)
  out <- knitr::knit_print(bp)
  expect_inherits(
    out, "knit_asis",
    info = "defect 5: knitr::knit_print dispatches to the table1 method"
  )
}

# Defect 6: list_custom_themes() reported the built-in 'simple' theme
expect_false(
  "simple" %in% list_custom_themes(),
  info = "defect 6: list_custom_themes() excludes built-in 'simple'"
)
expect_error(
  unregister_theme("simple"),
  "Cannot unregister built-in theme",
  info = "defect 6: built-in 'simple' theme cannot be unregistered"
)
expect_true(
  "simple" %in% list_available_themes(),
  info = "defect 6: 'simple' remains registered"
)
