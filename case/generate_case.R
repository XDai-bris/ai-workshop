#!/usr/bin/env Rscript
# Simulated two-sample MR case for the 45-minute validation walkthrough (2026-11-24).
# Writes:
#   project_template/data/main/{exposure_bmi_gwas.tsv, outcome_sbp_gwas.tsv}   the data the agent analyses
#   extra_data/control_positive/...   a second dataset with a known answer (true effect 0.30), not given to the agent
#   truth/   per-SNP simulation truth (never copy into an agent workspace)
# Usage: Rscript case/generate_case.R  (from any folder)
script_dir <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f)) dirname(normalizePath(f)) else getwd()
})
source(file.path(script_dir, "R", "sim_functions.R"))

cfg <- default_config()
cfg$seed <- 20261125L  # chosen by select_case_seed.R
cfg$datasets <- list(
  control_positive = list(beta_per_unit = 0.30, pleio_frac = 0, pleio_mean = 0, pleio_sd = 0),
  main             = list(beta_per_unit = 0.25, pleio_frac = 0, pleio_mean = 0, pleio_sd = 0)
)
set.seed(cfg$seed)
write_tsv <- function(d, path) write.table(d, path, sep = "\t", quote = FALSE, row.names = FALSE)
truth_dir <- file.path(script_dir, "truth")
dir.create(truth_dir, showWarnings = FALSE, recursive = TRUE)
rsids <- draw_rsids(cfg$n_snps * length(cfg$datasets))
for (k in seq_along(cfg$datasets)) {
  name <- names(cfg$datasets)[k]
  sim <- simulate_dataset(cfg$datasets[[name]], cfg, rsids[(k - 1) * cfg$n_snps + seq_len(cfg$n_snps)])
  d <- if (name == "main") file.path(script_dir, "project_template", "data", "main") else file.path(script_dir, "extra_data", name)
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
  write_tsv(sim$exposure, file.path(d, "exposure_bmi_gwas.tsv"))
  write_tsv(sim$outcome, file.path(d, "outcome_sbp_gwas.tsv"))
  write_tsv(sim$truth, file.path(truth_dir, sprintf("truth_snps_%s.tsv", name)))
}
writeLines(capture.output(dput(cfg)), file.path(truth_dir, "generation_config.R.txt"))
cat("done\n")
