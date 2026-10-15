# Unit tests for the MR pipeline.
# Usage (from the repository root): Rscript colleague_pipeline/tests/run_tests.R

source(file.path("colleague_pipeline", "R", "mr_pipeline.R"))

set.seed(42)
passed <- 0
n_tests <- 0
check <- function(name, condition) {
  n_tests <<- n_tests + 1
  if (isTRUE(condition)) {
    passed <<- passed + 1
    cat("  PASS:", name, "\n")
  } else {
    cat("  FAIL:", name, "\n")
  }
}

# Simulate exposure/outcome files in the consortium formats with a known causal effect
# (beta_true, in mmHg per kg/m^2). swap = TRUE reports the other allele as A2 for half the variants.
simulate_files <- function(beta_true, n = 60, swap = TRUE, missing = 0) {
  alleles <- matrix(c("A", "C", "A", "G", "C", "T", "G", "T"), ncol = 2, byrow = TRUE)
  pick <- alleles[sample.int(4, n, replace = TRUE), , drop = FALSE]
  eaf <- runif(n, 0.1, 0.9)
  bx_sd <- runif(n, 0.02, 0.06)                     # SD units per allele
  se_x_sd <- rep(0.003, n)
  by <- beta_true * bx_sd * SD_BMI + rnorm(n, 0, 0.02)
  se_y <- rep(0.02, n)
  ids <- sprintf("rs%d", seq_len(n) + 1000)
  exposure <- data.frame(SNP = ids, CHR = 1, POS = seq_len(n), EFFECT_ALLELE = pick[, 1], OTHER_ALLELE = pick[, 2],
                         EAF = eaf, BETA = bx_sd, SE = se_x_sd, P = 1e-10, N = 300000)
  flip <- if (swap) seq_len(n) %% 2 == 0 else rep(FALSE, n)
  outcome <- data.frame(rsid = ids, chr = 1, pos = seq_len(n),
                        A1 = ifelse(flip, pick[, 1], pick[, 2]), A2 = ifelse(flip, pick[, 2], pick[, 1]),
                        freq = ifelse(flip, 1 - eaf, eaf), beta = ifelse(flip, -by, by), se = se_y,
                        pval = 0.01, n = 750000)
  if (missing > 0) outcome$beta[seq_len(missing)] <- NA
  dir <- tempfile("mr_test_")
  dir.create(dir)
  write.table(exposure, file.path(dir, "exposure.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
  write.table(outcome, file.path(dir, "outcome.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
  dir
}

run <- function(dir) {
  mr_ivw(harmonise(read_exposure(file.path(dir, "exposure.tsv")), read_outcome(file.path(dir, "outcome.tsv"))))
}

cat("Running MR pipeline tests\n")

d <- simulate_files(beta_true = 0.5, swap = FALSE)
r <- run(d)
check("recovers a positive causal effect (within 10%)", abs(r$estimate - 0.5) / 0.5 < 0.10)

d <- simulate_files(beta_true = 0, swap = FALSE)
r <- run(d)
check("recovers a null causal effect (|estimate| < 2 SE)", abs(r$estimate) < 2 * r$se)

d <- simulate_files(beta_true = 0.5, swap = TRUE)
r <- run(d)
check("handles outcome effects reported for the other allele", abs(r$estimate - 0.5) / 0.5 < 0.10)

x_sd <- read.delim(file.path(d, "exposure.tsv"))
x_kg <- read_exposure(file.path(d, "exposure.tsv"))
check("converts exposure effects from SD units to kg/m^2", isTRUE(all.equal(x_kg$BETA, x_sd$BETA * 4.8)))

d <- simulate_files(beta_true = 0.5, swap = TRUE, missing = 3)
r <- run(d)
check("drops variants with missing outcome estimates", r$n_snps == 57)

dat <- harmonise(read_exposure(file.path(d, "exposure.tsv")), read_outcome(file.path(d, "outcome.tsv")))
fit <- lm(beta_outcome ~ 0 + beta_exposure, data = dat, weights = 1 / se_outcome^2)
check("IVW estimate equals weighted regression through the origin",
      isTRUE(all.equal(unname(coef(fit)), mr_ivw(dat)$estimate)))

cat(sprintf("\n%d/%d tests passed\n", passed, n_tests))
if (passed < n_tests) quit(status = 1)
