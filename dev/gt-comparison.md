# gt vs zztable1: Capability Comparison

## Overview

The gt R package (grammar of tables) and zztable1 occupy different
niches in the table-creation ecosystem. gt is a general-purpose table
rendering engine that takes a pre-computed data frame and provides
extraordinary control over presentation. zztable1 is a domain-specific
statistical table generator that takes raw data and a formula, computes
summary statistics, and renders a publication-ready Table 1.

gt is strictly more capable at the rendering and formatting layer.
zztable1 is strictly more capable at the statistical computation layer.

## gt Architecture

gt uses a pipeline/builder pattern with an S3 class (`gt_tbl`)
containing 17 internal slots for data, formatting, styling, footnotes,
summaries, and options. The workflow is:

1. Pass a data frame to `gt()` to create the table object
2. Chain modification functions via `|>` to layer formatting and
   structure
3. Render to the desired output format

Like zztable1's blueprint, gt uses lazy evaluation: formatting,
styling, and summary computations are stored as instructions and
executed only at render time. gt exposes 211 exported functions and
194 configurable display options.

## What gt Can Do That zztable1 Cannot

### Inline visualizations

`cols_nanoplot()` renders sparklines, bar charts, and boxplots inside
cells as SVG. `fmt_bins()` renders inline histograms.
`ggplot_image()` embeds ggplot objects. zztable1 cells contain only
text.

### Conditional cell styling

`data_color()` applies continuous color scales to cell backgrounds
with automatic text contrast using the APCA algorithm.
`tab_style_body()` targets cells by value, regex pattern, or
arbitrary predicate function. zztable1 has theme-level row striping
but no per-cell conditional formatting.

### Embedded media

`fmt_image()`, `fmt_icon()` (Font Awesome), `fmt_flag()` (country
flags), and `fmt_markdown()` (rendered markdown) can all appear
within cells. zztable1 cells are plain strings.

### Interactive tables

`opt_interactive()` adds JavaScript-powered sorting, filtering,
search, pagination, and row selection via a single function call.
zztable1 produces static output only.

### Column spanners

`tab_spanner()` creates multi-level hierarchical column headers
(spanners containing spanners). zztable1 has a flat column header
row.

### Summary rows

`summary_rows()` and `grand_summary_rows()` compute subtotals and
grand totals per row group with arbitrary aggregation functions,
placed at top or bottom. zztable1 has a totals column but not
per-group summary rows.

### 30 domain-specific formatters

Chemical formulas (`fmt_chem`), scientific units (`fmt_units`),
currencies, durations, fractions, percentages -- each aware of
locale and output format. zztable1 has three built-in numeric
summary types plus custom functions.

### Fine-grained footnote targeting

gt attaches footnotes to any of 14 table regions (specific cells,
column spanners, summary rows, stubhead, etc.) via the `cells_*`
location DSL. zztable1 targets footnotes at the variable or column
level only.

### Output formats

gt renders to 8 formats: HTML, LaTeX, RTF, Word/DOCX, PNG, PDF,
Typst, and grid grobs. zztable1 renders to console, HTML, and
LaTeX.

### Dynamic per-row formatting

`from_column()` lets any formatting parameter resolve its value from
a data column, enabling row-specific decimal places, colors, or
suffixes without loops. zztable1 applies uniform formatting per
variable type.

### Configurable options

gt exposes 194 options covering every visual aspect of the table
(padding, font, border style per region). zztable1 themes expose
roughly 10 parameters.

## What zztable1 Does That gt Cannot

### Formula-driven table specification

`arm ~ age + sex + bmi` declaratively specifies a Table 1 from raw
data. gt requires the user to pre-compute all summary statistics and
pass a ready-made data frame.

### Automatic statistical testing

P-values with configurable tests (t-test, Welch, ANOVA,
Kruskal-Wallis, Fisher, chi-squared) and automatic fallback when
assumptions are not met. gt has no statistical computation layer.

### Automatic variable type detection

Factors receive n (%), numerics receive mean (SD), and missing data
rows are added conditionally based on actual NA presence. gt
displays whatever data frame it is given.

### Stratified analysis

`strata = "site"` repeats the full table within each stratum level.
Achieving this in gt requires manual pre-computation and row-group
assembly.

### Lazy cell-level computation

Individual cells store unevaluated R expressions that are executed
on demand. gt's lazy evaluation applies to formatting and styling
but not to the underlying data values.

## Architectural Comparison

| Aspect | gt | zztable1 |
|:---|:---|:---|
| Input | Pre-computed data frame | Raw data + formula |
| Core pattern | Pipeline/builder | Formula -> blueprint -> render |
| Lazy evaluation | Formatting and styling | Cell computations |
| Storage | 17-slot list | Sparse environment (hash table) |
| Cell content | Text, images, icons, plots | Text only |
| Statistical tests | None | 7 built-in with fallback |
| Themes | 194 fine-grained options | 6 journal themes |
| Footnote targeting | 14 region types | Variable and column level |
| Output formats | 8 (HTML, LaTeX, RTF, DOCX, PNG, PDF, Typst, grob) | 3 (console, HTML, LaTeX) |
| Interactivity | JavaScript sorting/filtering | None |
| Column spanners | Multi-level hierarchical | Flat headers |

## Complementary Integration

A natural architecture would use zztable1's blueprint to compute
the statistics, then convert the evaluated blueprint to a data frame
and hand it to gt for rendering. This would combine zztable1's
formula-driven statistical computation with gt's rich formatting,
inline visualizations, interactive output, and broad format support.
