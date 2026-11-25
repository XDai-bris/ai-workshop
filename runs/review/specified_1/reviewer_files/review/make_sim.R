# Simulate summary stats in the dictionary's formats. True causal effect THETA mmHg per kg/m2.
set.seed(1); THETA <- 2
comp <- c(A = "T", T = "A", C = "G", G = "C")
cats <- c(rep("aligned", 40), rep("swap", 40), rep("comp", 40), rep("comp_swap", 40),
          rep("pal_same_aligned", 20), rep("pal_same_swap", 20), rep("pal_opp_aligned", 20), rep("pal_opp_swap", 20),
          rep("pal_ambig", 6), rep("not_in_outcome", 6), rep("missing9", 6), rep("missing_NA_beta", 3))
n <- length(cats); pal <- grepl("^pal", cats)
nonpal <- list(c("A", "G"), c("A", "C"), c("T", "G"), c("T", "C"))
X <- character(n); Y <- character(n)
for (i in 1:n) {
  pp <- if (pal[i]) { if (runif(1) < .5) c("A", "T") else c("C", "G") } else nonpal[[sample(4, 1)]]
  pp <- sample(pp); X[i] <- pp[1]; Y[i] <- pp[2]
}
# allele frequency of X (forward strand truth)
p <- runif(n, .1, .9)
for (i in which(pal & cats != "pal_ambig")) p[i] <- if (runif(1) < .5) runif(1, .08, .4) else runif(1, .6, .92)
p[cats == "pal_ambig"] <- runif(sum(cats == "pal_ambig"), .45, .55)
bxX <- runif(n, .03, .09) * sample(c(-1, 1), n, TRUE)   # effect of X on BMI, SD units
byX <- THETA * bxX / 4.8 + rnorm(n, 0, .004)            # effect of X on SBP, mmHg
sex <- rep(.0026, n); sey <- rep(.004, n)
exp_swap <- cats %in% c("swap", "comp_swap", "pal_same_swap", "pal_opp_swap")       # exposure EA is Y not X
opp      <- cats %in% c("comp", "comp_swap", "pal_opp_aligned", "pal_opp_swap")    # exposure on opposite strand
EA <- OA <- A1 <- A2 <- character(n); EAF <- bx <- numeric(n)
for (i in 1:n) {
  A2[i] <- X[i]; A1[i] <- Y[i]                           # outcome: forward strand, beta/freq for A2 = X
  if (exp_swap[i]) { ea <- Y[i]; oa <- X[i]; bx[i] <- -bxX[i]; EAF[i] <- 1 - p[i] }
  else             { ea <- X[i]; oa <- Y[i]; bx[i] <-  bxX[i]; EAF[i] <- p[i] }
  if (opp[i]) { ea <- comp[[ea]]; oa <- comp[[oa]] }
  EA[i] <- ea; OA[i] <- oa
}
snp <- sprintf("rsSIM%03d", 1:n)
exposure <- data.frame(SNP = snp, CHR = 1, POS = 1000 * (1:n), EFFECT_ALLELE = EA, OTHER_ALLELE = OA,
                       EAF = round(EAF, 4), BETA = bx, SE = sex, P = 1e-20, N = 3e5)
outcome <- data.frame(rsid = snp, chr = 1, pos = 1000 * (1:n), A1 = A1, A2 = A2, freq = round(p, 4),
                      beta = byX, se = sey, pval = .01, n = 75e4)
outcome <- outcome[cats != "not_in_outcome", ]
outcome[outcome$rsid %in% snp[cats == "missing9"], c("freq", "beta", "se", "pval")] <- -9
outcome[outcome$rsid %in% snp[cats == "missing_NA_beta"], "beta"] <- NA
write.table(exposure, "review/sim/data/exposure_bmi_gwas.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(outcome, "review/sim/data/outcome_sbp_gwas.tsv", sep = "\t", quote = FALSE, row.names = FALSE, na = "NA")
# truth: outcome effect on exposure EA = THETA*bx/4.8 -> sign(bx) ; script must give beta_out_h with this sign
truth <- data.frame(SNP = snp, cat = cats, EA, OA, A1, A2, EAF = round(EAF, 4), freq_A2 = round(p, 4),
                    bx_SD = bx, true_out_for_EA = THETA * bx / 4.8, expected_sign = sign(bx))
write.csv(truth, "review/sim/truth.csv", row.names = FALSE)
