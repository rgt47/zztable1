# Contributing to zztable1

Thank you for your interest in contributing. This document describes the
expected workflow for proposing changes, reporting issues, and
submitting pull requests.

## Reporting issues

Before opening an issue, please search existing issues at
<https://github.com/rgt47/zztable1/issues> to confirm the problem has
not already been reported. When opening a new issue, include:

- A minimal reproducible example (a `reprex::reprex()` is preferred).
- The output of
  [`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html).
- The version of zztable1 in use (`packageVersion('zztable1')`).
- The expected behaviour and the observed behaviour.
- For rendering issues, the target output format (console, HTML, LaTeX)
  and the theme in use.

## Proposing a change

For non-trivial changes, please open an issue first to discuss the
approach. The blueprint and rendering pipeline have several extension
points and a brief design discussion saves rework.

## Pull request workflow

1.  Fork the repository and create a topic branch off `main`.

2.  Install development dependencies. zztable1 uses `renv`; restore the
    pinned environment with:

    ``` r

    renv::restore()
    ```

3.  Make your changes. Keep commits focused; prefer many small commits
    over one large one.

4.  Add or update tests in `tests/testthat/`. New exported functions
    require tests. Include cases for each output format (console, HTML,
    LaTeX) when adding rendering features.

5.  Run
    [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
    to regenerate `man/` and `NAMESPACE`.

6.  Run the full check locally:

    ``` r

    devtools::check()
    ```

    The check must pass with no errors, warnings, or notes other than
    the standard ‘New submission’ note.

7.  Update `NEWS.md` with a one-line bullet under the unreleased
    section.

8.  Open a pull request against `main`. Reference any related issues.

## Coding style

- Use the native R pipe (`|>`); avoid `%>%` in new code.
- Use `<-` for assignment, never `=`.
- Use `snake_case` for functions and variables.
- Prefer implicit returns; reserve
  [`return()`](https://rdrr.io/r/base/function.html) for early exits.
- Document all exported functions with `roxygen2`. Each must have
  `@title`, `@description`, `@param`, `@return`, and `@examples`.
- Two-space indentation. Single quotes for character literals.
- Do not add ‘what’ comments. Reserve comments for non-obvious ‘why’.

## Tests

Tests use `testthat` 3rd edition. Run with:

``` r

devtools::test()
```

For coverage reports:

``` r

covr::package_coverage()
```

## Vignettes

If your change affects user-facing behaviour, update the corresponding
vignette in `vignettes/`. Vignettes that produce PDF output are not
committed; only the `.Rmd` source is tracked. Verify the vignette
builds:

``` r

devtools::build_vignettes()
```

## Code of Conduct

By participating in this project, you agree to abide by the [Code of
Conduct](https://rgt47.github.io/zztable1/CODE_OF_CONDUCT.md).
