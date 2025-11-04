#!/usr/bin/env Rscript

# Test script to verify footnote functionality
source("R/table1.R")
source("R/blueprint.R") 
source("R/validation_consolidated.R")
source("R/dimensions.R")
source("R/cells.R")
source("R/themes.R")
source("R/rendering.R")
source("R/utils.R")

# Create test data
data(mtcars)
mtcars$transmission <- factor(ifelse(mtcars$am == 1, "Manual", "Automatic"))

# Create table with footnotes
cat("Creating table with footnotes...\n")
bp <- table1(
  transmission ~ mpg + hp,
  data = mtcars,
  theme = "nejm",
  footnotes = list(
    variables = list(
      mpg = "Miles per gallon EPA highway rating",
      hp = "Gross horsepower"
    ),
    general = "Data from 1974 Motor Trend magazine"
  )
)

cat("Blueprint created successfully!\n")
cat("Dimensions:", dim(bp)[1], "x", dim(bp)[2], "\n")

# Check if footnotes are in metadata
cat("Footnote list in metadata:\n")
print(bp$metadata$footnote_list)

# Render in console format
cat("\nRendering table...\n")
output <- display_table(bp, mtcars, theme = "nejm")
cat(output)