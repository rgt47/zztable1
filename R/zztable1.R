# At the top of your file, add:
utils::globalVariables(c("variables", "code", "p.value"))
#' @importFrom stats lm sd setNames addmargins
#' @importFrom purrr map map2 map_dfr imap reduce pluck
#' @importFrom dplyr select bind_cols bind_rows slice contains
#' @importFrom janitor tabyl adorn_totals adorn_percentages adorn_pct_formatting adorn_ns
#' @importFrom tibble enframe
#' @importFrom broom tidy
#' @importFrom kableExtra kbl row_spec
#' @title Table One - Clinical Trial Data Summarizer
#' @description A package for creating publication-ready baseline characteristic
#'   tables (Table 1) for clinical trial data. This package provides functions for
#'   summarizing baseline characteristics by treatment groups, calculating p-values
#'   for comparisons, and formatting the results for publication.
#'
#' @details The package allows for stratification of results, handling of missing data,
#'   and export to LaTeX format with customizable styling.
#'
#' @section Main Functions:
#'   \itemize{
#'     \item \code{table1}: Main function to create summary tables
#'     \item \code{latex}: Export formatted tables to LaTeX
#'   }
#'
#' @importFrom janitor tabyl adorn_totals adorn_percentages adorn_pct_formatting adorn_ns fisher.test
#' @importFrom dplyr select bind_cols bind_rows slice contains mutate
#' @importFrom berryFunctions insertRows
#' @importFrom purrr map map2 imap reduce pluck
#' @importFrom broom tidy
#' @importFrom tibble enframe
#' @importFrom kableExtra kbl row_spec
#'
#' @name zztable2
#' @docType package
NULL

#' Create a summary table of baseline characteristics
#'
#' This is the main function used to create summary tables for clinical trial data.
#' It summarizes baseline characteristics by treatment groups and calculates
#' appropriate statistics and p-values for comparisons.
#'
#' @param form Formula specifying the grouping and variables to summarize (e.g., arm ~ sex + age)
#' @param data Dataframe containing the variables
#' @param strata Optional stratification variable
#' @param block Deprecated parameter
#' @param missing Logical; whether to show missing values
#' @param pvalue Logical; whether to show p-values
#' @param size Logical; whether to show group sizes
#' @param totals Logical; whether to show totals
#' @param fname Output filename for saved tables
#' @param layout Output format (e.g., "console")
#' @param ... Additional parameters passed to specialized methods
#'
#' @return A dataframe containing the summary table
#'
#' @examples
#' # Create a sample dataset
#' set.seed(123)
#' trial_data <- data.frame(
#'   arm = factor(rep(c("Treatment", "Placebo"), each = 50)),
#'   age = rnorm(100, mean = 45, sd = 15),
#'   sex = factor(sample(c("Male", "Female"), 100, replace = TRUE)),
#'   bmi = rnorm(100, mean = 26, sd = 5),
#'   site = factor(sample(c("Site1", "Site2", "Site3"), 100, replace = TRUE))
#' )
#'
#' # Create a simple summary table
#' table1(form = arm ~ sex + age + bmi, data = trial_data)
#'
#' # Create a table with totals
#' table1(form = arm ~ sex + age + bmi, data = trial_data, totals = TRUE)
#'
#' # Create a table without p-values
#' table1(form = arm ~ sex + age + bmi, data = trial_data, pvalue = FALSE)
#'
#' # Create a table with stratification
#' table1(form = arm ~ sex + age, data = trial_data, strata = "site")
#'
#' @export
table1 <- function(form, data, ...) {
  UseMethod("table1")
}

#' Create row names for table entries
#'
#' Internal function that generates appropriate row names for variables
#' in the summary table based on their type (factor, numeric, etc.)
#'
#' @param x Variable to create row names for
#' @param nm Name of the variable
#' @param missing Logical; whether to show missing values
#' @param ... Additional parameters
#'
#' @return Dataframe with variable names and codes
#' 
#' @examples
#' # For demonstration only, these functions are typically used internally
#' \dontrun{
#'   # For a factor variable:
#'   x <- factor(c("Male", "Female", "Male", NA))
#'   row_name(x, "Sex", missing = TRUE)
#'   
#'   # For a numeric variable:
#'   y <- c(23, 45, 67, NA, 34)
#'   row_name(y, "Age", missing = TRUE)
#' }
#'
#' @export
row_name <- function(x, nm, missing, ...) {
  UseMethod("row_name")
}

#' @describeIn row_name Method for factor variables
#' @export
row_name.factor <- function(x, nm, missing, ...) {
  categs <- levels(x)
  categs <- ifelse(is.na(categs), "<NA>", categs)
  nms <- cbind(variables = c(nm, categs), code = c(1, rep(2, length(categs))))
  return(as.data.frame(nms))
}

#' @describeIn row_name Method for numeric variables
#' @export
row_name.numeric <- function(x, nm, missing, ...) {
  out <- as.data.frame(cbind(variables = nm, code = 1))
  if (missing) {
    out2 <- as.data.frame(cbind(variables = "valid (missing)", code = 4))
    out <- rbind(out, out2)
  }
  return(out)
}

#' Create summary statistics for table rows
#'
#' Internal function that generates appropriate summary statistics for variables
#' in the summary table based on their type (factor, numeric, etc.)
#'
#' @param x Variable to summarize
#' @param grp Grouping variable
#' @param totals Logical; whether to show totals
#' @param missing Logical; whether to show counts of missing values
#' @param ... Additional parameters
#'
#' @return Dataframe with summary statistics
#' 
#' @examples
#' # For demonstration only, these functions are typically used internally
#' \dontrun{
#'   # For a factor variable:
#'   x <- factor(c("Yes", "No", "Yes", "No", "Yes"))
#'   grp <- factor(c("Treatment", "Treatment", "Placebo", "Placebo", "Placebo"))
#'   row_summary(x, grp, totals = TRUE)
#'   
#'   # For a numeric variable:
#'   y <- c(23, 45, 67, NA, 34)
#'   grp <- factor(c("Treatment", "Treatment", "Placebo", "Placebo", "Placebo"))
#'   row_summary(y, grp, totals = TRUE, missing = TRUE)
#' }
#'
#' @export
row_summary <- function(x, grp, totals, missing, ...) {
  UseMethod("row_summary")
}

#' @describeIn row_summary Method for factor variables
#' @export
row_summary.factor <- function(x, grp, totals, ...) {
  df <- data.frame(x = x, grp = grp)
  t1 <- df |>
    tabyl(x, grp, show_missing_levels = TRUE)
  if (totals) {
    t1 <- t1 |> adorn_totals("col")
  }
  t1 <- t1 |>
    adorn_percentages("col") |>
    adorn_pct_formatting(digits = 0) |>
    adorn_ns(position = "front") |>
    select(-x)
  names(t1) <- gsub("NA_", "<NA>", names(t1))
  return(rbind("", t1))
}


#' @describeIn row_summary Method for numeric variables
#' @export
row_summary.numeric <- function(x, grp, totals, missing, ...) {
  sp <- split(x, grp)
  if (totals) sp[["Total"]] <- x
  
  # Keep the original implementation to ensure identical output
  mm <- sapply(sp, function(x) round(mean(x, na.rm = TRUE), 2))
  ss <- sapply(sp, function(x) round(sd(x, na.rm = TRUE), 2))
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

#' Calculate p-values for comparisons
#'
#' Internal function that calculates appropriate statistical tests and p-values
#' based on variable type (factor, numeric, etc.)
#'
#' @param x Variable to test
#' @param grp Grouping variable
#' @param missing Logical; whether to show missing values
#' @param ... Additional parameters
#'
#' @return Vector of p-values
#' 
#' @examples
#' # For demonstration only, these functions are typically used internally
#' \dontrun{
#'   # For a factor variable:
#'   x <- factor(c("Yes", "No", "Yes", "No", "Yes"))
#'   grp <- factor(c("Treatment", "Treatment", "Placebo", "Placebo", "Placebo"))
#'   row_pv(x, grp)
#'   
#'   # For a numeric variable:
#'   y <- c(23, 45, 67, NA, 34)
#'   grp <- factor(c("Treatment", "Treatment", "Placebo", "Placebo", "Placebo"))
#'   row_pv(y, grp, missing = TRUE)
#' }
#'
#' @export
row_pv <- function(x, grp, missing, ...) {
  UseMethod("row_pv")
}

#' @describeIn row_pv Method for factor variables
#' @export
row_pv.factor <- function(x, grp, ...) {
  categs <- levels(x) |>
    length()
  if (categs >= 2) {
    tab <- data.frame(x = x, grp = grp) |>
      tabyl(x, grp, show_missing_levels = FALSE)
    pv <- tab |>
      janitor::fisher.test() |>
      pluck("p.value") |>
      round(4)
    # pv <- data.frame(x = x, y = y) |>
    #   tabyl(x, y, show_missing_levels = FALSE) |>
    #   janitor::fisher.test() |>
    #   pluck("p.value") |>
    #   round(4)
  } else {
    pv <- NA
  }
  return(c(pv, rep("", categs)))
}


#' @describeIn row_pv Method for numeric variables
#' @export
row_pv.numeric <- function(x, grp, missing, ...) {
  pv <- lm(x ~ grp) |>
    tidy() |>
    slice(2) |>
    pluck("p.value") |>
    round(4) |>
    as.character()
  if (missing) {
    pv <- c(pv, "")
  }

  return(pv)
}

#' Insert rows into a dataframe
#'
#' Helper function to insert rows at specific positions in a dataframe.
#' Used internally for adding section headers and other formatting elements.
#'
#' @param df Dataframe to modify
#' @param r Row indices where to insert
#' @param newrows Rows to insert
#' @param rcurr Logical; whether to count current or original rows
#'
#' @return Modified dataframe
#'
#' @examples
#' # Create a sample dataframe
#' df <- data.frame(a = 1:5, b = letters[1:5])
#' 
#' # Create new rows to insert
#' new_rows <- data.frame(a = c(99, 100), b = c("header1", "header2"))
#' 
#' # Insert rows at positions 2 and 4
#' berryFunctions::insertRows(df, c(2, 4), new_rows)
insertRows <- function(df, r, newrows, rcurr = FALSE) {
  # Check inputs
  if (!is.data.frame(df) || !is.data.frame(newrows)) {
    stop("Both df and newrows must be data frames")
  }
  
  if (ncol(df) != ncol(newrows)) {
    stop("df and newrows must have the same number of columns")
  }
  
  # Ensure column names match
  names(newrows) <- names(df)
  
  # Convert row indices to original frame indices if necessary
  if (rcurr) {
    r <- cumsum(c(0, rep(1, length(r) - 1))) + r
  }
  
  # Insert rows
  res <- df
  for (i in seq_along(r)) {
    if (r[i] == 1) {
      res <- rbind(newrows[i, , drop = FALSE], res)
    } else if (r[i] > nrow(res)) {
      res <- rbind(res, newrows[i, , drop = FALSE])
    } else {
      res <- rbind(
        res[1:(r[i] - 1), , drop = FALSE],
        newrows[i, , drop = FALSE],
        res[r[i]:nrow(res), , drop = FALSE]
      )
    }
  }
  
  return(res)
}

#' Stratify table by another variable
#'
#' Creates a stratified table where summary statistics are calculated
#' separately within each level of the stratification variable.
#'
#' @param x List of variables to summarize
#' @param grp Grouping variable
#' @param strat Stratification variable
#' @param size Logical; whether to show group sizes
#' @param totals Logical; whether to show totals
#' @param missing Logical; whether to show missing values
#' @param ... Additional parameters
#'
#' @return Stratified table with headers for each stratum
#'
#' @examples
#' # Create sample data
#' x_vars <- list(
#'   age = c(23, 45, 67, 34, 29),
#'   sex = factor(c("Male", "Female", "Male", "Female", "Male"))
#' )
#' grp <- factor(c("Treatment", "Treatment", "Placebo", "Placebo", "Placebo"))
#' strat <- factor(c("Site1", "Site1", "Site1", "Site2", "Site2"))
#' 
#' # This is typically called by table1.formula, not directly
#' # stratify(x_vars, grp, strat, size = TRUE, totals = TRUE, missing = TRUE)
stratify <- function(x, grp, strat, size, totals, missing, ...) {
  x_lst <- split(x, strat)
  grp_lst <- split(grp, strat)
  tab <- map2(x_lst, grp_lst, function(x, grp) {
    build(x = x, grp = grp, size = size, totals = totals, missing = missing, ...)
  })
  tab1 <- bind_rows(tab)

  # rownames(tab1) <- NULL
  new <- data.frame(matrix(NA, nrow = length(tab), ncol = ncol(tab1)))
  names(new) <- names(tab1)
  new$variables <- names(tab)
  new$code <- 5
  rr <- cumsum(c(1, rep(nrow(tab[[1]]) + 1, length(tab) - 1)))
  tab5 <- insertRows(tab1, rr, new, rcurr = FALSE)
}


#' Build a summary table
#'
#' Main internal function that assembles the summary table by combining
#' variable names, summary statistics, and p-values.
#'
#' @param x List of variables to summarize
#' @param grp Grouping variable
#' @param size Logical; whether to show group sizes
#' @param totals Logical; whether to show totals
#' @param missing Logical; whether to show missing values
#' @param ... Additional parameters
#'
#' @return Summary table as a dataframe
#'
#' @examples
#' # Create sample data
#' x_vars <- list(
#'   age = c(23, 45, 67, 34, 29),
#'   sex = factor(c("Male", "Female", "Male", "Female", "Male"))
#' )
#' grp <- factor(c("Treatment", "Treatment", "Placebo", "Placebo", "Placebo"))
#' 
#' # This is typically called by table1.formula, not directly
#' # build(x_vars, grp, size = TRUE, totals = TRUE, missing = TRUE)
build <- function(x, grp, size, totals, missing, ...) {
  left <- x |>
    imap(row_name, missing = missing, ...) |>
    bind_rows()
  right <- x |>
    map(row_pv, grp = grp, missing = missing, ...) |>
    unlist() |>
    enframe(name = NULL) |>
    setNames("p.value")
  mid <- x |>
    map(row_summary, grp = grp, totals = totals, missing = missing, ...) |>
    bind_rows()

  if (size) {
    left <- rbind(c("number", 3), left)
    tt <- table(grp, useNA = "ifany")
    if (totals) {
      tt <- tt |> addmargins(FUN = list(Total = sum))
    }
    mid <- rbind(tt, mid)
    right <- rbind("", right)
  }
  tab <- bind_cols(left, mid, right)
  rownames(tab) <- NULL
  return(tab)
}

#' @describeIn table1 Method for formula interface
#' @export
table1.formula <- function(form, data, strata = NULL,
                          block = NULL, missing = FALSE,
                          pvalue = TRUE, size = FALSE, totals = FALSE,
                          fname = "table1", layout = "console", ...) {
  formtest <- as.character(form)
  vars <- all.vars(form)
  # grp_logic = ifelse(!is.null(grp), TRUE, FALSE)
  grp_logic <- ifelse(length(form) > 2, TRUE, FALSE)
  # if grp_logic is false create a dummy variable named grp with random
  # assignment to 1 and 0.  
  if (!grp_logic & !totals) {
    stop("If totals = FALSE, then grp must be specified")
  }
  if (!grp_logic & pvalue) {
    stop("If pvalue = TRUE, then grp must be specified")
  }
  if (grp_logic) {
    grp <- deparse(form[[2]])
    x_vars <- all.vars(form)[-1]
  } else {
    data$grp <- sample(c(0, 1), nrow(data), replace = TRUE)
    grp <- "grp"
    x_vars <- all.vars(form)
  }
  strata_logic <- ifelse(!is.null(strata), TRUE, FALSE)
  dat0 <- data[c(x_vars, grp, strata)]

  dat0 <- map_dfr(
    dat0,
    function(x) {
      if (class(x) %in% c("character", "factor", "logical")) {
        x <- as.character(x)
        x <- factor(x)

        if (missing) {
          levels(x) <- c(levels(x), "<NA>")
          x[is.na(x)] <- "<NA>"
          return(x)
        } else {
          x
        }
      } else {
        x
      }
    }
  )

  if (strata_logic) {
    tab0 <- stratify(
      x = dat0[x_vars], grp = data[[grp]],
      strat = data[[strata]], size = size, totals = totals, missing = missing, ...
    )
  } else {
    tab0 <- build(
      x = dat0[x_vars], grp = data[[grp]], size = size, totals = totals,
      missing = missing, ...
    )
  }
  if (!pvalue) {
    tab0 <- tab0 |>
      dplyr::select(-p.value)
  }
  if (!grp_logic) {
    tab0 <- tab0 |>
      dplyr::select(variables, code, contains("Total"))
  }
class(tab0) <- c("table1", class(tab0))
  return(tab0)
}

#' Print method for table1 objects
#'
#' Prints a table1 object, excluding the code column.
#'
#' @param x A table1 object
#' @param ... Additional arguments passed to print methods
#'
#' @return The table without the code column
#'
#' @examples
#' # Create a sample table
#' set.seed(123)
#' trial_data <- data.frame(
#'   arm = factor(rep(c("Treatment", "Placebo"), each = 50)),
#'   age = rnorm(100, mean = 45, sd = 15)
#' )
#' tab <- table1(form = arm ~ age, data = trial_data)
#'
#' # Print the table
#' print(tab)
#'
#' @export
print.table1 <- function(x, ...) {
  # Remove the class "table1" to avoid recursive calls to print.table1
  class(x) <- setdiff(class(x), "table1")
  
  # Remove the code column
  result <- x[, colnames(x) != "code", drop = FALSE]
  
  # Print using the standard print method
  print(result, ...)
  
  # Return invisibly
  invisible(x)
}


#' NEJM-style theme for tables
#'
#' A predefined theme for formatting tables in the style of 
#' the New England Journal of Medicine.
#'
#' @format A list with two elements:
#' \describe{
#'   \item{foreground}{A vector of foreground (text) colors}
#'   \item{background}{A vector of background colors}
#' }
#'
#' @examples
#' # View the NEJM theme definition
#' theme_nejm
#'
#' @export
theme_nejm <- list(
  foreground = c("black", "black", "black", "black", "black"),
  background = c("#fff7e9", "white", "#fff7e9", "white", "white")
)

#' Export table to LaTeX format
#'
#' Formats and exports a table1 object to LaTeX format with customizable styling.
#'
#' @param tab Table created by table1()
#' @param digits Number of digits to display for numeric values
#' @param fname Filename for the output LaTeX file
#' @param theme List with foreground and background colors for table rows
#' @param ... Additional parameters passed to kable
#'
#' @return A kable object representing the formatted table
#'
#' @examples
#' # Create a sample table
#' \dontrun{
#' set.seed(123)
#' trial_data <- data.frame(
#'   arm = factor(rep(c("Treatment", "Placebo"), each = 50)),
#'   age = rnorm(100, mean = 45, sd = 15),
#'   sex = factor(sample(c("Male", "Female"), 100, replace = TRUE))
#' )
#' tab <- table1(form = arm ~ age + sex, data = trial_data)
#'
#' # Export to LaTeX
#' latex(tab, digits = 2, fname = "my_table")
#'
#' # Use a custom theme
#' my_theme <- list(
#'   foreground = c("black", "black", "black", "black", "black"),
#'   background = c("#f0f0f0", "white", "#f0f0f0", "white", "white")
#' )
#' latex(tab, theme = my_theme)
#' }
#'
#' @export
#' @describeIn table1 interprets formula and yields publication tables
latex <- function(tab, digits = 3, fname = "table0", theme = theme_nejm, ...) {
  tab5 <- dplyr::mutate(tab,
    variables = ifelse(code %in% c(2, 4),
      gsub("^", "\\\\quad ", variables), variables
    ),
    variables = gsub("TRUE", "true", variables),
    variables = gsub("FALSE", "false", variables)
    # missing = gsub("NA", "-", missing),
    # missing = gsub("NaN", "-", missing)
  )
  # tab6$vars = gsub("_","\_",tab6$vars)
  strp <- map(sort(unique(tab5$code)), function(x) {
    which(tab5$code == x)
  })
  myfcn <- function(x, i, theme = theme) {
    x <- x |> row_spec(strp[[i]],
      color = theme$foreground[i],
      background = theme$background[i]
    )
  }

  tab5 <- tab5 |>
    dplyr::select(-code)
  kk <- kbl(tab5, "latex",
    booktabs = TRUE, linesep = "",
    escape = FALSE, digits = digits,
    ...
  )

  tab5plusstripes <- reduce(1:length(strp),
    ~ myfcn(.x, .y, theme = theme),
    .init = kk
  )
  write(tab5plusstripes, paste0("./tables/", fname, ".tex"))
  system(paste0("sh ~/shr/figurize.sh ./tables/", fname, ".tex"))
  return(tab5plusstripes)
}
