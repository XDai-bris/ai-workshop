# Simulate summary statistics in the same formats as data/main, with a KNOWN causal effect.
# Usage: Rscript simulate.R <outdir>     (writes <outdir>/exposure_bmi_gwas.tsv, outcome_sbp_gwas.tsv, truth.csv)
args <- commandArgs(trailingOnly = TRUE)
outdir <- args[1]
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
set.seed(4242)

TRUE_EFFECT <- 2.0     # mmHg SBP per 1 kg/m2 BMI  (chosen by the reviewer)
SD_BMI <- 4.8
SE_Y <- 0.004          # small outcome SE so that per-variant signs are unambiguous (z ~ 5)
comp <- c(A = "T", T = "A", C = "G", G = "C")

# ---- allele-situation grid: (EA is outcome A2?) x (exposure on opposite strand?) x (palindromic?)
specs <- list()
add <- function(cat, n, pal, ea_is_a2, opp, f_range = "maf<=.42", extra = "none")
  specs[[length(specs) + 1]] <<- list(cat = cat, n = n, pal = pal, ea_is_a2 = ea_is_a2, opp = opp, f_range = f_range, extra = extra)
add("nonpal_aligned",            30, FALSE, TRUE,  FALSE)
add("nonpal_swapped",            30, FALSE, FALSE, FALSE)
add("nonpal_comp",               30, FALSE, TRUE,  TRUE)    # EA = comp(A2)
add("nonpal_comp_swapped",       30, FALSE, FALSE, TRUE)    # EA = comp(A1)  (EA label == comp of A1)
add("pal_same_EA_is_A2",         12, TRUE,  TRUE,  FALSE)
add("pal_same_EA_is_A1",         12, TRUE,  FALSE, FALSE)
add("pal_opp_EA_fwd_is_A2",      12, TRUE,  TRUE,  TRUE)
add("pal_opp_EA_fwd_is_A1",      12, TRUE,  FALSE, TRUE)
add("pal_ambiguous_maf_gt_042",   8, TRUE,  TRUE,  FALSE, f_range = "ambig")
add("outcome_beta_missing_-9",    3, FALSE, TRUE,  FALSE, "maf<=.42", "beta_missing")
add("outcome_freq_missing_nonpal",3, FALSE, FALSE, TRUE,  "maf<=.42", "freq_missing")
add("outcome_freq_missing_pal",   2, TRUE,  TRUE,  FALSE, "maf<=.42", "freq_missing")
add("outcome_allele_missing_-9",  2, FALSE, TRUE,  FALSE, "maf<=.42", "allele_missing")
add("allele_mismatch",            3, FALSE, TRUE,  FALSE, "maf<=.42", "mismatch")
add("not_in_outcome",             5, FALSE, TRUE,  FALSE, "maf<=.42", "absent")

nonpal_pairs <- list(c("A","C"), c("A","G"), c("C","T"), c("G","T"))
exp_rows <- list(); out_rows <- list(); truth <- list(); k <- 0
for (s in specs) for (j in seq_len(s$n)) {
  k <- k + 1; id <- sprintf("rsSIM%04d", k)
  if (s$pal) { pr <- if (runif(1) < .5) c("A","T") else c("C","G") } else pr <- nonpal_pairs[[sample(4, 1)]]
  pr <- sample(pr)                       # forward-strand alleles R, V
  R <- pr[1]; V <- pr[2]
  f <- if (s$f_range == "ambig") runif(1, .44, .56) else
       if (runif(1) < .5) runif(1, .06, .38) else runif(1, .62, .94)         # freq of V (forward)
  g <- sample(c(-1, 1), 1) * runif(1, .025, .07)                              # true effect of V on BMI (SD)
  # outcome (forward strand)
  A2 <- sample(c(R, V), 1); A1 <- setdiff(c(R, V), A2)
  # exposure effect allele (forward identity)
  ea_fwd <- if (s$ea_is_a2) A2 else A1
  oa_fwd <- setdiff(c(R, V), ea_fwd)
  if (s$f_range == "ambig") { s$opp <- runif(1) < .5; ea_fwd <- if (runif(1) < .5) A2 else A1; oa_fwd <- setdiff(c(R, V), ea_fwd) }
  ea_lab <- if (s$opp) unname(comp[ea_fwd]) else ea_fwd
  oa_lab <- if (s$opp) unname(comp[oa_fwd]) else oa_fwd
  bx_sd_true <- if (ea_fwd == V) g else -g
  eaf <- if (ea_fwd == V) f else 1 - f
  bx_sd <- bx_sd_true + rnorm(1, 0, .0026)
  sx <- runif(1, .0024, .0032)
  zx <- abs(bx_sd / sx)
  exp_rows[[k]] <- data.frame(SNP = id, CHR = sample(22, 1), POS = sample(1e8, 1), EFFECT_ALLELE = ea_lab,
    OTHER_ALLELE = oa_lab, EAF = round(eaf, 4), BETA = round(bx_sd, 7), SE = round(sx, 7),
    P = signif(2 * pnorm(-zx), 3), N = 300000, stringsAsFactors = FALSE)
  # outcome effect of V (mmHg) = TRUE_EFFECT * g / 4.8 ; effect for A2:
  by_V <- TRUE_EFFECT * g / SD_BMI + rnorm(1, 0, SE_Y)
  by_A2 <- if (A2 == V) by_V else -by_V
  fr_A2 <- min(max((if (A2 == V) f else 1 - f) + rnorm(1, 0, .01), .01), .99)
  row <- data.frame(rsid = id, chr = exp_rows[[k]]$CHR, pos = exp_rows[[k]]$POS, A1 = A1, A2 = A2,
    freq = round(fr_A2, 4), beta = round(by_A2, 7), se = round(SE_Y, 7),
    pval = signif(2 * pnorm(-abs(by_A2 / SE_Y)), 3), n = 750000, stringsAsFactors = FALSE)
  if (s$extra == "beta_missing")   row[c("beta", "se", "pval")] <- -9
  if (s$extra == "freq_missing")   row$freq <- -9
  if (s$extra == "allele_missing") { row$A1 <- "-9"; row$A2 <- "-9" }
  if (s$extra == "mismatch")       { row$A1 <- "A"; row$A2 <- "C"; exp_rows[[k]]$EFFECT_ALLELE <- "A"; exp_rows[[k]]$OTHER_ALLELE <- "G" }
  if (s$extra != "absent") out_rows[[length(out_rows) + 1]] <- row
  exp_used <- s$extra %in% c("none", "freq_missing") && !(s$pal && s$extra == "freq_missing") && s$extra != "ambig" ||
              (s$extra == "none" && !s$pal) || (s$extra == "none" && s$pal && s$f_range != "ambig")
  if (s$extra == "freq_missing" && !s$pal) exp_used <- TRUE
  if (s$extra == "freq_missing" && s$pal)  exp_used <- FALSE
  if (s$f_range == "ambig") exp_used <- FALSE
  truth[[k]] <- data.frame(SNP = id, category = s$cat, expected_used = exp_used,
    expected_flip = (ea_fwd != A2),   # outcome beta (for A2) must be negated to refer to the exposure EA
    stringsAsFactors = FALSE)
}
exposure <- do.call(rbind, exp_rows); outcome <- do.call(rbind, out_rows); truth <- do.call(rbind, truth)
exposure <- exposure[sample(nrow(exposure)), ]; outcome <- outcome[sample(nrow(outcome)), ]
write.table(exposure, file.path(outdir, "exposure_bmi_gwas.tsv"), sep = "\t", quote = FALSE, row.names = FALSE)
write.table(outcome,  file.path(outdir, "outcome_sbp_gwas.tsv"),  sep = "\t", quote = FALSE, row.names = FALSE)
write.csv(truth, file.path(outdir, "truth.csv"), row.names = FALSE)
cat("variants:", nrow(exposure), " in outcome:", nrow(outcome), " expected used:", sum(truth$expected_used), "\n")
print(table(truth$category, truth$expected_used))
