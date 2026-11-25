# Run an analysis script UNCHANGED, with a chosen working directory (so its relative outputs land there)
# and a chosen dataset folder.   Usage: Rscript run_in.R <workdir> <script> <datadir>
a <- commandArgs(trailingOnly = TRUE)
workdir <- a[1]; script <- normalizePath(a[2]); datadir <- normalizePath(a[3])
dir.create(workdir, recursive = TRUE, showWarnings = FALSE)
setwd(workdir)
# the script reads its dataset folder from commandArgs(trailingOnly = TRUE)[1]
commandArgs <- function(trailingOnly = FALSE) if (trailingOnly) datadir else c("Rscript", datadir)
source(script, echo = FALSE)
