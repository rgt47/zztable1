#' zztable1: Create "Table One" Summaries for Clinical Trials
#'
#' The `zztable1` package provides tools to create descriptive summary tables,
#' often referred to as "table one," that summarize baseline characteristics
#' of clinical trial or observational study participants by treatment groups
#' or other stratification variables. The package supports numeric and categorical
#' data, handles missing values, and generates publication-ready tables in
#' LaTeX or HTML formats.
#'
#' Key features of `zztable1` include:
#'
#' - **Stratification:** Generate summaries by treatment groups or stratified
#'   by a third variable (e.g., study sites).
#' - **P-Value Calculation:** Perform statistical tests (e.g., Fisher's exact test
#'   for categorical variables, linear regression for numeric variables) to include
#'   p-values for group comparisons.
#' - **Handling Missing Data:** Explicitly represent missing data in summaries and
#'   calculations where applicable.
#' - **Descriptive Statistics:** Compute means, standard deviations, and percentages
#'   for numeric and categorical variables.
#' - **Customizable Outputs:** Output tables in LaTeX or HTML with themes and
#'   styles suitable for publication.
#' - **Integration with Tidyverse:** Seamless compatibility with `dplyr` and other
#'   tidyverse tools for streamlined data manipulation.
#'
#' The package uses a modular design with generic methods for flexibility.
#' Methods are provided for both numeric and factor variables, enabling
#' extensions for additional data types if needed.
#'
#' # Installation
#'
#' To install the latest development version from GitHub, use:
#' \code{remotes::install_github("rgt47/zztable1")}
#'
#' # Getting Started
#'
#' The main function is `table1()`, which generates summary tables based on
#' a formula interface. The typical usage pattern is as follows:
#'
#' \code{
#' table1(
#'   data = dataset,
#'   form = group_variable ~ var1 + var2 + var3,
#'   strata = NULL, # Optional stratification variable
#'   pvalue = TRUE, # Include p-values
#'   totals = FALSE, # Add totals column
#'   missing = TRUE, # Show missing values explicitly
#'   layout = "console" # Output format
#' )
#' }
#'
#' For example, given a dataset `dat` with variables for treatment groups,
#' age, and gender:
#'
#' \code{
#' table1(dat, form = treatment ~ age + gender)
#' }
#'
#' This function will generate a summary table with descriptive statistics
#' for age and gender by treatment group.
#'
#' # Outputs
#'
#' The package supports output in multiple formats:
#'
#' - **Console Output:** View tables directly in the R console.
#' - **LaTeX Output:** Create publication-ready LaTeX tables with the `latex()`
#'   function, complete with custom themes.
#' - **HTML Output:** Generate styled HTML tables for inclusion in reports or
#'   web pages.
#'
#' # Dependencies
#'
#' The package leverages the following libraries:
#'
#' - `janitor`: For tabulations and table cleaning.
#' - `dplyr` and `purrr`: For data manipulation and functional programming.
#' - `kableExtra`: For table formatting and customization.
#' - `tibble`: For enhanced data frame handling.
#' - `broom`: For regression summaries.
#'
#' # Acknowledgments
#'
#' This package was inspired by the need for efficient, reproducible tools to
#' create "table one" summaries in clinical trial analyses. It builds upon
#' established R libraries to provide a user-friendly interface for data
#' summary and visualization.
#'
#' @docType package
#' @name zztable1
#' @aliases zztable1-package
#' Generate "Table One" Summaries for Clinical Trials
#'
#' The `table1` function generates descriptive summary tables (commonly called "table one")
#' to summarize baseline characteristics in clinical trials or observational studies.
#' It allows grouping by a treatment or stratification variable, includes statistical
#' tests for comparisons, and can output results in various formats suitable for
#' publication or exploration.
#'
#' The function supports both numeric and categorical variables, as well as stratification,
#' handling of missing data, and customization of output formats.
#'
#' @param form A formula specifying the grouping variable and variables to summarize.
#'   For example, \code{group ~ var1 + var2}.
#' @param data A data frame containing the variables specified in \code{form}.
#' @param strata An optional stratification variable for subgroup analyses (default: \code{NULL}).
#'   When specified, the function generates separate tables for each level of the stratification variable.
#' @param block A variable or grouping criterion used to organize rows of the
#'   summary table into distinct sections (blocks). Useful for grouping rows
#'   by categories like "Demographics" or "Clinical Characteristics" (default: \code{NULL}).
#' @param missing Logical. Should missing values be explicitly shown in summaries? (default: \code{FALSE}).
#' @param pvalue Logical. Should p-values for comparisons be included? (default: \code{TRUE}).
#' @param totals Logical. Should totals (e.g., column sums) be included in the summary? (default: \code{FALSE}).
#' @param fname Character. File name for saving outputs (used with LaTeX output). Default: \code{"table1"}.
#' @param layout Character. Output format. Options are \code{"console"}, \code{"latex"}, or \code{"html"}
#'   (default: \code{"console"}).
#' @param ... Additional arguments passed to lower-level functions for customization.
#'
#' @return A data frame representing the summary table, or a formatted table
#'   if \code{layout = "latex"} or \code{layout = "html"}.
#'
#' @details
#' Numeric variables are summarized with mean and standard deviation, while
#' categorical variables are summarized with frequencies and percentages.
#' P-values are calculated using Fisher's exact test for categorical variables
#' and linear regression for numeric variables.
#'
#' If a stratification variable is provided, summaries are generated for each
#' level of the stratification variable.
#'
#' @examples
#' # Example dataset
#' library(dplyr)
#' data <- data.frame(
#'         treatment = factor(c(rep("A", 50), rep("B", 50))),
#'         age = rnorm(100, mean = 50, sd = 10),
#'         sex = factor(sample(c("Male", "Female"), 100, replace = TRUE)),
#'         site = factor(rep(c("Site 1", "Site 2"), each = 50))
#' )
#'
#' # Basic usage
#' table1(data = data, form = treatment ~ age + sex)
#'
#' # Including totals and p-values
#' table1(data = data, form = treatment ~ age + sex, totals = TRUE, pvalue = TRUE)
#'
#' # Stratification by site
#' table1(data = data, form = treatment ~ age + sex, strata = "site")
#'
#' # Excluding missing values
#' table1(data = data, form = treatment ~ age + sex, missing = TRUE)
#'
#' # Output as LaTeX for publication
#' summary_table <- table1(data = data, form = treatment ~ age + sex)
#' latex(summary_table, fname = "summary_table", digits = 2)
#'
#' # Output as HTML for web-based reports
#' html(summary_table)
#'
#' @export
table1 <- function(form, data, ...) {
        # Use the S3 generic method for `table1`, allowing for formula and print methods.
        UseMethod("table1")
}

row_name <- function(x, nm, missing, ...) {
        UseMethod("row_name")
}

#' @keywords internal
#' @keywords internal
row_name.factor <- function(x, nm, missing = FALSE, ...) {
  # Add "<NA>" as a level if missing = TRUE
  if (missing) {
    levels(x) <- c(levels(x), "<NA>")
    x[is.na(x)] <- "<NA>"
  }
  
  # Generate variable names
  categs <- levels(x)
  categs <- ifelse(is.na(categs), "<NA>", categs)  # Ensure <NA> is included
  nms <- cbind(
    variables = c(nm, categs),  # Include variable name and factor levels
    code = c(1, rep(2, length(categs)))  # Assign codes: 1 for name, 2 for levels
  )
  
  # Return as a data frame
  return(as.data.frame(nms))
}

#' @keywords internal
row_name.numeric <- function(x, nm, missing, ...) {
        # Create a data frame with the variable name and a code (1 = numeric).
        out <- as.data.frame(cbind(variables = nm, code = 1))

        if (missing) {
                # If missing values are included, add an extra row for "valid (missing)".
                out2 <- as.data.frame(cbind(variables = "valid (missing)", code = 4))
                out <- rbind(out, out2) # Combine the rows.
        }

        # Return the resulting data frame.
        return(out)
}

row_summary <- function(x, grp, totals, missing, ...) {
        UseMethod("row_summary")
}

#' @keywords internal
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


#' @keywords internal
row_summary.numeric <- function(x, grp, totals = FALSE, missing = FALSE, ...) {
  # Split the numeric variable by group
  sp <- split(x, grp)
  
  if (totals) {
    # Add a "Total" group for all observations
    sp[["Total"]] <- x
  }
  
  # Compute mean and SD for each group
  mm <- sp |>
    map_vec(mean, na.rm = TRUE) |>
    round(2)
  
  ss <- sp |>
    map_vec(sd, na.rm = TRUE) |>
    round(2) |>
    (\(x) paste0("(", x, ")"))()
  
  # Combine mean and SD
  out <- paste(mm, ss)
  names(out) <- names(sp)  # Add group names as column names
  
  if (missing) {
    # Add valid and missing counts
    misscnt <- sapply(sp, function(x) sum(is.na(x)))
    validcnt <- sapply(sp, function(x) sum(!is.na(x)))
    out <- rbind(
      out,
      "valid (missing)" = paste0(validcnt, " (", misscnt, ")")
    ) |> as.data.frame()
    names(out) <- names(sp)  # Handle NA names gracefully
  } else {
    out <- as.data.frame(out)  # Ensure output is always a data frame
  }
  
  # Ensure the "Total" column exists when totals = TRUE
  if (totals && !"Total" %in% colnames(out)) {
    colnames(out)[ncol(out)] <- "Total"
  }
  
  return(out)
}

row_pv <- function(x, grp, missing, ...) {
        UseMethod("row_pv")
}

#' @keywords internal
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


#' @keywords internal
#' @keywords internal
row_pv.numeric <- function(x, grp, missing = FALSE, ...) {
  # Perform a linear regression to calculate the p-value
  pv <- lm(x ~ grp) |>
    tidy() |>
    slice(2) |>
    pluck("p.value") |>
    round(4) |>
    as.character()
  
  # If missing is TRUE, append a blank row
  if (missing) {
    pv <- c(pv, "")
  }

  # Return the p-value as a character vector
  return(pv)
}

#' @keywords internal
stratify <- function(x, grp, strat, totals, missing, ...) {
  # Split the data by stratification variable
  x_lst <- split(x, strat)
  grp_lst <- split(grp, strat)
  
  # Debug: Print stratification levels
  message("Stratification levels: ", paste(unique(strat), collapse = ", "))
  
  # Ensure factor levels are preserved for each stratum
  x_lst <- map(x_lst, function(df) {
    map(df, function(col) {
      if (is.factor(col)) {
        message("Preserving levels for factor: ", deparse(substitute(col)))
        factor(col, levels = levels(x[[1]]))  # Preserve original levels
      } else {
        col
      }
    }) |> as.data.frame()
  })
  
  # Build the table for each stratum, skipping invalid subsets
  tab <- map2(x_lst, grp_lst, function(x_stratum, grp_stratum) {
    message("Processing stratum with grouping levels: ", paste(unique(grp_stratum), collapse = ", "))
    if (length(unique(grp_stratum)) < 2) {
      warning("Stratum skipped due to insufficient levels in grouping variable.")
      return(NULL)
    }
    build(x = x_stratum, grp = grp_stratum, totals = totals, missing = missing, ...)
  })
  
  # Filter out NULL entries caused by skipped strata
  tab <- compact(tab)
  
  if (length(tab) == 0) {
    warning("All strata were skipped due to insufficient levels.")
    return(NULL)
  }
  
  # Combine the stratified tables
  tab1 <- bind_rows(tab)
  
  # Create a new data frame for the stratification labels
  new <- data.frame(matrix(NA, nrow = length(tab), ncol = ncol(tab1)))
  names(new) <- names(tab1)
  new$variables <- names(tab)
  new$code <- 5
  
  # Insert the stratification labels into the final table
  rr <- cumsum(c(1, rep(nrow(tab[[1]]) + 1, length(tab) - 1)))
  tab5 <- insertRows(tab1, rr, new, rcurr = F)
  
  # Debug: Print final table dimensions
  message("Final stratified table dimensions: ", nrow(tab5), " rows, ", ncol(tab5), " columns")
  
  return(tab5)
}


build <- function(x, grp, size, totals, missing, ...) {
  # Generate the left panel of the table
  left <- x |>
    imap(row_name, missing = missing, ...) |>
    bind_rows()
  
  # Generate the right panel of the table
  right <- x |>
    map(row_pv, grp = grp, missing = missing, ...) |>
    unlist() |>
    enframe(name = NULL) |>
    setNames("p.value")
  
  # Generate the middle panel of the table
  mid <- x |>
    map(row_summary, grp = grp, totals = totals, missing = missing, ...) |>
    bind_rows()
  
  # Debugging: Print dimensions
  message("Dimensions of left: ", nrow(left))
  message("Dimensions of mid: ", nrow(mid))
  message("Dimensions of right: ", nrow(right))
  
browser()
  if (size) {
    left <- rbind(c("number", 3), left)
    tt <- table(grp, useNA = "ifany")
    if (totals) {
      tt <- tt |> addmargins(FUN = list(Total = sum))
    }
    mid <- rbind(tt, mid)
    right <- rbind("", right)
  }
  
  # Combine all panels into a single table
  tab <- bind_cols(left, mid, right)
  rownames(tab) <- NULL
  
  return(tab)
}

#' @export
#' @describeIn table1 Interprets formula and yields publication-ready tables

table1.formula <- function(form, data, strata = NULL,
                           block = NULL, missing = FALSE,
                           size = FALSE, pvalue = TRUE, totals = FALSE,
                           fname = "table1", layout = "console", ...) {
        # Convert formula to character for easier manipulation.
        formtest <- as.character(form)

        # Extract variable names from the formula.
        vars <- all.vars(form)

        # Determine if there is a grouping variable.
        grp_logic <- ifelse(length(form) > 2, TRUE, FALSE)

        # Extract the grouping variable or set it to NULL.
        grp <- if (grp_logic) deparse(form[[2]]) else NULL

        # Extract independent variables from the formula.
        x_vars <- if (grp_logic) all.vars(form)[-1] else all.vars(form)

        # Determine if stratification is specified.
        strata_logic <- !is.null(strata)

        # Subset the dataset to include only relevant variables.
        dat0 <- data[c(x_vars, grp, strata)]

        # Clean and preprocess the dataset.
        dat0 <- map_dfr(dat0, function(x) {
                # Convert character, factor, or logical variables to factors.
                if (class(x) %in% c("character", "factor", "logical")) {
                        x <- as.character(x)
                        x <- factor(x)
                        if (missing) {
                                # Add "<NA>" as a level for missing values if requested.
                                levels(x) <- c(levels(x), "<NA>")
                                x[is.na(x)] <- "<NA>"
                                return(x)
                        } else {
                                return(x)
                        }
                } else {
                        return(x)
                }
        })
        # Generate summaries based on stratification or not.
        if (strata_logic) {
                # Call the stratify function if a stratification variable is provided.
                tab0 <- stratify(
                        x = dat0[x_vars], grp = data[[grp]],
                        strat = data[[strata]], totals = totals, missing = missing, ...
                )
        } else {
                # Otherwise, build the table directly.
                tab0 <- build(
                        x = dat0[x_vars], grp = data[[grp]], totals = totals,
                        size = size,
                        missing = missing, ...
                )
        }
browser()
        # Remove the p-value column if not requested.
        if (!pvalue) {
                tab0 <- tab0 |>
                        dplyr::select(-p.value)
        }

        # If no grouping variable, reduce the output to Total and p-value columns.
        if (!grp_logic) {
                tab0 <- tab0 |>
                        dplyr::select(variables, code, contains("Total"), p.value)
        }

        # Return the resulting table.
        return(tab0)
}

#' @export
table1.print <- function(tabler) {
        tabler[-2]
}

word <- function(tabler) {}

#' @keywords internal
#' @export
#' @describeIn table1 interprets formula and yields publication tables
html <- function(tabler) {
        kk <- kbl(tabler, "html",
                escape = F, digits = digits
        )
        tabhtml <- reduce(1:length(stripes),
                ~ myfcn(.x, .y, theme = theme),
                .init = kk
        )
}


theme_nejm <- list(
        foreground = c("black", "black", "black", "black", "black"),
        background = c("#fff7e9", "white", "#fff7e9", "white", "white")
)

#' @keywords internal
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
                booktabs = T, linesep = "",
                escape = F, digits = digits
        )

        tab5plusstripes <- reduce(1:length(strp),
                ~ myfcn(.x, .y, theme = theme),
                .init = kk
        )
        write(tab5plusstripes, paste0("./tables/", fname, ".tex"))
        system(paste0("sh ~/shr/figurize.sh ./tables/", fname, ".tex"))
        return(tab5plusstripes)
}


# options(knitr.kable.NA = "")
# library(pacman)
# p_load(
#         berryFunctions, atable, purrr, kableExtra, tibble,
#         janitor, broom, palmerpenguins, dplyr
# )
# set.seed(10)
# p1 <- sample_n(penguins, 100) |>
#         dplyr::select(
#                 species, flipper_length_mm, sex,
#                 body_mass_g, bill_length_mm, island
#         ) |>
#         dplyr::mutate(flp = flipper_length_mm > 197) |>
#         dplyr::filter(!is.na(sex))

# size <- c(TRUE, FALSE)
# pvalue <- c(TRUE, FALSE)
# totals <- c(TRUE, FALSE)
# missing <- c(TRUE, FALSE)
# strata_logic <- c(TRUE, FALSE)
# grp_logic <- c(TRUE, FALSE)

# pmap_wrap <- function(x) {
#         pmap(x, function(size, pvalue, totals, missing, strata_logic, grp_logic) {
#                 fname <- paste0(
#                         "strt", strata_logic, "grp", grp_logic, "size",
#                         size, "pv", pvalue, "tot", totals, "miss", missing
#                 )
#                 form1 <- "sex ~ flp + body_mass_g + bill_length_mm"
#                 form2 <- " ~ flp + body_mass_g + bill_length_mm"
#                 form <- ifelse(grp_logic, form1, form2)
#                 strata <- NULL
#                 if (strata_logic) {
#                         strata <- "island"
#                 }
#                 table1(as.formula(form),
#                         strata = strata,
#                         data = p1, pvalue = pvalue, size = size,
#                         totals = totals, missing = missing
#                 ) |>
#                         latex(theme = theme_nejm, fname = fname, digits = 3)
#                 out_file <- paste0(
#                         "\\vspace{.5in} \\begin{figure}[htpb] \\centering
#     \\includegraphics[width=0.8 \\textwidth]{./tables/",
#                         fname, ".pdf} \\caption{", fname, "} \\end{figure}"
#                 )
#                 cat(out_file, file = "temp.tex", append = T)
#         })
# }

# grid <- expand.grid(
#         size = size, pvalue = pvalue,
#         totals = totals, missing = missing, strata_logic = strata_logic, grp_logic = grp_logic
# )
# if (file.exists("temp.tex")) {
#         foo <- file.remove("temp.tex")
# }
# grid2 <- slice(grid, 1:32)
# out <- grid2 %>% pmap_wrap()
