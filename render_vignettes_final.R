# Script to render all vignettes to HTML and PDF
library(rmarkdown)
library(knitr)

# Set working directory to project root
setwd("/Users/zenn/Dropbox/prj/d03/zztable1_nextgen")

# Source all R files first
source("R/validation_consolidated.R")
source("R/error_handling.R")
source("R/cells.R")
source("R/utils.R")
source("R/blueprint.R")
source("R/themes.R")
source("R/dimensions.R")
source("R/rendering.R")
source("R/table1.R")

# Get all Rmd files
rmd_files <- list.files("vignettes", pattern = "\\.Rmd$", full.names = TRUE)
cat("Found vignettes:", paste(basename(rmd_files), collapse = ", "), "\n")

# Render each vignette to HTML and PDF
for (file in rmd_files) {
  cat("\nRendering", basename(file), "...\n")
  
  # Render to HTML
  tryCatch({
    rmarkdown::render(file, output_format = "html_document", quiet = TRUE)
    cat("  ✓ HTML rendered successfully\n")
  }, error = function(e) {
    cat("  ✗ HTML error:", e$message, "\n")
  })
  
  # Render to PDF with xelatex for unicode support
  tryCatch({
    rmarkdown::render(file, output_format = rmarkdown::pdf_document(latex_engine = "xelatex"), quiet = TRUE)
    cat("  ✓ PDF rendered successfully\n")
  }, error = function(e) {
    cat("  ✗ PDF error:", e$message, "\n")
  })
}

cat("\nVignette rendering complete!\n")