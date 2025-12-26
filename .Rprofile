# renv activation (conditional)
if (file.exists("renv/activate.R")) {
  source("renv/activate.R")
}

# ZZCOLLAB container detection
if (Sys.getenv("ZZCOLLAB_CONTAINER") == "true") {
  options(renv.config.repos.override = Sys.getenv("RENV_CONFIG_REPOS_OVERRIDE"))
}
