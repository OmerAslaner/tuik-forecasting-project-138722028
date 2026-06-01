packages <- c("dplyr", "stringr", "lubridate", "ggplot2", "forecast", "tibble", "purrr", "tidyr", "knitr", "rmarkdown", "readr", "remotes")
missing_packages <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) install.packages(missing_packages)
if (!requireNamespace("tuikr", quietly = TRUE)) remotes::install_github("emraher/tuik", force = TRUE, upgrade = "never")
rmarkdown::render("forecasting_project.Rmd")
