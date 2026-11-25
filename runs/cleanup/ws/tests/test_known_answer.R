#!/usr/bin/env Rscript
# Known-answer test for analysis/mr_analysis.R.
# Simulates exposure/outcome GWAS files (same formats as data/DATA_DICTIONARY.md) with a known
# causal effect, covering every allele situation, runs the analysis script and checks the result.
# Usage (from the project root): Rscript tests/test_known_answer.R
# Work happens in scratch/known_answer/ (removed on success).

THETA <- 2.0      # true causal effect: mmHg SBP per 1 kg/m2 BMI
SD_BMI <- 4.8
set.seed(1)

root <- normalizePath(".")
script <- file.path(root, "analysis", "mr_analysis.R")
stopifnot(file.exists(script))
work <- file.path(root, "scratch", "known_answer")
unlink(work, recursive = TRUE)
dir.create(file.path(work, "data"), recursive = TRUE)

comp <- function(a) c(A = "T", T = "A", C = "G", G = "C")[a]
K <- 40   # variants per usable category

# Each usable category: exposure alleles, whether the outcome is on the opposite strand,
# whether outcome A2 is the (strand-equivalent of the) exposure effect allele, EAF range.
cats <- list(
  aligned           = list(pal = FALSE, strand = FALSE, a2_is_ea = TRUE,  eaf = c(.1, .9),
                           expect = "none: alleles aligned"),
  swapped           = list(pal = FALSE, strand = FALSE, a2_is_ea = FALSE, eaf = c(.1, .9),
                           expect = "flipped: allele order swapped"),
  complemented      = list(pal = FALSE, strand = TRUE,  a2_is_ea = TRUE,  eaf = c(.1, .9),
                           expect = "strand: complemented, no flip"),
  complemented_swap = list(pal = FALSE, strand = TRUE,  a2_is_ea = FALSE, eaf = c(.1, .9),
                           expect = "strand: complemented and allele order swapped, flipped"),
  pal_same_ea       = list(pal = TRUE,  strand = FALSE, a2_is_ea = TRUE,  eaf = c(.1, .3),
                           expect = "palindromic: same strand (inferred from EAF), no flip"),
  pal_same_oa       = list(pal = TRUE,  strand = FALSE, a2_is_ea = FALSE, eaf = c(.1, .3),
                           expect = "palindromic: same strand (inferred from EAF), flipped"),
  pal_opp_ea        = list(pal = TRUE,  strand = TRUE,  a2_is_ea = TRUE,  eaf = c(.1, .3),
                           expect = "palindromic: strand flipped (inferred from EAF), no flip"),
  pal_opp_oa        = list(pal = TRUE,  strand = TRUE,  a2_is_ea = FALSE, eaf = c(.1, .3),
                           expect = "palindromic: strand flipped (inferred from EAF), flipped"))

nonpal_pairs <- list(c("A", "C"), c("A", "G"), c("C", "T"), c("G", "T"))
pal_pairs    <- list(c("A", "T"), c("C", "G"))

exp_rows <- list(); out_rows <- list(); truth <- character()
id <- 0
new_id <- function() { id <<- id + 1; sprintf("rs%d", 1000000 + id) }

for (nm in names(cats)) {
  ct <- cats[[nm]]
  for (k in seq_len(K)) {
    snp <- new_id()
    pr <- sample(if (ct$pal) pal_pairs else nonpal_pairs, 1)[[1]]
    if (runif(1) < .5) pr <- rev(pr)
    ea <- pr[1]; oa <- pr[2]
    eaf <- runif(1, ct$eaf[1], ct$eaf[2])
    bx_sd <- sample(c(-1, 1), 1) * runif(1, 0.03, 0.08)         # per SD
    # Exposure SE is deliberately tiny (I2_GX ~ 1). MR-Egger is biased towards zero by about I2_GX
    # (regression dilution; Bowden et al. 2016), and with SE 0.003 SD and |BETA| 0.03-0.08 SD
    # I2_GX is ~0.96, giving a mean slope of ~1.92 for a true 2.0. That is a property of the
    # method, not a script bug, so the test uses SE 0.0005 SD to make the bias negligible.
    sx <- 0.0005
    bx_obs <- bx_sd + rnorm(1, 0, sx)
    sy <- 0.03
    by_ea <- THETA * bx_sd * SD_BMI + rnorm(1, 0, sy)   # true effect of EA on SBP (+noise)
    # outcome representation
    ea_f <- if (ct$strand) unname(comp(ea)) else ea
    oa_f <- if (ct$strand) unname(comp(oa)) else oa
    if (ct$a2_is_ea) { a2 <- ea_f; a1 <- oa_f; b <- by_ea;  f <- eaf }
    else             { a2 <- oa_f; a1 <- ea_f; b <- -by_ea; f <- 1 - eaf }
    exp_rows[[snp]] <- data.frame(SNP = snp, CHR = 1, POS = id * 1000, EFFECT_ALLELE = ea,
      OTHER_ALLELE = oa, EAF = round(eaf, 4), BETA = bx_obs, SE = sx, P = 1e-20, N = 300000)
    out_rows[[snp]] <- data.frame(rsid = snp, chr = 1, pos = id * 1000, A1 = a1, A2 = a2,
      freq = round(f, 4), beta = b, se = sy, pval = 0.1, n = 750000)
    truth[snp] <- ct$expect
  }
}

# Variants that must be dropped
add_drop <- function(label, n, ea, oa, eaf, a1, a2, outfreq = NULL, miss = FALSE, absent = FALSE) {
  for (k in seq_len(n)) {
    snp <- new_id()
    exp_rows[[snp]] <<- data.frame(SNP = snp, CHR = 1, POS = id * 1000, EFFECT_ALLELE = ea,
      OTHER_ALLELE = oa, EAF = eaf, BETA = 0.05, SE = 0.003, P = 1e-20, N = 300000)
    if (!absent) {
      out_rows[[snp]] <<- if (miss)
        data.frame(rsid = snp, chr = -9, pos = -9, A1 = -9, A2 = -9, freq = -9, beta = -9,
                   se = -9, pval = -9, n = -9)
      else data.frame(rsid = snp, chr = 1, pos = id * 1000, A1 = a1, A2 = a2,
                      freq = if (is.null(outfreq)) eaf else outfreq, beta = 5, se = 0.03,
                      pval = 0.1, n = 750000)
    }
    truth[snp] <<- label
  }
}
add_drop("dropped: palindromic, MAF > 0.42 (strand ambiguous)", 4, "A", "T", 0.47, "T", "A")
add_drop("dropped: allele mismatch", 4, "A", "C", 0.3, "A", "G")
add_drop("dropped: outcome data missing (-9)", 4, "A", "C", 0.3, NA, NA, miss = TRUE)
add_drop("dropped: not in outcome GWAS", 4, "A", "C", 0.3, NA, NA, absent = TRUE)
add_drop("dropped: non-ACGT or indel alleles", 2, "A", "C", 0.3, "I", "D")
# the indel rows carry A1/A2 = I/D in the outcome only; exposure alleles are valid

ex <- do.call(rbind, exp_rows); ou <- do.call(rbind, out_rows)
ex <- ex[sample(nrow(ex)), ]; ou <- ou[sample(nrow(ou)), ]
write.table(ex, file.path(work, "data", "exposure_bmi_gwas.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(ou, file.path(work, "data", "outcome_sbp_gwas.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)

# ---- run the analysis script on the simulated data (cwd = work, so outputs stay in scratch)
rscript <- file.path(R.home("bin"), "Rscript")
old <- setwd(work)
res <- system2(rscript, c(shQuote(script), "data"), stdout = TRUE, stderr = TRUE)
setwd(old)
status <- attr(res, "status"); if (is.null(status)) status <- 0
if (status != 0) { cat(res, sep = "\n"); stop("analysis script failed") }

est <- read.csv(file.path(work, "results", "estimates.csv"), stringsAsFactors = FALSE)
lg  <- read.csv(file.path(work, "results", "harmonisation_log.csv"), stringsAsFactors = FALSE)

fails <- character()
check <- function(ok, msg) { cat(if (ok) "PASS  " else "FAIL  ", msg, "\n", sep = ""); if (!ok) fails <<- c(fails, msg) }

# 1. harmonisation labels per variant
lg$expected <- truth[lg$SNP]
check(nrow(lg) == length(truth), "one log row per simulated variant")
bad <- lg[lg$harmonisation_action != lg$expected, ]
check(nrow(bad) == 0, sprintf("harmonisation action matches expectation for all variants (%d mismatches)", nrow(bad)))
if (nrow(bad)) print(head(bad[, c("SNP", "harmonisation_action", "expected")]))
check(all(lg$used == !grepl("^dropped", lg$expected)), "used flag matches expectation")

# 2. recovery of the causal effect
n_used <- sum(!grepl("^dropped", truth))
check(all(est$n_snps == n_used), sprintf("n_snps = %d usable variants", n_used))
for (m in c("IVW (multiplicative random effects)", "MR-Egger", "Weighted median")) {
  r <- est[est$method == m, ]
  ok <- THETA >= r$ci_lower && THETA <= r$ci_upper && abs(r$estimate - THETA) < 0.5
  check(ok, sprintf("%s recovers %.1f: %.3f (95%% CI %.3f to %.3f)", m, THETA, r$estimate, r$ci_lower, r$ci_upper))
}
ei <- est[est$method == "MR-Egger intercept", ]
check(ei$ci_lower <= 0 && ei$ci_upper >= 0, "MR-Egger intercept CI includes 0 (no pleiotropy simulated)")

# 3. Hand-worked example (expected values worked out on paper, not from the script's formulas).
# Four aligned variants, exposure BETA per SD = 0.1, 0.2, -0.1, 0.05 (SE 0.01); outcome effect of the
# exposure allele in mmHg = 0.24, 0.48, -0.24, 0.12 (SE 0.1).
# 1 SD = 4.8 kg/m2, so exposure effects are 0.48, 0.96, -0.48, 0.24 kg/m2 and every Wald ratio is
# 0.24/0.48 = 0.5 mmHg per kg/m2. IVW = 0.5 exactly; its SE = 1/sqrt(sum(w*bx^2)) with w = 100 and
# sum(bx^2) = 0.2304+0.9216+0.2304+0.0576 = 1.44, so SE = 1/sqrt(144) = 1/12 = 0.083333.
hw <- file.path(work, "hand"); dir.create(file.path(hw, "data"), recursive = TRUE)
write.table(data.frame(SNP = paste0("h", 1:4), CHR = 1, POS = 1:4 * 1000, EFFECT_ALLELE = "A",
    OTHER_ALLELE = "C", EAF = 0.3, BETA = c(0.1, 0.2, -0.1, 0.05), SE = 0.01, P = 1e-20, N = 300000),
  file.path(hw, "data", "exposure_bmi_gwas.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(data.frame(rsid = paste0("h", 1:4), chr = 1, pos = 1:4 * 1000, A1 = "C", A2 = "A",
    freq = 0.3, beta = c(0.24, 0.48, -0.24, 0.12), se = 0.1, pval = 0.1, n = 750000),
  file.path(hw, "data", "outcome_sbp_gwas.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
old <- setwd(hw)
res2 <- system2(rscript, c(shQuote(script), "data"), stdout = TRUE, stderr = TRUE)
setwd(old)
if (!is.null(attr(res2, "status"))) { cat(res2, sep = "\n"); stop("analysis script failed on hand example") }
he <- read.csv(file.path(hw, "results", "estimates.csv"), stringsAsFactors = FALSE)
hi <- he[he$method == "IVW (multiplicative random effects)", ]
check(abs(hi$estimate - 0.5) < 1e-9, sprintf("hand example: IVW estimate = 0.5 (got %.6f)", hi$estimate))
check(abs(hi$se - 1/12) < 1e-9, sprintf("hand example: IVW SE = 1/12 = 0.083333 (got %.6f)", hi$se))

if (length(fails)) stop(length(fails), " check(s) failed")
unlink(work, recursive = TRUE)
cat("All checks passed.\n")
