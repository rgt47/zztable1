# Phase 5: Quick Start Guide

**Phase 5 Focus:** Performance Optimization & Modern Statistical Features
**Target Duration:** 3 weeks
**Expected Outcome:** 25-35% performance improvement + modern statistical defaults

---

## 30-Second Overview

The zztable1_nextgen package is production-ready and needs performance optimization:
- Current performance baseline established
- Phase 5 can add 25-35% improvement
- Four sub-phases planned (5.1-5.4)
- Recommended start: Phase 5.2 (caching, easiest)

---

## Quick Start (Do This First)

### Step 1: Verify Everything Works (5 minutes)
```bash
cd /Users/zenn/Dropbox/prj/d03/zztable1_nextgen
Rscript -e "
library(devtools)
load_all()

# Quick test
data(mtcars)
mtcars\$g <- factor(rep(c('A', 'B'), 16))
bp <- table1(g ~ mpg + hp, data = mtcars)
render_console(bp)
cat('\n✓ Package working!\n')
"
```

### Step 2: Run Full Test Suite (5 minutes)
```bash
Rscript -e "devtools::test()"
# Should see: 171 tests passed
```

### Step 3: Read the Essential Documents (30 minutes)
1. **PROJECT_STATUS.md** - Current state (skim in 10 min)
2. **PHASE5_ROADMAP.md** - What to build (skim in 10 min)
3. **DEVELOPER_GUIDE.md** - How to implement (read in 10 min)

### Step 4: Pick Your First Task (Decision time)

**Easiest & Quickest (Recommended Start):**
```
Phase 5.2: Statistical Result Caching
- Effort: 1-2 days
- Impact: 2-5% improvement
- Implementation: Straightforward pattern
```

**Or Choose Based on Interest:**

| Phase | Focus | Effort | Impact | Best For |
|-------|-------|--------|--------|----------|
| 5.1 | Parallel stats | 3-5 days | 10-15% | Performance-focused |
| 5.2 | Result caching | 1-2 days | 2-5% | Quick win |
| 5.3 | Vectorization | 2-4 days | 10-15% | Code quality |
| 7.1 | More tests | 2-3 days | Features | User demand |
| 7.2 | CIs & effect sizes | 2-3 days | Features | Modern stats |

---

## Implementation Roadmap

### Week 1: Foundation & Quick Wins
```
Day 1-2: Phase 5.2 (Result Caching)
  - Add cache structure to blueprint
  - Implement cache lookup in evaluate_cell()
  - Write cache tests
  - Verify 2-5% improvement

Day 2-3: Phase 7.1 (Additional Tests)
  - Add Mann-Whitney test
  - Add Mood's median test
  - Add McNemar test
  - Update documentation
```

### Week 2: Core Performance
```
Day 1-3: Phase 5.1 (Parallel Statistics)
  - Create compute_statistics_smart() dispatcher
  - Implement parallel variant (mclapply/parLapply)
  - Test correctness (serial vs parallel match)
  - Benchmark improvement (target: 10-15%)

Day 4: Phase 5.3 (Vectorization)
  - Profile code for loops
  - Convert to vectorized operations
  - Benchmark improvement (target: 10-15%)
```

### Week 3: Modern Features & Finalization
```
Day 1-3: Phase 7.2 (CIs & Effect Sizes)
  - Implement mean_ci() function
  - Implement effect size calculations
  - Add to numeric summaries
  - Test and document

Day 4: Integration & Testing
  - Full regression testing
  - Performance verification
  - Documentation updates
  - Code review preparation
```

---

## Getting Started: Step-by-Step

### 1. Environment Setup

**Clone and setup:**
```bash
cd /Users/zenn/Dropbox/prj/d03/zztable1_nextgen
git status  # Verify you're on main branch
```

**Install dependencies:**
```bash
Rscript -e "
if (!require('devtools')) install.packages('devtools')
devtools::install_deps()
"
```

**Load for development:**
```bash
Rscript -e "devtools::load_all()"
```

### 2. Understanding the Codebase (Choose one)

**For Performance-focused work:**
1. Read: `PERFORMANCE_ANALYSIS.md` (understand baseline)
2. Review: `R/cells.R` (understand cell evaluation)
3. Review: `R/parallel_processing.R` (understand existing parallel)
4. Study: `DEVELOPER_GUIDE.md` section 2 (code patterns)

**For Feature-focused work:**
1. Review: `R/utils.R` (understand current stats)
2. Review: `R/validation_consolidated.R` (understand validation)
3. Study: `DEVELOPER_GUIDE.md` section 2 (code patterns)
4. Look: `tests/testthat/test-*.R` (understand test structure)

### 3. Pick Your First Task

**If you want: Quick win + performance improvement**
→ Start with **Phase 5.2: Result Caching**

**If you want: Core performance optimization**
→ Start with **Phase 5.1: Parallel Statistics**

**If you want: Code optimization**
→ Start with **Phase 5.3: Vectorization**

**If you want: User-requested features**
→ Start with **Phase 7.1: Additional Tests** or **Phase 7.2: CIs & Effect Sizes**

---

## Detailed Instructions: Phase 5.2 (Recommended Start)

### Phase 5.2: Statistical Result Caching

**Goal:** Cache statistical calculations so they're not recomputed for multiple renders

**Current Problem:**
- If you render same table 3 times (console, HTML, LaTeX), stats computed 3x
- Test p-values recomputed even though data/groups unchanged

**Solution:**
- Add cache structure to blueprint
- Check cache before computing stats
- Store results in cache after computation

### Implementation (Estimated: 1-2 days)

**Step 1: Add cache to blueprint (5 min)**

File: `R/blueprint.R`

Find the blueprint creation code:
```r
blueprint <- list(
  formula = formula_obj,
  data = data_frame,
  # ... existing fields ...
)
```

Add cache field:
```r
blueprint <- list(
  formula = formula_obj,
  data = data_frame,
  stat_cache = list(),  # NEW: Add this line
  # ... existing fields ...
)
```

**Step 2: Create cache key function (10 min)**

File: `R/utils.R` (or new section in R/cells.R)

Add function:
```r
#' Create cache key for statistical computation
#' @keywords internal
create_stat_cache_key <- function(variable, stratum, test_type) {
  # Create unique key for this computation
  paste0(
    "var_", variable,
    "_strat_", stratum %||% "none",
    "_test_", test_type
  )
}
```

**Step 3: Update cell evaluation (15 min)**

File: `R/cells.R`

Find `evaluate_cell.cell_statistic()`:

```r
# BEFORE: Direct computation
evaluate_cell.cell_statistic <- function(cell, data, env, force_recalc) {
  result <- compute_cell_statistic(cell, data, env)
  list(content = result, cached = FALSE)
}

# AFTER: Add cache check
evaluate_cell.cell_statistic <- function(cell, data, env, force_recalc) {
  # Get cache key from cell metadata
  cache_key <- cell$cache_key

  # Check if blueprint has cache
  blueprint <- get("blueprint", envir = env)

  if (!is.null(blueprint$stat_cache[[cache_key]]) && !force_recalc) {
    # Use cached result
    return(list(
      content = blueprint$stat_cache[[cache_key]],
      cached = TRUE
    ))
  }

  # Compute if not cached
  result <- compute_cell_statistic(cell, data, env)

  # Store in cache
  if (!is.null(blueprint$stat_cache)) {
    blueprint$stat_cache[[cache_key]] <- result
  }

  list(content = result, cached = FALSE)
}
```

**Step 4: Add cache keys to cells (20 min)**

File: `R/cells.R` (in cell creation logic)

When creating statistical cells, add cache key:
```r
stat_cell <- list(
  type = "statistic",
  # ... existing fields ...
  cache_key = create_stat_cache_key(
    variable = var_name,
    stratum = stratum_spec,
    test_type = test_spec
  )  # NEW: Add this
)
```

**Step 5: Write tests (20 min)**

File: `tests/testthat/test-caching.R` (new file)

```r
test_that("statistical results are cached", {
  # Create blueprint
  data(mtcars)
  mtcars$g <- factor(rep(c("A", "B"), 16))
  bp <- table1(g ~ mpg + hp, data = mtcars)

  # Render first time (populates cache)
  output1 <- render_console(bp)
  cache_size_1 <- length(bp$stat_cache)

  # Render second time (uses cache)
  output2 <- render_console(bp)
  cache_size_2 <- length(bp$stat_cache)

  # Cache should exist and be same size
  expect_true(cache_size_1 > 0)
  expect_equal(cache_size_1, cache_size_2)

  # Results should be identical
  expect_equal(output1, output2)
})

test_that("cache is bypassed with force_recalc", {
  # Create blueprint
  data(mtcars)
  mtcars$g <- factor(rep(c("A", "B"), 16))
  bp <- table1(g ~ mpg + hp, data = mtcars, force_recalc = TRUE)

  # Force recalc should work
  output <- render_console(bp)
  expect_true(length(output) > 0)
})

test_that("caching improves performance", {
  # Benchmark multiple renders
  data(mtcars)
  mtcars$g <- factor(rep(c("A", "B"), 16))
  bp <- table1(g ~ mpg + hp, data = mtcars)

  # Time first render
  t1 <- system.time(render_console(bp))[3]

  # Time second render (should be faster with cache)
  t2 <- system.time(render_console(bp))[3]

  # Second render should be faster (cache hit)
  # Allow for variance, just verify not slower
  expect_true(t2 <= t1 * 1.1)  # Allow 10% variance
})
```

**Step 6: Verify improvement (10 min)**

```bash
# Run tests
Rscript -e "testthat::test_file('tests/testthat/test-caching.R')"

# Quick benchmark
Rscript -e "
library(devtools)
load_all()

data(mtcars)
mtcars\$g <- factor(rep(c('A', 'B'), 16))
bp <- table1(g ~ mpg + hp, data = mtcars)

# Time multiple renders
t1 <- system.time({
  for (i in 1:10) render_console(bp)
})[3]

cat('Time for 10 renders with caching:', t1, 'seconds\n')
cat('Expected improvement: 2-5%\n')
"
```

**Step 7: Run full test suite (5 min)**

```bash
Rscript -e "devtools::test()"
# Should still see: 171 tests passed
```

---

## Common Patterns in Code

### Pattern 1: Adding Optional Features
```r
# Check if available, use if yes, fallback if no
if (requireNamespace("package", quietly = TRUE)) {
  # Use enhanced version
  package::function(data)
} else {
  # Fall back to base R
  fallback_function(data)
}
```

### Pattern 2: S3 Method Dispatch
```r
# Generic function
my_function <- function(x) {
  UseMethod("my_function", x)
}

# Method for class "cell_statistic"
my_function.cell_statistic <- function(x) {
  # Implementation
}
```

### Pattern 3: Cell Evaluation
```r
# Cells have type, metadata, and optional cached result
cell <- list(
  type = "statistic",  # Determines which S3 method
  variable = "age",     # Metadata
  formula = formula_obj,
  computation = function(data) {...},
  cache_key = "key_here",
  cached_result = NULL  # Filled in on first evaluation
)
```

---

## Helpful Commands

### Testing
```bash
# Run all tests
Rscript -e "devtools::test()"

# Run specific file
Rscript -e "testthat::test_file('tests/testthat/test-caching.R')"

# Check coverage
Rscript -e "covr::report(covr::package_coverage())"
```

### Debugging
```bash
# Load package with debugging enabled
Rscript -e "
library(devtools)
load_all()

# Set breakpoint (opens debugger)
debug(my_function)
"
```

### Performance
```bash
# Quick benchmark
Rscript -e "
library(profvis)
profvis({
  # Code to profile
})
"
```

---

## Deliverables Checklist

For each Phase 5 sub-phase, before submitting:

- [ ] Code implemented according to DEVELOPER_GUIDE patterns
- [ ] Tests written and passing (at least 2-3 new tests per feature)
- [ ] No regression (all 171+ existing tests still pass)
- [ ] Backward compatible (no breaking changes)
- [ ] Documented (roxygen docs + inline comments)
- [ ] Performance verified (baseline comparison if applicable)
- [ ] Code reviewed (self-review at minimum)
- [ ] CHANGELOG updated
- [ ] Vignette or example added (if user-facing feature)

---

## Success Criteria for Phase 5

### Performance Improvements
- [ ] Phase 5.1: Parallel stats achieve 10-15% improvement
- [ ] Phase 5.2: Caching achieves 2-5% improvement
- [ ] Phase 5.3: Vectorization achieves 10-15% improvement
- [ ] **Combined: 25-35% overall improvement**

### Quality Standards
- [ ] All existing tests pass (171+)
- [ ] New tests written for all new features
- [ ] Code follows established patterns
- [ ] Documentation complete
- [ ] Zero regressions
- [ ] Backward compatible

### Deliverables
- [ ] Code merged to main branch
- [ ] Version number bumped (1.0.0 → 1.1.0)
- [ ] CHANGELOG updated
- [ ] Documentation updated
- [ ] Vignettes/examples added

---

## Timeline & Milestones

### Week 1: Foundation
- **Day 1-2:** Phase 5.2 (Caching) - Complete
- **Day 3:** Review & Testing - Complete
- **Day 4-5:** Phase 7.1 (Additional Tests) - Complete
- **Checkpoint:** Run full test suite, verify no regressions

### Week 2: Performance
- **Day 1-3:** Phase 5.1 (Parallel Stats) - Complete
- **Day 4:** Phase 5.3 (Vectorization) - In progress
- **Day 5:** Integration Testing - Complete
- **Checkpoint:** Benchmark shows 25-35% improvement

### Week 3: Features & Polish
- **Day 1-3:** Phase 7.2 (CIs & Effect Sizes) - Complete
- **Day 4:** Final Testing & Documentation - Complete
- **Day 5:** Code Review & Refinement - Complete
- **Final Checkpoint:** All tests pass, performance verified

---

## Getting Help

### Documentation
- **Current state:** PROJECT_STATUS.md
- **What to build:** PHASE5_ROADMAP.md
- **How to implement:** DEVELOPER_GUIDE.md
- **Architecture:** Blueprint_Construction_Guide.md
- **Troubleshooting:** TROUBLESHOOTING.md

### Code Examples
- **Existing tests:** tests/testthat/test-theme-integration.R
- **S3 methods:** R/cells.R
- **Rendering pipeline:** R/rendering.R
- **Parallel pattern:** R/parallel_processing.R

### Quick Reference
- **Code style:** DEVELOPER_GUIDE.md part 4
- **Testing pattern:** DEVELOPER_GUIDE.md part 3
- **Common issues:** TROUBLESHOOTING.md
- **Performance:** PERFORMANCE_ANALYSIS.md

---

## Ready to Start?

**For Phase 5.2 (Recommended):**
1. Read this entire guide (you just did!)
2. Open `R/blueprint.R` and `R/cells.R`
3. Follow "Detailed Instructions: Phase 5.2" above
4. Write tests as you implement
5. Verify with `devtools::test()`
6. Benchmark improvement with script above

**Start time:** 1-2 hours
**Expected completion:** 1-2 days for full implementation + testing

**Good luck! You've got this.** 🚀
