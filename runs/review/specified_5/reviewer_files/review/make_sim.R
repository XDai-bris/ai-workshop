# Simulate summary statistics in the dictionary's formats. TRUE causal effect = 2.0 mmHg per 1 kg/m2.
# Writes review/sim/{exposure_bmi_gwas.tsv,outcome_sbp_gwas.tsv,truth.csv}
set.seed(42)
THETA <- 2.0
SD_BMI <- 4.8
comp <- c(A = "T", T = "A", C = "G", G = "C")
nonpal <- list(c("A","C"), c("A","G"), c("T","C"), c("T","G"))
pal    <- list(c("A","T"), c("C","G"))

# situation = how outcome alleles relate to exposure alleles
sit <- c(rep("aligned", 100), rep("swapped", 100), rep("strand", 100), rep("strand_swapped", 100),
         rep("pal_same_A2EA", 20), rep("pal_same_A2OA", 20), rep("pal_opp_A2EA_label", 20), rep("pal_opp_A2OA_label", 20),
         rep("pal_ambiguous", 15), rep("miss_m9", 10), rep("absent", 10))
n <- length(sit)
snp <- sprintf("rs%d", sample(1e6:9e7, n))
is_pal <- grepl("^pal", sit)
ea <- oa <- character(n)
for (i in 1:n) {
  p <- if (is_pal[i]) pal[[sample(2, 1)]] else nonpal[[sample(4, 1)]]
  p <- sample(p)
  ea[i] <- p[1]; oa[i] <- p[2]
}
eaf <- ifelse(is_pal & sit != "pal_ambiguous",
              ifelse(runif(n) < .5, runif(n, .05, .33), runif(n, .67, .95)),
              runif(n, .05, .95))
eaf[sit == "pal_ambiguous"] <- runif(sum(sit == "pal_ambiguous"), .45, .55)
eaf[sit == "pal_same_A2EA" | sit == "pal_same_A2OA"] <- round(eaf[sit == "pal_same_A2EA" | sit == "pal_same_A2OA"], 4)

bx_sd <- runif(n, .03, .09) * sample(c(-1, 1), n, TRUE)   # per-SD, either sign
sx_sd <- 0.0026
bx_kg <- bx_sd / SD_BMI
sy <- 0.01
b_ea_out <- THETA * bx_kg + rnorm(n, 0, sy)              # true outcome effect of the exposure EA (no pleiotropy)
f_ea_out <- pmin(.97, pmax(.03, eaf + rnorm(n, 0, .01)))  # outcome freq of the EA

# outcome representation (forward strand)
strand_flip <- sit %in% c("strand", "strand_swapped", "pal_opp_A2EA_label", "pal_opp_A2OA_label")
swap        <- sit %in% c("swapped", "strand_swapped", "pal_same_A2OA", "pal_opp_A2OA_label")
ea_f <- ifelse(strand_flip, comp[ea], ea); oa_f <- ifelse(strand_flip, comp[oa], oa)
# A2 is the allele whose effect is reported
A2 <- ifelse(swap, oa_f, ea_f); A1 <- ifelse(swap, ea_f, oa_f)
beta <- ifelse(swap, -b_ea_out, b_ea_out)
freq <- ifelse(swap, 1 - f_ea_out, f_ea_out)

exposure <- data.frame(SNP = snp, CHR = sample(1:22, n, TRUE), POS = sample(1e6:2e8, n), EFFECT_ALLELE = ea,
  OTHER_ALLELE = oa, EAF = round(eaf, 4), BETA = round(bx_sd, 7), SE = sx_sd,
  P = signif(2 * pnorm(-abs(bx_sd / sx_sd)), 3), N = 300000)
outcome <- data.frame(rsid = snp, chr = exposure$CHR, pos = exposure$POS, A1 = A1, A2 = A2, freq = round(freq, 4),
  beta = round(beta, 7), se = sy, pval = signif(2 * pnorm(-abs(beta / sy)), 3), n = 750000, stringsAsFactors = FALSE)
m <- sit == "miss_m9"
outcome[m, c("freq", "beta", "se", "pval")] <- -9
outcome <- outcome[sit != "absent", ]
outcome <- outcome[sample(nrow(outcome)), ]               # shuffled order

dir.create("review/sim", showWarnings = FALSE)
write.table(exposure, "review/sim/exposure_bmi_gwas.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
write.table(outcome, "review/sim/outcome_sbp_gwas.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
truth <- data.frame(SNP = snp, situation = sit, true_ea_outcome_beta = b_ea_out, true_sign_needed =
                    ifelse(swap, "negate outcome beta", "keep outcome beta"))
write.csv(truth, "review/sim/truth.csv", row.names = FALSE)

# oracle: IVW on the true harmonised data (non-dropped variants)
keep <- !(sit %in% c("pal_ambiguous", "miss_m9", "absent"))
cat("oracle IVW on retained variants:", sum(bx_kg[keep] * b_ea_out[keep]) / sum(bx_kg[keep]^2), " n =", sum(keep), "\n")
print(table(sit))
