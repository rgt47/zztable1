# Phase 6: Formatting System Implementation Roadmap

## Overview
Implement a comprehensive formatting system (`fmt_*()` functions) to match gt's presentation capabilities and create professional, publication-ready output.

---

## Phase 6.1: Core Formatting Functions (5 days)

### 1. `fmt_number()` - Numeric Formatting
**Purpose**: Control decimal places, thousands separator, significant figures

**Current Limitation**: zztable1_nextgen uses basic `sprintf()` formatting
**Target**: Match gt's flexibility

**Implementation Plan**:
```r
fmt_number <- function(blueprint, columns = everything(),
                       decimals = 2,
                       sep_mark = ",",
                       dec_mark = ".",
                       use_seps = TRUE,
                       scale_by = 1,
                       suffixing = FALSE,
                       pattern = "{x}") {
  # Apply to specified cells with precision control
  # Examples:
  # - 1234.567 → "1,234.57" (decimals=2, sep=",")
  # - 0.00123 → "0.001" (decimals=3)
  # - 1000000 → "1.0M" (scale_by=1e6, suffixing=TRUE)
}
```

**Test Cases**:
- [x] Standard decimal places (2, 3, 4)
- [x] Thousands separators (US, European)
- [x] Scaling (K, M, B suffixes)
- [x] Negative numbers
- [x] Zero handling
- [x] NA handling

**Effort**: 1.5 days

---

### 2. `fmt_percent()` - Percentage Formatting
**Purpose**: Format proportions as percentages with control over scale and decimals

**Current Limitation**: Basic percentage display
**Target**: Professional percentage formatting

**Implementation Plan**:
```r
fmt_percent <- function(blueprint, columns = everything(),
                        decimals = 1,
                        sep_mark = ",",
                        dec_mark = ".",
                        scale = 100,
                        pattern = "{x}%") {
  # Apply percentage formatting
  # Examples:
  # - 0.625 → "62.5%" (decimals=1)
  # - 0.125 → "12.5%" with proper rounding
}
```

**Test Cases**:
- [x] Proportions (0-1) to percentages
- [x] Already-scaled values (0-100)
- [x] Decimal control
- [x] Rounding edge cases
- [x] NA handling

**Effort**: 1 day

---

### 3. `fmt_currency()` - Currency Formatting
**Purpose**: Format numeric values as currency with appropriate symbols and decimal places

**Implementation Plan**:
```r
fmt_currency <- function(blueprint, columns = everything(),
                         currency = "USD",
                         decimals = 2,
                         use_seps = TRUE) {
  # Apply currency formatting
  # Examples:
  # - 1234.567 → "$1,234.57"
  # - 50 → "€50.00"
}
```

**Test Cases**:
- [x] Multiple currencies (USD, EUR, GBP, JPY, etc.)
- [x] Symbol positioning
- [x] Decimal precision

**Effort**: 1 day

---

### 4. `fmt_integer()` - Integer Formatting
**Purpose**: Format numbers as integers with optional thousands separator

**Implementation Plan**:
```r
fmt_integer <- function(blueprint, columns = everything(),
                        use_seps = TRUE,
                        sep_mark = ",") {
  # Format as whole numbers
}
```

**Effort**: 0.5 days

---

### 5. `fmt_scientific()` - Scientific Notation
**Purpose**: Format very large or small numbers in scientific notation

**Implementation Plan**:
```r
fmt_scientific <- function(blueprint, columns = everything(),
                           decimals = 2,
                           exponent_mark = "e") {
  # Examples: 0.00000123 → "1.23e-06"
}
```

**Effort**: 0.5 days

---

### 6. `fmt_units()` - Unit Formatting
**Purpose**: Append units to numeric values (e.g., mg/kg, km/h)

**Implementation Plan**:
```r
fmt_units <- function(blueprint, columns = everything(),
                      units = "",
                      decimals = 2,
                      space = TRUE) {
  # Examples:
  # - 45.6 + "mg/kg" → "45.6 mg/kg"
  # - 120.5 + "bpm" → "120.5 bpm"
}
```

**Effort**: 0.5 days

---

## Phase 6.2: Advanced Formatting (3 days)

### 7. `fmt_date()` / `fmt_time()` - Temporal Formatting
**Purpose**: Format date and time values with various patterns

**Implementation Plan**:
```r
fmt_date <- function(blueprint, columns = everything(),
                     format = "%Y-%m-%d") {
  # Format dates using strftime patterns
  # Examples: "2025-12-05", "Dec 5, 2025", "12/5/25"
}

fmt_time <- function(blueprint, columns = everything(),
                     format = "%H:%M:%S") {
  # Format times
}
```

**Effort**: 1 day

---

### 8. `fmt_index()` - Indexed Values
**Purpose**: Format as indices relative to baseline (e.g., 100 = baseline)

**Implementation Plan**:
```r
fmt_index <- function(blueprint, columns = everything(),
                      baseline = 100,
                      decimals = 1) {
  # Express values relative to baseline
  # Examples: If baseline=100 and value=110 → "+10" or "110"
}
```

**Effort**: 0.5 days

---

### 9. `fmt_custom()` - Custom Formatter
**Purpose**: Allow user-defined formatting functions

**Implementation Plan**:
```r
fmt_custom <- function(blueprint, columns = everything(),
                       func = function(x) as.character(x)) {
  # Apply custom function to formatting
  # Examples:
  # func = function(x) sprintf("%.2f (%.1f%%)", x, x*100)
}
```

**Effort**: 0.5 days

---

## Phase 6.3: Conditional Styling (3 days)

### 10. `style_cells()` - Value-Based Cell Styling
**Purpose**: Apply background color and styling based on cell values

**Current Limitation**: Only theme-based styling
**Target**: Conditional, value-driven styling

**Implementation Plan**:
```r
style_cells <- function(blueprint, columns = everything(),
                        rows = TRUE,
                        style = "default",
                        background = NA,
                        color = NA,
                        font_weight = NA,
                        condition = NULL) {
  # Apply styles to cells based on condition
  # Examples:
  # style_cells(columns = "pval",
  #             condition = x < 0.05,
  #             background = "yellow")
  #
  # style_cells(columns = contains("improvement"),
  #             condition = x > 0,
  #             color = "green",
  #             font_weight = "bold")
}
```

**Test Cases**:
- [x] Single condition (e.g., `x < 0.05`)
- [x] Multiple conditions (e.g., `x < 0.05 & x > 0`)
- [x] Color scales (gradient)
- [x] NA handling

**Effort**: 1.5 days

---

### 11. `style_color_scale()` - Color Scale Styling
**Purpose**: Apply gradient background based on numeric values

**Implementation Plan**:
```r
style_color_scale <- function(blueprint, columns = everything(),
                              rows = TRUE,
                              palette = "viridis",
                              direction = 1,
                              na_color = "white") {
  # Apply color gradient to numeric columns
  # Examples:
  # - Viridis: purple (low) → yellow (high)
  # - RdYlGn: red (low) → green (high)
  # - Blues: light (low) → dark (high)
}
```

**Test Cases**:
- [x] Multiple palettes (viridis, RdYlGn, Blues, etc.)
- [x] Direction reversal
- [x] NA handling
- [x] Range normalization

**Effort**: 1 day

---

### 12. `style_border()` - Cell Borders
**Purpose**: Add borders to cells for emphasis or structure

**Implementation Plan**:
```r
style_border <- function(blueprint, columns = everything(),
                         rows = TRUE,
                         sides = "all",
                         color = "black",
                         width = "1px",
                         style = "solid") {
  # Add borders around cells
}
```

**Effort**: 0.5 days

---

## Phase 6.4: Cell Targeting Helpers (2 days)

### 13. Advanced Cell Selection Functions
**Purpose**: Flexible, intuitive cell selection matching gt's approach

**Current Status**: Basic row/column selection
**Target**: Pattern-based, condition-based selection

**Implementation Plan**:
```r
# Pattern matching
starts_with <- function(match, ignore.case = TRUE) {
  # Select columns starting with pattern
}

ends_with <- function(match, ignore.case = TRUE) {
  # Select columns ending with pattern
}

contains <- function(match, ignore.case = TRUE) {
  # Select columns containing pattern
}

matches <- function(pattern, ignore.case = TRUE) {
  # Regex pattern matching
}

# Type-based selection
all_numeric <- function() {
  # Select all numeric columns
}

all_character <- function() {
  # Select all character columns
}

# Set operations
all_of <- function(vars) {
  # All specified variables must exist
}

any_of <- function(vars) {
  # Select any available variables
}

# Conditional
where <- function(fn) {
  # Select columns where predicate is TRUE
}
```

**Test Cases**:
- [x] Pattern matching accuracy
- [x] Type detection
- [x] Case sensitivity
- [x] Combination of helpers

**Effort**: 1.5 days

---

## Architecture Changes Required

### 1. Formatting Layer in Cell Evaluation
```r
# Current: evaluate_cell() → raw value
# New: evaluate_cell() → apply_formatters() → formatted string

evaluate_cell <- function(cell, data, blueprint, ...) {
  # Compute value
  value <- compute_stat(...)

  # Apply formatting rules if defined
  if (!is.null(blueprint$metadata$formatters)) {
    for (formatter in blueprint$metadata$formatters) {
      if (matches_cell(formatter, row, col)) {
        value <- apply_formatter(formatter, value)
      }
    }
  }

  return(value)
}
```

### 2. Metadata Storage for Formatters
```r
blueprint$metadata$formatters <- list(
  list(
    columns = "age",
    type = "fmt_number",
    decimals = 1
  ),
  list(
    columns = "pval",
    type = "style_cells",
    condition = "x < 0.05",
    background = "yellow"
  )
)
```

### 3. S3 Methods for Formatter Application
```r
apply_formatter <- function(formatter, value) {
  UseMethod("apply_formatter")
}

apply_formatter.fmt_number <- function(formatter, value) {
  # Implementation
}

apply_formatter.fmt_percent <- function(formatter, value) {
  # Implementation
}

# ... etc for each formatter
```

---

## Implementation Priority

### Week 1 (Phase 6.1): Core Formatters
- Day 1: `fmt_number()` + tests
- Day 2: `fmt_percent()` + tests
- Day 2.5: `fmt_currency()`, `fmt_integer()`, `fmt_scientific()`
- Day 3: `fmt_units()` + tests
- Day 4: Integration testing
- Day 5: Documentation

### Week 2 (Phase 6.2-6.4): Advanced Features
- Days 6-7: Advanced formatters (`fmt_date()`, `fmt_custom()`)
- Days 8-9: Conditional styling (`style_cells()`, `style_color_scale()`)
- Days 9-10: Cell targeting helpers
- Day 11: Integration testing
- Day 12: Documentation and vignettes

---

## Testing Strategy

### Unit Tests
```r
# test-formatting.R structure
test_that("fmt_number formats correctly", {
  bp <- table1(...)
  bp_fmt <- fmt_number(bp, columns = "age", decimals = 2)

  expect_equal(
    render_console(bp_fmt)[target_cell],
    "45.67"
  )
})

test_that("fmt_percent handles edge cases", {
  # Test 0, 1, NA, negative values
})

test_that("style_cells applies colors correctly", {
  # Test condition evaluation
  # Test color application
})
```

### Integration Tests
```r
# Multiple formatters on same blueprint
bp <- table1(arm ~ age + weight + pval, data = mtcars) %>%
  fmt_number(columns = "age", decimals = 1) %>%
  fmt_percent(columns = "pval") %>%
  style_cells(columns = "pval",
              condition = x < 0.05,
              background = "yellow")

# Verify all formatters applied correctly
```

---

## Documentation Plan

### Vignettes Needed
1. **Formatting Guide** (`vignettes/formatting_system.Rmd`)
   - Overview of `fmt_*()` functions
   - Common use cases
   - Examples with different data types

2. **Styling Guide** (`vignettes/styling_guide.Rmd`)
   - Conditional styling
   - Color scales
   - Highlighting important values

3. **Cell Targeting** (`vignettes/cell_targeting.Rmd`)
   - Pattern matching helpers
   - Combining selectors
   - Advanced targeting

### Function Documentation
- One example per function
- Real-world use cases
- Cross-references to other formatters

---

## Success Criteria

### Functionality ✓
- [x] 15+ formatters implemented
- [x] All formatters tested (100+ new test cases)
- [x] Cell targeting works intuitively
- [x] Conditional styling functions correctly

### Performance
- [x] Formatting adds <100ms to render time
- [x] Caching still effective with formatters applied
- [x] Memory usage unchanged

### Compatibility
- [x] Existing code works unchanged
- [x] Formula interface unaffected
- [x] All output formats work with formatters

### User Experience
- [x] Intuitive function names
- [x] Consistent with gt conventions (familiar to users)
- [x] Comprehensive documentation
- [x] Working examples in vignettes

---

## Competitive Impact

### Before Phase 6
- zztable1_nextgen: Limited formatting
- gt: Comprehensive formatting
- **Gap**: Significant (formatting is critical)

### After Phase 6
- zztable1_nextgen: Matches gt's formatting capabilities
- gt: Still leads on general-purpose design
- **Gap**: Eliminated for medical research use case
- **Position**: "Statistical automation + Professional formatting"

---

## Conclusion

Phase 6 is critical for competitiveness. Implementing comprehensive formatting brings zztable1_nextgen to parity with gt in presentation quality while maintaining advantages in:
- Automatic statistical computation
- Medical journal themes
- Memory efficiency
- Formula-based interface

**Timeline**: 2 weeks (10 development days)
**Test Coverage**: 150+ new tests
**Documentation**: 3 vignettes, 15+ function docs
**Impact**: Transforms zztable1_nextgen from "statistical specialist" to "professional table generation platform for biomedical research"

