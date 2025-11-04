create_table(
  formula = treatment ~ Sepal.Length + Sepal.Width + Species,
  data = iris,
  pvalue = TRUE,
  theme = "console"
)
