# Runs the UNCHANGED analysis/mr_analysis.R with working directory = review/<sim>,
# so results/ and report.md are written under review/<sim>/ and never touch the real ones.
# usage (from project root): Rscript review/run_unchanged.R sim_noisy
sim <- commandArgs(TRUE)[1]
script <- normalizePath("analysis/mr_analysis.R")
setwd(file.path("review", sim))
cat("cwd:", getwd(), "\n")
a <- commandArgs(TRUE)
ca <- if (length(a) >= 2) a[2] else "data"
commandArgs <- function(trailingOnly = FALSE) ca   # the script's optional dataset-folder argument
source(script, echo = FALSE)
