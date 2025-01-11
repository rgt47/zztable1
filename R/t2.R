#' Table one summaries
#'
#' Summarizes baseline trial results by treatment
#' @param data dataframe
#' @param form formula y ~ x1 + x2
#' @param ... extra parameters passed through to speciality functions
#' @return a dataframe
#' @examples
#' table1(dat2, form = arm ~ sex + age, annot = FALSE)

#' @export
table1 <- function(form, data, ...) {
  UseMethod("table1")
}

row_name <- function(x, nm, missing, ...) {
  UseMethod("row_name")
}

#' @export
row_name.factor <- function(x, nm, missing, ...) {
  categs <- levels(x)
  categs <- ifelse(is.na(categs), "<NA>", categs)
  nms <- cbind(variables = c(nm, categs), code = c(1, rep(2, length(categs))))
  return(as.data.frame(nms))
}

#' @export
row_name.numeric <- function(x, nm, missing, ...) {
  out <- as.data.frame(cbind(variables = nm, code = 1))
  if (missing) {
    out2 <- as.data.frame(cbind(variables = "valid (missing)", code = 4))
    out <- rbind(out, out2)
  }
  return(out)
}

row_summary <- function(x, grp, totals, missing, ...) {
  UseMethod("row_summary")
}

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


#' @export
row_summary.numeric <- function(x, grp, totals, missing, ...) {
  sp <- split(x, grp)
  if (totals) sp[["Total"]] <- x
  mm <- sp |>
    map_vec(mean, na.rm = TRUE) |>
    round(2)
  ss <- sp |>
    map_vec(sd, na.rm = TRUE) |>
    round(2) |>
    paste0("(", x = _, ")")
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

row_pv <- function(x, grp, missing, ...) {
  UseMethod("row_pv")
}

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

stratify <- function(x, grp, strat, totals, missing, ...) {
  x_lst <- split(x, strat)
  grp_lst <- split(grp, strat)
  tab <- map2(x_lst, grp_lst, function(x, grp) {
    build(x = x, grp = grp, totals = totals, missing = missing, ...)
  })
  tab1 <- bind_rows(tab)

  # rownames(tab1) <- NULL
  new <- data.frame(matrix(NA, nrow = length(tab), ncol = ncol(tab1)))
  names(new) <- names(tab1)
  new$variables <- names(tab)
  new$code <- 5
  rr <- cumsum(c(1, rep(nrow(tab[[1]]) + 1, length(tab) - 1)))
  tab5 <- insertRows(tab1, rr, new, rcurr = F)
}


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

#' @export
#' @describeIn table1 interprets formula and yields publication tables
table1.formula <- function(form, data, strata = NULL,
                           block = NULL, missing = FALSE,
                           pvalue = TRUE, totals = FALSE,
                           fname = "table1", layout = "console", ...) {
  formtest <- as.character(form)
  vars <- all.vars(form)
  # grp_logic = ifelse(!is.null(grp), TRUE, FALSE)
  grp_logic = ifelse(length(form) > 2, TRUE, FALSE)
  if (grp_logic) {
	  grp <- deparse(form[[2]])
  x_vars <- all.vars(form)[-1]

  } else {
	  grp=NULL
  x_vars <- all.vars(form)
  }
  strata_logic = ifelse(!is.null(strata), TRUE, FALSE)
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
      strat = data[[strata]], totals = totals, missing = missing, ...
    )
  } else {
    tab0 <- build(x = dat0[x_vars], grp = data[[grp]], totals = totals,
		  missing = missing, ...)
  }
  if (!pvalue) {
    tab0 <- tab0 |>
      dplyr::select(-p.value)
  }
  if (!grp_logic) {
    tab0 <- tab0 |>
      dplyr::select(variables, code, contains("Total"), p.value)
  }
  return(tab0)
}

#' @export
table1.print <- function(tabler) {
  tabler[-2]
}

word <- function(tabler) {}

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


options(knitr.kable.NA = "")
library(pacman)
p_load(
  berryFunctions, atable, purrr, kableExtra, tibble,
  janitor, broom, palmerpenguins, dplyr
)
set.seed(10)
p1 <- sample_n(penguins, 100) |>
  dplyr::select(
    species, flipper_length_mm, sex,
    body_mass_g, bill_length_mm, island
  ) |>
  dplyr::mutate(flp = flipper_length_mm > 197) |>
  dplyr::filter(!is.na(sex))

size <- c(TRUE, FALSE)
pvalue <- c(TRUE, FALSE)
totals <- c(TRUE, FALSE)
missing <- c(TRUE, FALSE)
strata_logic <- c(TRUE, FALSE)
grp_logic <- c(TRUE, FALSE)

pmap_wrap <- function(x) {
  pmap(x, function(size, pvalue, totals, missing, strata_logic, grp_logic) {
    fname <- paste0(
      "strt", strata_logic, "grp", grp_logic, "size",
      size, "pv", pvalue, "tot", totals, "miss", missing
    )
    form1 <- "sex ~ flp + body_mass_g + bill_length_mm"
    form2 <- " ~ flp + body_mass_g + bill_length_mm"
    form <- ifelse(grp_logic, form1, form2)
    strata = NULL
    if (strata_logic){strata="island"}
    table1(as.formula(form),
      strata = strata,
      data = p1, pvalue = pvalue, size = size,
      totals = totals, missing = missing
    ) |>
      latex(theme = theme_nejm, fname = fname, digits = 3)
    out_file <- paste0(
      "\\vspace{.5in} \\begin{figure}[htpb] \\centering
    \\includegraphics[width=0.8 \\textwidth]{./tables/",
      fname, ".pdf} \\caption{", fname, "} \\end{figure}"
    )
    cat(out_file, file = "temp.tex", append = T)
  })
}

grid <- expand.grid(
  size = size, pvalue = pvalue,
  totals = totals, missing = missing, strata_logic = strata_logic, grp_logic = grp_logic
)
if (file.exists("temp.tex")) {
  foo <- file.remove("temp.tex")
}
grid2 <- slice(grid, 1:32)
  # out <- grid2 %>% pmap_wrap()

