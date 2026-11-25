#!/usr/bin/env Rscript
# Two-sample MR: effect of BMI on systolic blood pressure (mmHg per 1 kg/m2).
# Implements analysis_plan.md using base R only.
# Usage (from the project root): Rscript analysis/mr_analysis.R [dataset_folder]
# Default dataset folder: data/main. Outputs go to results/ and report.md in the working directory.

args <- commandArgs(trailingOnly = TRUE)
data_dir <- if (length(args) >= 1) args[1] else "data/main"

SD_BMI_KGM2  <- 4.8    # 1 SD of BMI in kg/m2 (data dictionary)
MAF_MAX_PAL  <- 0.42   # palindromic variants with MAF above this are dropped
MISSING_CODE <- -9     # outcome missing-value code
set.seed(20240601)     # for the weighted-median bootstrap

dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------------- 1. Read and clean
exp_file <- file.path(data_dir, "exposure_bmi_gwas.tsv")
out_file <- file.path(data_dir, "outcome_sbp_gwas.tsv")
stopifnot(file.exists(exp_file), file.exists(out_file))

exposure <- read.delim(exp_file, stringsAsFactors = FALSE, na.strings = c("NA", ""))
outcome  <- read.delim(out_file, stringsAsFactors = FALSE, na.strings = c("NA", ""))

# -9 is the outcome's missing code (numeric columns; also guard allele columns)
for (v in c("chr", "pos", "freq", "beta", "se", "pval", "n")) {
  if (v %in% names(outcome)) {
    outcome[[v]] <- suppressWarnings(as.numeric(outcome[[v]]))
    outcome[[v]][!is.na(outcome[[v]]) & outcome[[v]] == MISSING_CODE] <- NA
  }
}
for (v in c("A1", "A2")) outcome[[v]][outcome[[v]] %in% as.character(MISSING_CODE)] <- NA
outcome$A1 <- toupper(outcome$A1); outcome$A2 <- toupper(outcome$A2)
exposure$EFFECT_ALLELE <- toupper(exposure$EFFECT_ALLELE)
exposure$OTHER_ALLELE  <- toupper(exposure$OTHER_ALLELE)

if (anyDuplicated(exposure$SNP)) stop("Duplicate SNP ids in exposure file")
if (anyDuplicated(outcome$rsid)) stop("Duplicate rsid in outcome file")

dat <- merge(exposure, outcome, by.x = "SNP", by.y = "rsid", all.x = TRUE, sort = FALSE)
dat <- dat[match(exposure$SNP, dat$SNP), ]   # keep exposure order

in_outcome  <- dat$SNP %in% outcome$rsid
usable_out  <- in_outcome & !is.na(dat$beta) & !is.na(dat$se) & dat$se > 0 &
               !is.na(dat$A1) & !is.na(dat$A2)

# ---------------------------------------------------------------- 2. Harmonise
# Target: outcome effect expressed for the exposure effect allele (EA).
comp <- function(a) c(A = "T", T = "A", C = "G", G = "C")[a]
is_pal <- function(a, b) paste0(sort(c(a, b)), collapse = "") %in% c("AT", "CG")

dat$action <- NA_character_
dat$flip   <- NA     # TRUE: outcome beta must be negated and freq -> 1 - freq
dat$out_freq_ea <- NA_real_   # outcome frequency of the exposure EA after harmonisation

for (i in seq_len(nrow(dat))) {
  if (!in_outcome[i]) { dat$action[i] <- "dropped: not in outcome GWAS"; next }
  if (!usable_out[i]) { dat$action[i] <- "dropped: outcome data missing (-9)"; next }

  ea <- dat$EFFECT_ALLELE[i]; oa <- dat$OTHER_ALLELE[i]
  a1 <- dat$A1[i];            a2 <- dat$A2[i]
  if (!all(c(ea, oa, a1, a2) %in% c("A", "C", "G", "T"))) {
    dat$action[i] <- "dropped: non-ACGT or indel alleles"; next
  }
  # outcome effect is for A2; frequency of EA in outcome if strands agree
  if (is_pal(ea, oa)) {
    if (!(a1 == ea && a2 == oa) && !(a1 == oa && a2 == ea)) {
      dat$action[i] <- "dropped: allele mismatch"; next
    }
    eaf <- dat$EAF[i]
    f_naive <- if (a2 == ea) dat$freq[i] else 1 - dat$freq[i]   # assumes same strand
    if (is.na(eaf) || is.na(f_naive) ||
        min(eaf, 1 - eaf) > MAF_MAX_PAL ||
        min(dat$freq[i], 1 - dat$freq[i]) > MAF_MAX_PAL) {
      dat$action[i] <- "dropped: palindromic, MAF > 0.42 (strand ambiguous)"; next
    }
    same_strand <- (eaf < 0.5) == (f_naive < 0.5)
    if (same_strand) {
      dat$flip[i] <- (a2 != ea)
      dat$out_freq_ea[i] <- f_naive
      dat$action[i] <- if (dat$flip[i]) "palindromic: same strand (inferred from EAF), flipped"
                       else "palindromic: same strand (inferred from EAF), no flip"
    } else {
      # opposite strand: outcome A2 is the complement of the allele it appears to be
      dat$flip[i] <- (a2 == ea)
      dat$out_freq_ea[i] <- 1 - f_naive
      dat$action[i] <- if (dat$flip[i]) "palindromic: strand flipped (inferred from EAF), flipped"
                       else "palindromic: strand flipped (inferred from EAF), no flip"
    }
    next
  }
  # non-palindromic
  if (a2 == ea && a1 == oa) {
    dat$flip[i] <- FALSE; dat$action[i] <- "none: alleles aligned"
  } else if (a2 == oa && a1 == ea) {
    dat$flip[i] <- TRUE;  dat$action[i] <- "flipped: allele order swapped"
  } else if (a2 == comp(ea) && a1 == comp(oa)) {
    dat$flip[i] <- FALSE; dat$action[i] <- "strand: complemented, no flip"
  } else if (a2 == comp(oa) && a1 == comp(ea)) {
    dat$flip[i] <- TRUE;  dat$action[i] <- "strand: complemented, flipped"
  } else {
    dat$action[i] <- "dropped: allele mismatch"; next
  }
  dat$out_freq_ea[i] <- if (dat$flip[i]) 1 - dat$freq[i] else dat$freq[i]
}

dat$used <- !is.na(dat$flip)
dat$beta_out_h <- ifelse(dat$used, ifelse(dat$flip, -dat$beta, dat$beta), NA)

harm_log <- data.frame(
  SNP = dat$SNP, exposure_EA = dat$EFFECT_ALLELE, exposure_OA = dat$OTHER_ALLELE,
  exposure_EAF = dat$EAF, outcome_A1 = dat$A1, outcome_A2 = dat$A2,
  outcome_freq_A2 = dat$freq, harmonisation_action = dat$action, used = dat$used,
  stringsAsFactors = FALSE)
write.csv(harm_log, "results/harmonisation_log.csv", row.names = FALSE)

# ---------------------------------------------------------------- 3. Units
# Exposure effects per kg/m2 (data are per SD); outcome already in mmHg.
mr <- dat[dat$used, ]
bx  <- mr$BETA * SD_BMI_KGM2
sex <- mr$SE   * SD_BMI_KGM2
by  <- mr$beta_out_h
sey <- mr$se
n   <- length(bx)
if (n < 4) stop("Too few usable instruments (", n, ") for MR-Egger")
cat(sprintf("%d of %d variants used\n", n, nrow(dat)))

# ---------------------------------------------------------------- 4. Estimate
z975 <- qnorm(0.975)

# IVW, multiplicative random effects (residual SE scaled, not allowed below 1)
w <- 1 / sey^2
ivw_fit <- lm(by ~ 0 + bx, weights = w)
ivw_b   <- unname(coef(ivw_fit))
sigma_i <- summary(ivw_fit)$sigma
ivw_se  <- sqrt(1 / sum(w * bx^2)) * max(1, sigma_i)
Q       <- sum(w * (by - ivw_b * bx)^2)
Q_df    <- n - 1
Q_p     <- pchisq(Q, Q_df, lower.tail = FALSE)
I2      <- max(0, (Q - Q_df) / Q)

# MR-Egger: orient so every SNP-exposure effect is positive
sgn <- sign(bx); sgn[sgn == 0] <- 1
bx_o <- bx * sgn; by_o <- by * sgn
eg_fit  <- lm(by_o ~ bx_o, weights = w)
eg_sum  <- summary(eg_fit)
eg_sig  <- max(1, eg_sum$sigma)
eg_coef <- eg_sum$coefficients
eg_df   <- n - 2
eg_int  <- eg_coef[1, 1]; eg_int_se <- eg_coef[1, 2] / eg_sum$sigma * eg_sig
eg_b    <- eg_coef[2, 1]; eg_b_se   <- eg_coef[2, 2] / eg_sum$sigma * eg_sig
tcrit   <- qt(0.975, eg_df)

# Weighted median (Bowden 2016), first-order weights, parametric bootstrap SE
wmedian <- function(b, wt) {
  o <- order(b); b <- b[o]; wt <- wt[o] / sum(wt)
  p <- cumsum(wt) - 0.5 * wt
  below <- max(which(p < 0.5))
  b[below] + (b[below + 1] - b[below]) * (0.5 - p[below]) / (p[below + 1] - p[below])
}
ratio    <- by / bx
se_ratio <- sey / abs(bx)
wm_b <- wmedian(ratio, 1 / se_ratio^2)
boot <- replicate(1000, {
  bxs <- rnorm(n, bx, sex); bys <- rnorm(n, by, sey)
  wmedian(bys / bxs, 1 / (sey / abs(bxs))^2)
})
wm_se <- sd(boot)

estimates <- data.frame(
  method   = c("IVW (multiplicative random effects)", "MR-Egger", "MR-Egger intercept", "Weighted median"),
  estimate = c(ivw_b, eg_b, eg_int, wm_b),
  se       = c(ivw_se, eg_b_se, eg_int_se, wm_se),
  stringsAsFactors = FALSE)
crit <- c(z975, tcrit, tcrit, z975)
estimates$ci_lower <- estimates$estimate - crit * estimates$se
estimates$ci_upper <- estimates$estimate + crit * estimates$se
estimates$n_snps   <- n
estimates <- estimates[, c("method", "estimate", "se", "ci_lower", "ci_upper", "n_snps")]
write.csv(estimates, "results/estimates.csv", row.names = FALSE)

cat(sprintf("IVW Cochran's Q = %.2f (df %d, p = %.3g), I2 = %.2f\n", Q, Q_df, Q_p, I2))
print(estimates, digits = 4)

# ---------------------------------------------------------------- 5. Scatter plot
png("results/figures/scatter.png", width = 1600, height = 1200, res = 200)
xlim <- range(c(0, bx_o - z975 * sex, bx_o + z975 * sex))
ylim <- range(c(by_o - z975 * sey, by_o + z975 * sey, 0))
plot(bx_o, by_o, pch = 16, col = "grey30", xlim = xlim, ylim = ylim,
     xlab = "SNP effect on BMI (kg/m2 per allele)",
     ylab = "SNP effect on SBP (mmHg per allele)",
     main = "BMI -> SBP: SNP-outcome vs SNP-exposure effects")
segments(bx_o, by_o - z975 * sey, bx_o, by_o + z975 * sey, col = "grey70")
segments(bx_o - z975 * sex, by_o, bx_o + z975 * sex, by_o, col = "grey70")
abline(h = 0, v = 0, lty = 3, col = "grey80")
abline(0, ivw_b, col = "firebrick", lwd = 2)
abline(eg_int, eg_b, col = "steelblue", lwd = 2)
abline(0, wm_b, col = "darkgreen", lwd = 2)
legend("topleft", bty = "n", lwd = 2,
       col = c("firebrick", "steelblue", "darkgreen"),
       legend = c("IVW", "MR-Egger", "Weighted median"))
mtext("Effects oriented so SNP-exposure effects are positive; bars are 95% CIs", side = 1, line = 4, cex = 0.7)
dev.off()

# ---------------------------------------------------------------- report.md (<= 200 words)
n_drop <- nrow(dat) - n
fmt <- function(i) sprintf("%.2f (95%% CI %.2f to %.2f)", estimates$estimate[i], estimates$ci_lower[i], estimates$ci_upper[i])
report <- c(
  "# BMI and systolic blood pressure: Mendelian randomization (simulated data)",
  "",
  sprintf("**Question.** Causal effect of BMI on SBP, in mmHg per 1 kg/m2 higher BMI.", ""),
  "",
  sprintf("**Data.** %d BMI instruments; %d used after harmonisation (%d dropped for missing outcome data, allele mismatch or ambiguous palindromic strand; see `results/harmonisation_log.csv`).", nrow(dat), n, n_drop),
  "",
  sprintf("**Results.** IVW (random effects): %s mmHg per kg/m2. Weighted median: %s. MR-Egger: %s.", fmt(1), fmt(4), fmt(2)),
  "",
  sprintf("**Heterogeneity and pleiotropy.** Cochran's Q = %.1f on %d df (p = %.2g). MR-Egger intercept = %.3f mmHg (95%% CI %.3f to %.3f).", Q, Q_df, Q_p, eg_int, estimates$ci_lower[3], estimates$ci_upper[3]),
  "",
  "**Caveats.** Results rest on the usual MR assumptions, which these checks cannot prove. Data are simulated; do not interpret as real findings."
)
words <- length(strsplit(paste(report, collapse = " "), "\\s+")[[1]])
if (words > 200) warning("report.md has ", words, " words (limit 200)")
writeLines(report, "report.md")
cat("Done. Report words:", words, "\n")
