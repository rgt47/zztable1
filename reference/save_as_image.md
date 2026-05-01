# Save a Table1 Blueprint as an Image

Renders a `table1_blueprint` to PDF, PNG, or SVG via the
`zztab2fig::zzt2f()` Typst pipeline. Intended for workflows that need a
pixel image of the table, including terminal-based display via graphics
protocols (Kitty, iTerm2).

## Usage

``` r
save_as_image(
  blueprint,
  filename = "table1",
  sub_dir = tempdir(),
  format = c("png", "pdf", "svg"),
  theme = NULL,
  dpi = 300L,
  ...
)
```

## Arguments

- blueprint:

  A `table1_blueprint`.

- filename:

  Output file base name (no extension). Defaults to `"table1"`.

- sub_dir:

  Output directory. Defaults to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html).

- format:

  One of `"png"`, `"pdf"`, or `"svg"`.

- theme:

  Optional theme name passed to `zzt2f()`.

- dpi:

  PNG resolution.

- ...:

  Additional arguments forwarded to `zzt2f()`.

## Value

Invisibly, the path to the rendered file.
