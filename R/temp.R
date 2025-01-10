
frm <- function(form) {
  vars <- all.vars(form)
  y_var <- deparse(form[[2]])
  g_bar <- deparse(form[[c(3, 1)]])
  g_var <- NULL
  if (g_bar == "|") {
    x_vars <- all.vars(form[[c(3, 2)]])
    g_var <- all.vars(form[[c(3, 3)]])
    group <- data[g_var]
  } else {
    x_vars <- all.vars(form)[-1]
  }
}
