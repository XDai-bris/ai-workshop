# Run the MR pipeline on one dataset folder.
# Usage (from the repository root):
#   Rscript colleague_pipeline/run_pipeline.R data/main
# Writes results/colleague_pipeline/<dataset>/estimates.csv and scatter.png

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("Usage: Rscript colleague_pipeline/run_pipeline.R <dataset folder>")
data_dir <- args[1]

pipeline_dir <- "colleague_pipeline"
source(file.path(pipeline_dir, "R", "mr_pipeline.R"))

exposure <- read_exposure(file.path(data_dir, "exposure_bmi_gwas.tsv"))
outcome <- read_outcome(file.path(data_dir, "outcome_sbp_gwas.tsv"))
dat <- harmonise(exposure, outcome)
res <- mr_ivw(dat)

out_dir <- file.path("results", "colleague_pipeline", basename(data_dir))
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
write.csv(res, file.path(out_dir, "estimates.csv"), row.names = FALSE)

png(file.path(out_dir, "scatter.png"), width = 1600, height = 1200, res = 200)
plot(dat$beta_exposure, dat$beta_outcome, pch = 19, col = "#1f77b4",
     xlab = "SNP effect on BMI (kg/m² per allele)", ylab = "SNP effect on SBP (mmHg per allele)",
     main = sprintf("BMI -> SBP (%s): IVW = %.2f mmHg per kg/m²", basename(data_dir), res$estimate))
abline(0, res$estimate, col = "#d62728", lwd = 2)
abline(h = 0, v = 0, col = "grey70", lty = 2)
invisible(dev.off())

cat(sprintf("%s: IVW %.3f mmHg per kg/m² (95%% CI %.3f to %.3f), %d SNPs\n",
            basename(data_dir), res$estimate, res$ci_lower, res$ci_upper, res$n_snps))
cat("Wrote", out_dir, "\n")
