# Simulate summary stats in the dictionary's file formats.
# TRUE causal effect: 0.8 mmHg SBP per 1 kg/m2 BMI  (exposure BETA is per SD; 1 SD = 4.8 kg/m2).
# Run from review/:  Rscript sim.R
set.seed(1)
THETA <- 0.8; SD <- 4.8
comp <- c(A = "T", T = "A", C = "G", G = "C")
nonpal <- list(c("A", "C"), c("A", "G"), c("C", "T"), c("G", "T"))
pal    <- list(c("A", "T"), c("C", "G"))

scen <- rbind(
  data.frame(kind = "aligned",          pal = FALSE, swap = FALSE, strand = FALSE, k = 60),
  data.frame(kind = "swapped",          pal = FALSE, swap = TRUE,  strand = FALSE, k = 60),
  data.frame(kind = "strand",           pal = FALSE, swap = FALSE, strand = TRUE,  k = 60),
  data.frame(kind = "strand+swapped",   pal = FALSE, swap = TRUE,  strand = TRUE,  k = 60),
  data.frame(kind = "pal same",         pal = TRUE,  swap = FALSE, strand = FALSE, k = 8),
  data.frame(kind = "pal same swapped", pal = TRUE,  swap = TRUE,  strand = FALSE, k = 8),
  data.frame(kind = "pal opp",          pal = TRUE,  swap = FALSE, strand = TRUE,  k = 8),
  data.frame(kind = "pal opp swapped",  pal = TRUE,  swap = TRUE,  strand = TRUE,  k = 8))

rows <- list(); id <- 0
for (s in seq_len(nrow(scen))) for (j in seq_len(scen$k[s])) {
  id <- id + 1
  p <- if (scen$pal[s]) pal[[sample(2, 1)]] else nonpal[[sample(4, 1)]]
  if (runif(1) < 0.5) p <- rev(p)
  ea <- p[1]; oa <- p[2]
  eaf <- if (scen$pal[s]) sample(c(runif(1, .08, .40), runif(1, .60, .92)), 1) else runif(1, .05, .95)
  bx_true <- rnorm(1, 0, .05); bx_true <- sign(bx_true) * max(abs(bx_true), .02)
  sex <- .0026
  bx_obs <- bx_true + rnorm(1, 0, sex)                 # exposure BETA, SD units, for EA
  by_ea  <- THETA * bx_true * SD + rnorm(1, 0, .03)    # outcome effect of EA, mmHg (the truth we must recover)
  of <- min(max(eaf + rnorm(1, 0, .01), .02), .98)     # outcome freq of the EA (physical allele)
  a2phys <- if (scen$swap[s]) oa else ea
  a1phys <- if (scen$swap[s]) ea else oa
  beta2  <- if (scen$swap[s]) -by_ea else by_ea        # outcome beta is for A2
  f2     <- if (scen$swap[s]) 1 - of else of
  A1 <- if (scen$strand[s]) comp[[a1phys]] else a1phys # reverse strand => complemented labels
  A2 <- if (scen$strand[s]) comp[[a2phys]] else a2phys
  rows[[id]] <- data.frame(kind = scen$kind[s], SNP = sprintf("sim%03d", id), CHR = 1 + id %% 22, POS = 1000 * id,
    EFFECT_ALLELE = ea, OTHER_ALLELE = oa, EAF = round(eaf, 4), BETA = round(bx_obs, 6), SE = sex, P = 1e-20, N = 300000,
    A1 = A1, A2 = A2, freq = round(f2, 4), beta = round(beta2, 6), se = 0.03, pval = 0.01, n = 750000,
    true_by_ea = by_ea, stringsAsFactors = FALSE)
}
d <- do.call(rbind, rows)

mk <- function(kind, SNP, EA, OA, EAF, BETA, A1, A2, freq, beta, se, pval, n) {
  data.frame(kind = kind, SNP = SNP, CHR = 9, POS = seq_along(SNP) * 7 + 9e6, EFFECT_ALLELE = EA, OTHER_ALLELE = OA,
    EAF = EAF, BETA = BETA, SE = .0026, P = 1e-20, N = 3e5, A1 = A1, A2 = A2, freq = freq, beta = beta, se = se,
    pval = pval, n = n, true_by_ea = NA, stringsAsFactors = FALSE)
}
amb  <- mk("pal ambiguous", c("amb1", "amb2", "amb3"), c("A", "C", "T"), c("T", "G", "A"), c(.47, .55, .50),
           c(.03, -.04, .05), c("T", "G", "A"), c("A", "C", "T"), c(.48, .53, .51), c(.1, -.1, .1), .03, .1, 75e4)
mis  <- mk("allele mismatch", c("mm1", "mm2"), c("A", "C"), c("G", "T"), c(.3, .4), c(.03, -.04),
           c("A", "A"), c("C", "C"), c(.3, .4), c(.1, .1), .03, .1, 75e4)  # genuinely unmatched alleles
miss <- mk("missing -9", c("na1", "na2", "na3"), c("A", "G", "C"), c("G", "T", "T"), c(.3, .4, .2), c(.03, -.04, .05),
           c("G", "T", "T"), c("A", "G", "C"), c(-9, .4, .2), c(-9, -9, .1), c(-9, -9, -9), -9, c(-9, 75e4, -9))
all <- rbind(d, amb, mis, miss)
absent <- data.frame(SNP = c("abs1", "abs2", "abs3"), CHR = 8, POS = 8e6 + 1:3, EFFECT_ALLELE = "A", OTHER_ALLELE = "G",
                     EAF = .3, BETA = c(.03, -.02, .04), SE = .0026, P = 1e-20, N = 3e5)

write.table(rbind(all[, names(absent)], absent), "sim_data/exposure_bmi_gwas.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
out <- all[, c("SNP", "CHR", "POS", "A1", "A2", "freq", "beta", "se", "pval", "n")]
names(out) <- c("rsid", "chr", "pos", "A1", "A2", "freq", "beta", "se", "pval", "n")
write.table(out, "sim_data/outcome_sbp_gwas.tsv", sep = "\t", quote = FALSE, row.names = FALSE)
write.csv(all[, c("SNP", "kind", "true_by_ea")], "sim_data/truth.csv", row.names = FALSE)
cat("exposure rows:", nrow(all) + nrow(absent), " outcome rows:", nrow(out), "\n")
