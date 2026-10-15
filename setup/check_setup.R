# Workshop setup check. Run from the repository root folder:
#   conda run -n ieu-ai-workshop Rscript setup/check_setup.R
# Prints "SETUP OK" when R, plotting and the data all work.

ok <- TRUE
problem <- function(msg) {
  cat("PROBLEM:", msg, "\n")
  ok <<- FALSE
}

cat("R version:", R.version.string, "\n")
if (getRversion() < "4.5.0") {
  problem("R 4.5 or later is needed. Are you running R from the ieu-ai-workshop environment (conda run -n ieu-ai-workshop ...)?")
}

if (!file.exists(file.path("data", "DATA_DICTIONARY.md"))) {
  problem("data/DATA_DICTIONARY.md not found. Run this command from the repository root folder.")
} else {
  x <- tryCatch(read.delim(file.path("data", "main", "exposure_bmi_gwas.tsv")), error = function(e) NULL)
  if (is.null(x) || nrow(x) != 100) problem("could not read data/main/exposure_bmi_gwas.tsv")
}

if (length(.libPaths()) > 1) {
  cat("NOTE: R can see other package libraries:", paste(.libPaths()[-length(.libPaths())], collapse = "; "), "\n")
  cat("      Recreate the environment from environment.yml, or tell an organiser.\n")
}

png_path <- file.path(tempdir(), "setup_check.png")
plotted <- tryCatch({
  png(png_path, width = 400, height = 300)
  plot(1:10, (1:10)^2, pch = 19)
  dev.off()
  file.exists(png_path) && file.size(png_path) > 0
}, error = function(e) {
  cat(conditionMessage(e), "\n")
  FALSE
})
if (!isTRUE(plotted)) problem("could not write a PNG plot")
unlink(png_path)

if (ok) {
  cat("\nSETUP OK\n")
} else {
  cat("\nSETUP FAILED: see the problems above, or ask an organiser.\n")
  quit(status = 1)
}
