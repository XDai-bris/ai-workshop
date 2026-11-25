# Runs review/mr_analysis_fixed.R (line 100 patched) in review/<workdir>; outputs stay under review/.
# usage: Rscript review/run_fixed.R <workdir under review/> <data dir relative to that workdir>
a <- commandArgs(TRUE)
script <- normalizePath("review/mr_analysis_fixed.R")
wd <- file.path("review", a[1]); dir.create(wd, showWarnings = FALSE, recursive = TRUE)
setwd(wd)
cat("cwd:", getwd(), "\n")
ca <- a[2]
commandArgs <- function(trailingOnly = FALSE) ca
source(script, echo = FALSE)
