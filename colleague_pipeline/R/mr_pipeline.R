# Two-sample Mendelian randomization pipeline: BMI (exposure) -> systolic blood pressure (outcome)
#
# Steps
#   1. read_exposure(): read BMI instruments and convert effects from SD units to kg/m^2
#   2. read_outcome():  read SBP look-up and remove variants with missing estimates
#   3. harmonise():     align outcome effects to the exposure effect allele
#   4. mr_ivw():        inverse-variance weighted causal estimate
#
# All functions use base R only.

SD_BMI <- 4.8  # kg/m^2 per SD of BMI (DATA_DICTIONARY.md)

#' Read the exposure (BMI) GWAS file and convert effects to kg/m^2 per allele.
read_exposure <- function(path) {
  x <- read.delim(path, stringsAsFactors = FALSE)
  x$BETA <- x$BETA * SD_BMI
  x$SE <- x$SE * SD_BMI
  x
}

#' Read the outcome (SBP) GWAS file. `beta` and `freq` refer to allele A2.
read_outcome <- function(path) {
  y <- read.delim(path, stringsAsFactors = FALSE)
  # Remove variants without an outcome estimate
  y[!is.na(y$beta) & !is.na(y$se), ]
}

#' Align outcome effects to the exposure effect allele.
#' Both GWAS report alleles on the GRCh38 forward strand, so comparing the outcome
#' effect allele (A2) with the exposure effect allele is sufficient: if they differ,
#' the outcome effect refers to the other allele and its sign is flipped.
harmonise <- function(exposure, outcome) {
  dat <- merge(exposure, outcome, by.x = "SNP", by.y = "rsid")
  same_allele <- dat$A2 == dat$EFFECT_ALLELE
  data.frame(
    SNP = dat$SNP,
    beta_exposure = dat$BETA,
    se_exposure = dat$SE,
    beta_outcome = ifelse(same_allele, dat$beta, -dat$beta),
    se_outcome = dat$se,
    stringsAsFactors = FALSE
  )
}

#' Inverse-variance weighted (IVW) estimate of the causal effect.
mr_ivw <- function(dat) {
  w <- 1 / dat$se_outcome^2
  estimate <- sum(w * dat$beta_exposure * dat$beta_outcome) / sum(w * dat$beta_exposure^2)
  se <- sqrt(1 / sum(w * dat$beta_exposure^2))
  data.frame(
    method = "IVW",
    estimate = estimate,
    se = se,
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    n_snps = nrow(dat)
  )
}
