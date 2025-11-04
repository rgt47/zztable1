# zztable1_nextgen Development Notes

## Project Overview
Redesigning the zztable1 R package architecture while maintaining the same input interface (formula + data + options). The key innovation is moving from immediate computation to a lazy evaluation approach with a single R object output.

## Current vs Next-Gen Architecture

### Current zztable1 Approach:
- Formula → Multiple data frames → Complex binding/merging → Final data frame
- Immediate computation of all statistics
- Manual row insertion and assembly logic
- Monolithic functions with mixed concerns

### Next-Gen Approach:
- Formula → Single blueprint object → Lazy evaluation → Output on demand
- **Goal**: Interpret function arguments to:
  1. Determine dimensions of output object (rows × columns)
  2. Store computation instructions as metadata in each cell
  3. Execute calculations only when needed (print, export, etc.)

## Design Considerations

### Single R Object Requirements:
- Input compatibility with existing formula interface
- Rich metadata storage (variable types, tests, formatting)
- Multiple output formats (console, LaTeX, HTML)
- Extensibility for new variable types/export formats
- Natural fit within R ecosystem

### Lazy Evaluation Blueprint Concept:
Each cell contains computation metadata instead of results:
```r
# Example cell metadata:
list(
  type = "mean_sd",
  data_subset = expression(data$age[data$arm == "Treatment"]),
  computation = expression(paste0(round(mean(x, na.rm=TRUE), 2), " (", round(sd(x, na.rm=TRUE), 2), ")")),
  dependencies = c("data", "arm", "age"),
  format_rules = list(digits = 2)
)
```

### Key Design Questions Still Open:

1. **Cell Storage Approach:**
   - Array/Matrix: `table[i,j]` contains computation metadata
   - Data Frame: Each cell is a row with `(row, col, computation)`
   - Nested List: `table[[row]][[col]]$computation`

2. **Computation Storage:**
   - Expressions: `expression(mean(data$age[data$arm == "Treatment"]))`
   - Functions: `function(data) mean(data$age[data$arm == "Treatment"])`
   - DSL/String: `"mean(age) | filter(arm == 'Treatment')"`

3. **Execution Strategy:**
   - On-demand: Each cell computed when accessed
   - Cached: Compute once, store result alongside metadata
   - Vectorized: Compute entire rows/columns together

4. **Dimension Analysis:**
   From `table1(arm ~ age + sex + bmi, data=data)`, determine:
   - Rows: Variable headers + factor levels + summary rows
   - Columns: Group levels + Total (if requested) + p-value (if requested)

## Current Status
- [x] Analyzed existing zztable1 architecture
- [x] Identified improvement opportunities
- [x] Understood lazy evaluation blueprint concept
- [x] Choose specific implementation approach (blueprint object with cell metadata)
- [x] Design the single R object structure (Table1Blueprint class)
- [x] Implement core framework (all major components functional)
- [x] Test with example data (comprehensive vignettes created)
- [x] Medical journal theme system (NEJM, Lancet, JAMA with authentic formatting)
- [x] HTML/LaTeX/Console output formats
- [x] Stratified analysis capabilities
- [x] Complete vignette system with examples
- [x] PDF rendering quality assurance (all vignettes render to high-quality PDFs)

## Implementation Details

### Architecture Decisions Made:
1. **Cell Storage**: Nested list structure `table[[row]][[col]]` with computation metadata
2. **Computation Storage**: Function-based approach with data subsetting expressions
3. **Execution Strategy**: On-demand computation with blueprint caching
4. **Blueprint Object**: `table1_blueprint` S3 class with metadata and dimensions

### Core Components Implemented:
- `R/table1.R` - Main interface function maintaining formula compatibility
- `R/blueprint.R` - Blueprint object creation and management
- `R/cells.R` - Cell computation logic and metadata storage
- `R/rendering.R` - Multi-format output rendering (HTML, LaTeX, console)
- `R/themes.R` - Medical journal theming system
- `R/dimensions.R` - Dynamic table dimension calculation
- `R/utils.R` - Statistical computation utilities
- `R/validation_consolidated.R` - Input validation and error handling

### Medical Journal Themes:
- **NEJM Theme**: Authentic light yellow/cream striping (#fefcf0), minimal borders, ± format
- **Lancet Theme**: Clean white background, horizontal-only borders, parentheses format  
- **JAMA Theme**: Clean minimal formatting, horizontal-only borders, lettered footnotes
- **Console Theme**: Monospace font, basic styling for development/testing

### Vignette System:
- `vignettes/zztable1_nextgen_guide.Rmd` - Comprehensive package guide
- `vignettes/theming_system.Rmd` - Medical journal theme demonstrations
- `vignettes/stratified_examples.Rmd` - Multi-center trial stratified analysis
- `vignettes/dataset_examples.Rmd` - Built-in R dataset examples (rewritten for current functions)

## Recent Updates

### PDF Rendering Quality Assurance (Latest)
- **Complete vignette PDF testing**: Systematically tested all 6 main vignettes for PDF rendering quality
- **Fixed footnote rendering error**: Resolved `integerOneIndex` error in `render_footnotes()` function by adding proper bounds checking when no footnote markers present
- **Unicode character compatibility**: Replaced LaTeX-incompatible Unicode characters (±, α, χ²) with ASCII equivalents (+/-, alpha, chi-squared)
- **LaTeX dependency management**: Added comprehensive LaTeX packages (colortbl, xcolor, booktabs, threeparttable) to all vignette YAML headers
- **Source import standardization**: Updated all vignettes to use consistent `source("../R/...")` pattern instead of problematic `devtools::load_all()` or missing file references
- **Function name corrections**: Fixed `list_themes()` → `list_available_themes()` function call
- **All vignettes now render successfully**: 6 high-quality PDFs generated with proper table formatting and medical journal styling

**PDF Test Results:**
- `customizing_statistics.pdf` (342KB) - Custom summary function examples
- `dataset_examples.pdf` (338KB) - Comprehensive theme showcase with built-in datasets  
- `stratified_examples.pdf` (253KB) - Multi-center trial stratified analysis examples
- `theming_system.pdf` (228KB) - Medical journal theme demonstrations
- `toothgrowth_example.pdf` (326KB) - Complete clinical trial analysis example
- `zztable1_nextgen_guide.pdf` (270KB) - Comprehensive package guide

### Blueprint Construction Documentation
- **Created comprehensive technical guide**: Written 10-page `Blueprint_Construction_Guide.md` covering the complete blueprint construction sequence
- **Detailed R environments analysis**: Deep technical dive into sparse storage implementation using R environments as hash tables
- **Function-by-function documentation**: Expanded coverage of each component including `table1()`, `parse_formula()`, `analyze_dimensions()`, `Table1Blueprint()`, etc.
- **Performance characteristics documentation**: Memory efficiency analysis showing 60-80% reduction through sparse storage
- **Extension points documentation**: Coverage of custom statistical functions, themes, and cell types

### Statistical Test Framework Enhancement
- **Added configurable statistical tests**: New parameters `continuous_test` and `categorical_test` allow users to specify test types
- **Continuous variable tests**: Support for `"ttest"`, `"anova"`, `"welch"`, `"kruskal"` tests  
- **Categorical variable tests**: Support for `"fisher"` and `"chisq"` tests with automatic fallback
- **Enhanced numeric summaries**: Added `"median_range"`, `"mean_ci"` summary options
- **Theme-aware dimension calculation**: New `calculate_table_dimensions_themed()` function with theme-specific adjustments

### Footnote System Fixes
- **Fixed footnote rendering bug**: Removed duplicate `render_footnotes` placeholder function that was overriding actual implementation
- **Corrected metadata reference**: Fixed `render_footnotes` to use `blueprint$metadata$footnote_list` instead of `blueprint$metadata$footnotes`
- **Implemented threeparttable for LaTeX**: Enhanced PDF footnote rendering using proper LaTeX `threeparttable` package with `\begin{tablenotes}` environment
- **Updated vignette dependencies**: Added `threeparttable` to LaTeX extra_dependencies in `dataset_examples.Rmd`
- **Verified footnote functionality**: Footnotes now render correctly in console, HTML, and PDF formats with proper markers (e.g., `mpg(1)`, `hp(2)`) and footnote sections

### Missing Data Analysis  
- **Explored missing=TRUE logic**: Dimension calculation depends on BOTH `missing=TRUE` flag AND actual missing data presence (`missing_counts > 0`)
- **Per-variable missing rows**: System allocates exactly 1 missing row per variable that has missing data
- **Efficient design**: No wasted rows when `missing=TRUE` but no actual missing data exists
- **Stratification interaction**: Missing data rows multiply by number of strata in stratified analyses

### Custom Numeric Summary Functions
- **Explored custom function capabilities**: Users can pass any function to `numeric_summary` parameter
- **Built-in options available**: `"mean_sd"`, `"median_iqr"`, `"mean_se"` with theme-specific formatting
- **Advanced custom functions**: Demonstrated bootstrap CIs, robust statistics, Bayesian credible intervals, distribution shape analysis
- **Multi-line summaries**: Custom functions can use `\n` for multi-line cell content without affecting table dimensions
- **Function factories**: Created parameterized generators for domain-specific summary formats

### Previous Updates
- Analyzed actual medical journal papers (NEJM, Lancet Neurology, JAMA Neurology) to extract authentic Table 1 formatting
- Updated theme system with real journal specifications and CSS styling
- Implemented row striping for NEJM theme matching actual publications
- Rewrote dataset_examples vignette to use current function architecture
- All vignettes successfully rendered to HTML with working examples

## Context Files
- Original package: `/Users/zenn/prj/d03/zztable1/`
- Current working directory: `/Users/zenn/Dropbox/prj/d03/zztable1_nextgen/`
- Sample papers analyzed: `NEJMoa050151.pdf`, `lancet-neurology-rct.pdf`, `jama-neurology.pdf`