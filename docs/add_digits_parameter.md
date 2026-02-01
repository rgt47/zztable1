I'll help you add a new "digits" argument to the table1.formula function and ensure it's properly passed to the relevant round() functions throughout the code. Here's a step-by-step guide on what changes need to be made:

## Step 1: Add the "digits" parameter to the table1.formula function

First, add the "digits" parameter to the function definition with a default value, likely 2 (since that's what's currently hardcoded in row_summary.numeric):

```r
table1.formula <- function(form, data, strata = NULL,
                          block = NULL, missing = FALSE,
                          pvalue = TRUE, size = FALSE, totals = FALSE,
                          fname = "table1", layout = "console", digits = 2, ...) {
```

## Step 2: Update the row_summary.numeric function

The row_summary.numeric function contains round() functions that need to be modified to use the digits parameter:

```r
row_summary.numeric <- function(x, grp, totals, missing, digits = 2, ...) {
  sp <- split(x, grp)
  if (totals) sp[["Total"]] <- x
  
  # Update these lines to use the digits parameter
  mm <- sapply(sp, function(x) round(mean(x, na.rm = TRUE), digits))
  ss <- sapply(sp, function(x) round(sd(x, na.rm = TRUE), digits))
  ss <- paste0("(", ss, ")")
  
  out <- paste(mm, ss)
  names(out) <- names(sp)
  if (missing) {
    misscnt <- sapply(sp, function(x) sum(is.na(x)))
    validcnt <- sapply(sp, function(x) sum(!is.na(x)))
    out2 <- paste0(validcnt, " (", misscnt, ")")
    out <- rbind(out, "valid (missing)" = out2) |> as.data.frame()
    names(out) <- ifelse(is.na(names(out)), "<NA>", names(out))
  }
  return(out)
}
```

## Step 3: Update the row_pv functions

The row_pv.factor and row_pv.numeric functions contain round() functions for p-values:

```r
row_pv.factor <- function(x, grp, digits = 2, ...) {
  categs <- levels(x) |>
    length()
  if (categs >= 2) {
    tab <- data.frame(x = x, grp = grp) |>
      tabyl(x, grp, show_missing_levels = FALSE)
    pv <- tab |>
      janitor::fisher.test() |>
      pluck("p.value") |>
      round(digits) |>  # Update this line
      round(digits)
  } else {
    pv <- NA
  }
  return(c(pv, rep("", categs)))
}

row_pv.numeric <- function(x, grp, missing, digits = 2, ...) {
  pv <- lm(x ~ grp) |>
    tidy() |>
    slice(2) |>
    pluck("p.value") |>
    round(digits) |>  # Update this line
    as.character()
  if (missing) {
    pv <- c(pv, "")
  }

  return(pv)
}
```

## Step 4: Update the build function

Modify the build function to pass the digits parameter to the row functions:

```r
build <- function(x, grp, size, totals, missing, digits = 2, ...) {
  left <- x |>
    imap(row_name, missing = missing, ...) |>
    bind_rows()
  right <- x |>
    map(row_pv, grp = grp, missing = missing, digits = digits, ...) |>
    unlist() |>
    enframe(name = NULL) |>
    setNames("p.value")
  mid <- x |>
    map(row_summary, grp = grp, totals = totals, missing = missing, digits = digits, ...) |>
    bind_rows()

  # Rest of the function remains the same
  # ...
}
```

## Step 5: Update the stratify function

Modify the stratify function to pass the digits parameter:

```r
stratify <- function(x, grp, strat, size, totals, missing, digits = 2, ...) {
  x_lst <- split(x, strat)
  grp_lst <- split(grp, strat)
  tab <- map2(x_lst, grp_lst, function(x, grp) {
    build(x = x, grp = grp, size = size, totals = totals, missing = missing, digits = digits, ...)
  })
  tab1 <- bind_rows(tab)

  # Rest of the function remains the same
  # ...
}
```

## Step 6: Update the table1.formula function call to stratify or build

In the table1.formula function, update the calls to stratify or build to pass the digits parameter:

```r
# Inside table1.formula function:
if (strata_logic) {
  tab0 <- stratify(
    x = dat0[x_vars], grp = data[[grp]],
    strat = data[[strata]], size = size, totals = totals, missing = missing, 
    digits = digits, ...  # Add digits parameter here
  )
} else {
  tab0 <- build(
    x = dat0[x_vars], grp = data[[grp]], size = size, totals = totals,
    missing = missing, digits = digits, ...  # Add digits parameter here
  )
}
```

## Step 7: Update the latex function to prioritize the digits parameter

The latex function already has a digits parameter, but it should be aligned with the default value used in table1.formula:

```r
latex <- function(tab, digits = 2, fname = "table0", theme = theme_nejm, ...) {
  # Function remains the same
  # ...
}
```

## Summary of Changes

In total, you need to:
1. Add the digits parameter to table1.formula with default value of 2
2. Add and use the digits parameter in row_summary.numeric
3. Add and use the digits parameter in row_pv.factor and row_pv.numeric
4. Modify build and stratify functions to pass the digits parameter
5. Update the function calls in table1.formula to pass the digits parameter
6. Ensure the latex function's digits parameter has the same default value

These changes will ensure that the digits parameter is properly passed through the chain of function calls and used consistently across all rounding operations in the package.
