# Phase 5+ Enhancement Roadmap

**Document Date:** December 5, 2025
**Status:** Strategic Planning
**Recommendation Level:** All items are high-value improvements for future development

---

## Overview

The zztable1_nextgen package has completed 4 comprehensive refactoring phases with:
- ✅ Code quality improvements (522 lines deduplication, 75% complexity reduction)
- ✅ Advanced features (optional rlang, parallel processing, user themes)
- ✅ 100% backward compatibility with 171 passing tests
- ✅ Solid foundation for user contributions and extensions

This roadmap identifies the most impactful enhancement opportunities for Phase 5 and beyond, organized by value, effort, and dependencies.

---

## Phase 5: Core Performance Enhancements

### 5.1: Parallel Statistical Calculations

**Value:** High (10-15% performance improvement for large datasets)
**Effort:** Medium (3-5 days)
**Dependencies:** Phase 4.2 (parallel processing framework)

**Objectives:**
- Parallelize statistical computations across strata
- Separate cell evaluation (Phase 4.2) from statistical computation (new)
- Intelligent batching of calculations by variable type

**Implementation Details:**

Current architecture evaluates each cell serially. Statistical calculations (mean, SD, test p-values) can be parallelized:

```r
# Current approach (serial):
for (stratum in strata) {
  for (variable in variables) {
    stats <- compute_statistics(variable, stratum_data)
  }
}

# Proposed approach (parallel):
results <- parallel::mclapply(
  strata,
  function(s) {
    lapply(variables, function(v) {
      compute_statistics(v, get_stratum_data(s))
    })
  },
  mc.cores = detect_cores()
)
```

**Key Functions to Create:**
- `parallelize_statistics()` - Dispatcher for stat computation
- `compute_stats_parallel()` - Parallel multi-stratum computation
- `compute_stats_serial()` - Serial fallback
- `smart_stat_batching()` - Batch similar operations for efficiency

**Benefits:**
- Significant speedup for multi-stratum tables (5-15 strata)
- No user-facing API changes
- Automatic parallel selection based on data characteristics
- Graceful fallback to serial if issues detected

**Testing Strategy:**
- Benchmark with 100+ variable, 10+ stratum datasets
- Verify statistical accuracy matches serial implementation
- Test with various variable types and test selection

---

### 5.2: Statistical Result Caching

**Value:** Medium (2-5% performance improvement)
**Effort:** Low (1-2 days)
**Dependencies:** None (standalone)

**Objectives:**
- Cache statistical computations (mean, SD, p-values)
- Detect when results can be reused
- Memoization for common calculations

**Implementation Details:**

```r
# Create computation cache in blueprint
blueprint$stat_cache <- list()

# Cache key example:
cache_key <- digest::digest(
  list(variable = "age", stratum = "arm==treatment", test_type = "ttest")
)

# Cached computation:
if (cache_key %in% names(blueprint$stat_cache)) {
  result <- blueprint$stat_cache[[cache_key]]
} else {
  result <- compute_statistics(...)
  blueprint$stat_cache[[cache_key]] <- result
}
```

**Benefits:**
- Eliminates redundant calculations
- Particularly valuable for multi-format rendering (console + HTML + LaTeX)
- Minimal code changes needed
- Easy to validate against non-cached results

---

### 5.3: Vectorized Numeric Operations

**Value:** Medium (10-15% improvement for numeric-heavy tables)
**Effort:** Medium (2-4 days)
**Dependencies:** None

**Objectives:**
- Use vectorized operations instead of loops where possible
- Leverage base R's columnar operations
- Profile and optimize hot paths

**Opportunities:**
1. **Variable analysis vectorization:** Currently uses `for` loops, can use `sapply/mapply`
2. **Missing data analysis:** Convert per-variable loops to vectorized checks
3. **Factor level extraction:** Use `levels()` directly instead of `unique()`
4. **Numeric summary batching:** Compute multiple summaries in one pass

**Example Optimization:**
```r
# Current (looped):
for (var in variables) {
  col_class <- class(data[[var]])[1]
  if (col_class == "numeric") {
    summary_stats <- mean(data[[var]], na.rm = TRUE)
  }
}

# Optimized (vectorized):
numeric_vars <- sapply(variables, function(v) is.numeric(data[[v]]))
summary_stats <- lapply(data[variables[numeric_vars]], mean, na.rm = TRUE)
```

**Testing:**
- Benchmark against current implementation
- Verify results are numerically identical
- Test with various dataset sizes and types

---

## Phase 6: Output Format Expansion

### 6.1: Markdown Output Format

**Value:** High (broader compatibility with documentation workflows)
**Effort:** Medium (2-3 days)
**Dependencies:** Core rendering pipeline (already exists)

**Objectives:**
- Add GitHub Flavored Markdown (GFM) output format
- Support for inclusion in documentation
- Table-in-markdown for easy embedding

**Implementation:**

```r
render_markdown <- function(blueprint, theme = "console", ...) {
  # Use render_pipeline with markdown dispatch
  render_pipeline(
    blueprint,
    theme,
    format = "markdown",
    ...
  )
}
```

**Features:**
- Pipe tables for GitHub/GitLab
- Pandoc-compatible format
- Preserve theme formatting in Markdown comments
- Optional code block wrapper

**Example Output:**
```markdown
| Variable | Treatment | Control | p-value |
|----------|-----------|---------|---------|
| Age      | 45.2 ± 8.3 | 43.1 ± 9.2 | 0.156 |
| Sex (F)  | 48 (32%)  | 52 (35%)  | 0.421 |

*Table 1: Baseline characteristics by treatment arm*
```

---

### 6.2: Word Document Output (docx)

**Value:** High (enterprise requirement for medical documents)
**Effort:** High (4-5 days)
**Dependencies:** flextable package (optional)

**Objectives:**
- Generate publication-ready Word documents
- Preserve all formatting and styling
- Support footnotes and table captions

**Implementation Strategy:**

```r
render_docx <- function(blueprint, theme = "nejm",
                       title = NULL, footnotes = NULL, ...) {
  # Create flextable object
  ft <- flextable::flextable(get_table_data(blueprint))

  # Apply theme-specific formatting
  ft <- apply_theme_to_flextable(ft, theme)

  # Create document
  doc <- officer::read_docx() %>%
    officer::body_add_flextable(ft) %>%
    officer::body_add_par(title, style = "Heading 1")

  return(doc)
}
```

**Benefits:**
- Direct export to .docx format
- Medical journals often require Word submissions
- Preserves table 1 styling for publication
- Footnotes and cross-references supported

---

### 6.3: Excel Output Format

**Value:** Medium (data analyst favorite)
**Effort:** Low (1-2 days)
**Dependencies:** openxlsx package (optional)

**Objectives:**
- Export to .xlsx with theme formatting
- Multiple sheets for strata
- Conditional formatting for readability

**Implementation:**

```r
render_xlsx <- function(blueprint, theme = "nejm", file = "table1.xlsx") {
  wb <- openxlsx::createWorkbook()

  # Add sheet per stratum
  for (stratum in blueprint$strata) {
    sheet_data <- subset_blueprint_data(blueprint, stratum)
    openxlsx::addWorksheet(wb, stratum)
    openxlsx::writeData(wb, stratum, sheet_data)
  }

  openxlsx::saveWorkbook(wb, file)
  invisible(file)
}
```

---

## Phase 7: Statistical Features

### 7.1: Additional Statistical Tests

**Value:** Medium (broader statistical flexibility)
**Effort:** Low-Medium (2-3 days)
**Dependencies:** Core validation system

**Current Supported Tests:**
- Continuous: t-test, ANOVA, Welch, Kruskal-Wallis
- Categorical: Fisher exact, Chi-square

**Proposed Additions:**
1. **Continuous:**
   - Mann-Whitney U test (nonparametric alternative)
   - Mood's median test
   - Brunner-Munzel test (robust alternative)
   - Permutation tests

2. **Categorical:**
   - McNemar test (paired data)
   - Cochran-Mantel-Haenszel test (stratified analysis)
   - Exact binomial test

3. **Mixed:**
   - Linear mixed models for repeated measures
   - Logistic regression for binary outcomes
   - Cox proportional hazards for time-to-event

**Implementation Pattern:**
```r
stat_tests <- list(
  continuous = list(
    t.test = list(func = stats::t.test, p_extract = "p.value"),
    mann_whitney = list(func = wilcox.test, p_extract = "p.value"),
    permutation = list(func = oneway_perm_test, p_extract = "p.value")
  ),
  categorical = list(
    chisq = list(func = chisq.test, p_extract = "p.value"),
    mcnemar = list(func = mcnemar.test, p_extract = "p.value")
  )
)
```

---

### 7.2: Confidence Intervals and Effect Sizes

**Value:** High (important for modern epidemiology)
**Effort:** Medium (2-3 days)
**Dependencies:** None (base R capable)

**Objectives:**
- Include 95% CI in numeric summaries
- Report effect sizes alongside p-values
- Support for Bayesian credible intervals

**Example Implementations:**
```r
# Mean with CI
mean_ci <- function(x, conf = 0.95) {
  t_val <- qt((1 + conf) / 2, df = length(x) - 1)
  se <- sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x)))
  m <- mean(x, na.rm = TRUE)
  paste0(
    sprintf("%.2f", m),
    " [",
    sprintf("%.2f", m - t_val * se),
    "-",
    sprintf("%.2f", m + t_val * se),
    "]"
  )
}

# Cohen's d for continuous variables
cohens_d <- function(x, g) {
  groups <- unique(g[!is.na(g)])
  if (length(groups) == 2) {
    x1 <- x[g == groups[1]]
    x2 <- x[g == groups[2]]
    sp <- sqrt((var(x1) + var(x2)) / 2)
    (mean(x1) - mean(x2)) / sp
  }
}

# Odds Ratio for categorical
odds_ratio <- function(x, y) {
  tab <- table(x, y)
  (tab[1,1] * tab[2,2]) / (tab[1,2] * tab[2,1])
}
```

---

## Phase 8: User Experience Enhancements

### 8.1: Interactive Shiny Application

**Value:** High (significantly improves accessibility)
**Effort:** High (5-7 days)
**Dependencies:** shiny, ggplot2 (optional)

**Objectives:**
- Interactive table builder GUI
- Real-time preview
- Export to multiple formats
- Data upload and exploration

**Key Components:**
1. **Data upload panel** - CSV, Excel, R data files
2. **Formula builder** - Visual interface for ~grouping variables +outcome variables
3. **Options panel** - Theme, test selection, stratification, footnotes
4. **Preview pane** - Real-time table rendering
5. **Export panel** - Download in various formats

**Architecture:**
```r
# Create Shiny app
library(shiny)
library(zztable1nextgen)

ui <- fluidPage(
  titlePanel("Table 1 Builder"),
  sidebarLayout(
    sidebarPanel(
      # Data upload
      fileInput("file", "Upload data", accept = c(".csv", ".xlsx", ".RData")),
      # Formula builder
      selectInput("groupvar", "Grouping variable", choices = NULL),
      selectizeInput("outcomes", "Outcome variables", choices = NULL, multiple = TRUE),
      # Options
      selectInput("theme", "Theme", choices = list_available_themes()),
      selectInput("continuous_test", "Continuous test",
                 choices = c("ttest", "anova", "welch", "kruskal")),
      # Export
      downloadButton("download", "Download Table")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Console", verbatimTextOutput("preview_console")),
        tabPanel("HTML", htmlOutput("preview_html")),
        tabPanel("LaTeX", verbatimTextOutput("preview_latex"))
      )
    )
  )
)

server <- function(input, output, session) {
  # Reactive data loading
  data_reactive <- reactive({
    # Load data from uploaded file
  })

  # Reactive formula building
  formula_reactive <- reactive({
    # Build formula from selections
  })

  # Reactive table creation
  table_reactive <- reactive({
    table1(formula_reactive(), data = data_reactive(), theme = input$theme)
  })

  # Preview outputs
  output$preview_console <- renderText({
    paste(render_console(table_reactive()), collapse = "\n")
  })

  # Download handler
  output$download <- downloadHandler(...)
}

shinyApp(ui, server)
```

**Benefits:**
- No coding required for non-technical users
- Real-time feedback
- Exploration of different options
- Export ready for publication

---

### 8.2: Command-Line Interface (CLI)

**Value:** Medium (useful for batch processing)
**Effort:** Medium (2-3 days)
**Dependencies:** argparse or docopt packages

**Objectives:**
- Create R script wrapper for command-line use
- Batch processing capability
- Configuration files support

**Example Usage:**
```bash
# Single table
Rscript table1.R --data patients.csv --formula "treatment ~ age + sex" --theme nejm --output table1.html

# Batch processing
Rscript table1.R --batch config.json
```

**Config File Format:**
```json
{
  "tables": [
    {
      "name": "baseline",
      "data": "baseline.csv",
      "formula": "arm ~ age + sex + bmi",
      "theme": "nejm",
      "stratify": "center",
      "output": "baseline.html"
    },
    {
      "name": "followup",
      "data": "followup.csv",
      "formula": "arm ~ wt_change + outcomes",
      "theme": "lancet",
      "output": "followup.html"
    }
  ]
}
```

---

### 8.3: Enhanced Documentation Portal

**Value:** Medium (improves discoverability)
**Effort:** Medium (2-3 days)
**Dependencies:** pkgdown or quarto

**Objectives:**
- Professional documentation website
- Interactive examples
- Gallery of themes and use cases
- Tutorial video guides

**Content Structure:**
```
docs/
├── index.html                    # Landing page
├── getting-started.html          # Quick start guide
├── formula-syntax.html           # Formula specification
├── themes/
│   ├── builtin-themes.html       # Medical journal themes
│   ├── custom-themes.html        # Creating custom themes
│   └── theme-gallery.html        # Visual showcase
├── outputs/
│   ├── console-format.html       # Console output
│   ├── html-format.html          # HTML format
│   ├── latex-format.html         # LaTeX for PDF
│   └── export-formats.html       # All export options
├── examples/
│   ├── basic-table.html          # Simple example
│   ├── stratified-analysis.html  # Multi-center trials
│   ├── custom-statistics.html    # Advanced options
│   └── real-world-examples.html  # Published tables
├── api-reference.html            # Function documentation
├── faq.html                       # Common questions
└── troubleshooting.html          # Help & debugging
```

---

## Phase 9: Ecosystem Integration

### 9.1: Central Theme Registry

**Value:** Medium (enables theme ecosystem)
**Effort:** High (5+ days, requires infrastructure)
**Dependencies:** Phase 4.3 (theme registry system)

**Objectives:**
- Central online repository for user-created themes
- Theme discovery and installation
- Version management and ratings

**Implementation:**
```r
# Install theme from central registry
install_theme("company_branding", source = "central")

# Search for themes
search_themes(keywords = c("pharmaceutical", "medical"))

# View theme ratings
theme_info <- get_theme_info("company_branding")
# Returns: author, version, rating, downloads, description
```

**Infrastructure Requirements:**
- Web service (REST API)
- Theme validation pipeline
- Security scanning for malicious code
- Version control and rollback capability

---

### 9.2: R Markdown Integration

**Value:** High (seamless scientific document creation)
**Effort:** Low-Medium (1-2 days)
**Dependencies:** R Markdown infrastructure (already exists)

**Objectives:**
- Native R Markdown code chunks
- Easy table inclusion in documents
- Automatic numbering and cross-references

**Example Usage in R Markdown:**
```rmarkdown
# Clinical Trial Results

```{r table1}
library(zztable1nextgen)
data(trial_data)

bp <- table1(
  treatment ~ age + sex + comorbidities,
  data = trial_data,
  strata = "center",
  theme = "nejm",
  caption = "Baseline characteristics by treatment arm"
)

render_html(bp)
```

Table \@ref(tab:table1) shows the baseline characteristics...
```

---

### 9.3: Integration with Other Packages

**Value:** Medium (ecosystem connectivity)
**Effort:** Medium (1-2 days each)

**Target Packages:**

1. **gtsummary** (complementary approach)
   - Compare table1 output with gtsummary
   - Conversion utilities where beneficial
   - Cross-promotion

2. **tableone** (predecessor competition)
   - Migration guide from tableone to table1
   - API compatibility layer (optional)

3. **flextable** (word document integration)
   - Native flextable output as alternative to docx
   - Leverage flextable's formatting capabilities

4. **officer** (document building)
   - Direct Word/PowerPoint integration
   - Embed tables in slide presentations

---

## Phase 10: Advanced Analytics

### 10.1: Missing Data Analysis

**Value:** Medium (important for real-world data)
**Effort:** Medium (2-3 days)
**Dependencies:** None (mostly visualization)

**Objectives:**
- Structured missing data display
- Missing mechanism analysis
- Imputation framework integration

**Features:**
```r
# Display missing patterns
table1_missing <- table1(
  group ~ age + sex + bmi,
  data = trial_data,
  missing = "pattern"  # New option: "count", "percent", "pattern"
)

# Analyze missing completely at random (MCAR)
table1_mcar <- table1(
  group ~ age + sex,
  data = trial_data,
  missing = "mcar_test"  # Little's MCAR test
)

# Integration with imputation
table1_imputed <- table1(
  group ~ age + sex,
  data = mice::complete(imputed_data),
  caption = "Analysis using multiply imputed data"
)
```

---

### 10.2: Subgroup Analysis Framework

**Value:** High (critical for regulatory submissions)
**Effort:** Medium (2-3 days)
**Dependencies:** None

**Objectives:**
- Systematic subgroup table generation
- Interaction testing
- Forest plots for effect modification

**Implementation:**
```r
# Create subgroup tables
table1_subgroups <- table1_subgroup_analysis(
  formula = treatment ~ age + sex,
  data = trial_data,
  subgroups = c("age_group", "sex", "disease_stage"),
  outcomes = c("efficacy", "safety"),
  test_interaction = TRUE
)

# Forest plot of treatment effects by subgroup
plot(table1_subgroups, type = "forest")
```

---

## Priority Matrix

### High Value, Low Effort (Quick Wins)

1. **5.2: Statistical result caching** (1-2 days) - 2-5% improvement
2. **6.3: Excel output** (1-2 days) - Common format
3. **7.1: Additional statistical tests** (2-3 days) - High demand
4. **9.2: R Markdown integration** (1-2 days) - Seamless workflow

### High Value, Medium Effort (Core Phase 5)

1. **5.1: Parallel statistical calculations** (3-5 days) - 10-15% improvement
2. **5.3: Vectorized operations** (2-4 days) - 10-15% improvement
3. **6.1: Markdown output** (2-3 days) - Documentation workflows
4. **7.2: Confidence intervals & effect sizes** (2-3 days) - Modern epidemiology

### High Value, High Effort (Future Phases)

1. **8.1: Shiny application** (5-7 days) - Accessibility
2. **6.2: Word document output** (4-5 days) - Publication requirement
3. **9.1: Central theme registry** (5+ days) - Theme ecosystem
4. **10: Advanced analytics** (5-10 days) - Research applications

---

## Recommended Next Steps (Phase 5 Focus)

Based on impact and effort, Phase 5 should focus on:

1. **Statistical result caching** (foundation for performance)
2. **Parallel statistical calculations** (10-15% speedup with little API change)
3. **Additional statistical tests** (high user demand, low implementation cost)
4. **Confidence intervals and effect sizes** (modern statistical practice)

**Estimated Timeline:** 2-3 weeks for all Phase 5 items
**Expected Outcome:** 15-20% overall performance improvement + modern statistical defaults

---

## Appendix: Performance Optimization Opportunities Summary

| Opportunity | Estimated Gain | Effort | Phase |
|-------------|----------------|--------|-------|
| Statistical caching | 2-5% | Low | 5.2 |
| Parallel statistics | 10-15% | Medium | 5.1 |
| Vectorized operations | 10-15% | Medium | 5.3 |
| CI/Effect size support | N/A (features) | Medium | 7.2 |
| **Total Phase 5 Opportunity** | **25-35%** | **Medium** | **5** |

---

## Conclusion

The zztable1_nextgen package has a strong foundation for future development. The recommended Phase 5 focus on performance optimization and statistical features will:

- Achieve 25-35% overall performance improvement
- Add modern statistical capabilities (CIs, effect sizes, additional tests)
- Maintain full backward compatibility
- Position package for Phase 6+ ecosystem expansion

All identified opportunities are implementable within existing architecture without breaking changes.
