# Simulation of two-sample MR summary statistics with a known truth.
#
# Every SNP is first defined on its exposure-increasing allele. Each GWAS file then reports
# a randomly chosen allele as its effect allele, as real consortia do.
# Base R only.

default_config <- function() {
  list(
    seed = 20261116L,        # first seed >= 20261115 meeting the criteria in select_seed.R
    sd_bmi = 4.8,            # kg/m^2 per SD of BMI (stated in the data dictionary)
    sd_sbp = 19,             # mmHg, used for outcome standard errors
    n_exposure = 300000,
    n_outcome = 750000,
    n_snps = 100,
    min_z_exposure = 7,      # every instrument strong; no selection step, so no winner's curse
    gamma_floor = 0.01,      # per-allele SNP-BMI effect (SD units) = floor + Exp(mean = excess)
    gamma_mean_excess = 0.012,
    balanced_sd = 0.005,     # balanced (mean-zero) pleiotropy in every dataset, mmHg
    n_palindromic = 8,       # half clearly inferable from EAF, half ambiguous (MAF 0.43-0.49)
    strand_flip_frac = 0.50, # share of non-palindromic SNPs reported on the other strand in the outcome (e.g. TOP/BOT mix-up)
    n_missing_code = 3,      # outcome rows with beta/se/pval = -9
    n_absent_in_outcome = 4, # instruments missing from the outcome file
    traps = list(
      allele_convention = TRUE, # outcome beta refers to A2; documented only in the dictionary
      units = TRUE,             # exposure BETA in SD units; question asks per kg/m^2
      missing_code = TRUE,
      strand_flip = TRUE,
      palindromic = TRUE
    ),
    # beta_per_unit: mmHg SBP per 1 kg/m^2 BMI. Directional pleiotropy acts on the
    # exposure-increasing allele (mmHg per allele). Values tuned 2026-10-15 with check_generator.R so that
    # IVW fails the negative control and misses the main truth, while MR-Egger and weighted median recover both.
    datasets = list(
      control_positive = list(beta_per_unit = 0.30, pleio_frac = 0,    pleio_mean = 0,    pleio_sd = 0),
      control_negative = list(beta_per_unit = 0,    pleio_frac = 0.15, pleio_mean = 0.20, pleio_sd = 0.03),
      main             = list(beta_per_unit = 0.55, pleio_frac = 0.15, pleio_mean = 0.20, pleio_sd = 0.03)
    )
  )
}

complement <- function(x) unname(c(A = "T", C = "G", G = "C", T = "A")[x])

# Simulate one dataset. Returns list(exposure, outcome, truth) as data frames.
simulate_dataset <- function(spec, cfg, rsids) {
  J <- cfg$n_snps
  stopifnot(length(rsids) == J)
  pal <- if (isTRUE(cfg$traps$palindromic)) seq_len(cfg$n_palindromic) else integer(0)
  nonpal_pairs <- list(c("A", "C"), c("A", "G"), c("C", "T"), c("G", "T"))
  pal_pairs <- list(c("A", "T"), c("C", "G"))
  pairs <- lapply(seq_len(J), function(j) {
    sample(if (j %in% pal) pal_pairs[[sample.int(2, 1)]] else nonpal_pairs[[sample.int(4, 1)]])
  })
  a_inc <- vapply(pairs, `[`, "", 1)  # exposure-increasing allele
  a_dec <- vapply(pairs, `[`, "", 2)

  f_inc <- runif(J, 0.05, 0.95)
  pal_ambiguous <- rep(FALSE, J)
  if (length(pal)) {
    amb <- pal[seq_len(floor(length(pal) / 2))]
    inf <- setdiff(pal, amb)
    maf <- c(runif(length(amb), 0.43, 0.49), runif(length(inf), 0.10, 0.35))
    f_inc[c(amb, inf)] <- ifelse(runif(length(pal)) < 0.5, maf, 1 - maf)
    pal_ambiguous[amb] <- TRUE
  }

  se_x <- 1 / sqrt(2 * f_inc * (1 - f_inc) * cfg$n_exposure)
  gamma <- pmax(cfg$gamma_floor + rexp(J, 1 / cfg$gamma_mean_excess), cfg$min_z_exposure * se_x)

  pleiotropic <- rep(FALSE, J)
  n_pleio <- round(spec$pleio_frac * J)
  if (n_pleio > 0) pleiotropic[sample.int(J, n_pleio)] <- TRUE
  alpha <- rnorm(J, 0, cfg$balanced_sd)
  alpha[pleiotropic] <- alpha[pleiotropic] + rnorm(n_pleio, spec$pleio_mean, spec$pleio_sd)

  beta_per_sd <- spec$beta_per_unit * cfg$sd_bmi
  Gamma <- beta_per_sd * gamma + alpha

  f_out <- pmin(pmax(f_inc + rnorm(J, 0, 0.01), 0.01), 0.99)
  se_y <- cfg$sd_sbp / sqrt(2 * f_out * (1 - f_out) * cfg$n_outcome)

  bx_inc <- gamma + rnorm(J, 0, se_x)
  # Instruments were selected at P < 5e-8 in this same GWAS, so redraw any estimate that would
  # not have passed (a small, realistic winner's curse). Found by the 2026-10-15 pilot agents.
  z_sel <- qnorm(1 - 5e-8 / 2)
  while (any(low <- abs(bx_inc / se_x) < z_sel)) {
    bx_inc[low] <- gamma[low] + rnorm(sum(low), 0, se_x[low])
  }
  by_inc <- Gamma + rnorm(J, 0, se_y)

  chr <- sample.int(22, J, replace = TRUE)
  pos <- sample.int(2e8, J)

  # Exposure file: random effect-allele orientation, BETA in SD units (or kg/m^2 without the trap)
  exp_eff_inc <- runif(J) < 0.5
  x_scale <- if (isTRUE(cfg$traps$units)) 1 else cfg$sd_bmi
  eaf_x <- pmin(pmax(f_inc + rnorm(J, 0, 0.005), 0.005), 0.995)
  exposure <- data.frame(
    SNP = rsids, CHR = chr, POS = pos,
    EFFECT_ALLELE = ifelse(exp_eff_inc, a_inc, a_dec),
    OTHER_ALLELE = ifelse(exp_eff_inc, a_dec, a_inc),
    EAF = round(ifelse(exp_eff_inc, eaf_x, 1 - eaf_x), 4),
    BETA = signif(ifelse(exp_eff_inc, bx_inc, -bx_inc) * x_scale, 6),
    SE = signif(se_x * x_scale, 6),
    P = signif(2 * pnorm(-abs(bx_inc / se_x)), 3),
    N = as.integer(cfg$n_exposure),
    stringsAsFactors = FALSE
  )
  exposure <- exposure[order(exposure$P), ]

  # Outcome file: independent orientation, then strand flips, missing codes, absent rows
  out_eff_inc <- runif(J) < 0.5
  eff <- ifelse(out_eff_inc, a_inc, a_dec)
  oth <- ifelse(out_eff_inc, a_dec, a_inc)
  freq <- round(ifelse(out_eff_inc, f_out, 1 - f_out), 4)
  beta_y <- signif(ifelse(out_eff_inc, by_inc, -by_inc), 6)
  se_y_rep <- signif(se_y, 6)
  pval_y <- signif(2 * pnorm(-abs(by_inc / se_y)), 3)

  nonpal_idx <- setdiff(seq_len(J), pal)
  absent <- rep(FALSE, J)
  if (cfg$n_absent_in_outcome > 0) absent[sample(nonpal_idx, cfg$n_absent_in_outcome)] <- TRUE

  strand_flipped <- rep(FALSE, J)
  if (isTRUE(cfg$traps$strand_flip)) {
    cand <- nonpal_idx[!absent[nonpal_idx]]
    strand_flipped[sample(cand, round(cfg$strand_flip_frac * length(cand)))] <- TRUE
  }
  if (length(pal)) {
    # half of the palindromic SNPs reported on the other strand (same letters, swapped meaning)
    strand_flipped[sample(pal, floor(length(pal) / 2))] <- TRUE
  }
  eff[strand_flipped] <- complement(eff[strand_flipped])
  oth[strand_flipped] <- complement(oth[strand_flipped])

  missing_code <- rep(FALSE, J)
  if (isTRUE(cfg$traps$missing_code) && cfg$n_missing_code > 0) {
    cand <- nonpal_idx[!absent[nonpal_idx]]
    missing_code[sample(cand, cfg$n_missing_code)] <- TRUE
    beta_y[missing_code] <- -9
    se_y_rep[missing_code] <- -9
    pval_y[missing_code] <- -9
  }

  if (isTRUE(cfg$traps$allele_convention)) {
    outcome <- data.frame(rsid = rsids, chr = chr, pos = pos, A1 = oth, A2 = eff, freq = freq,
                          beta = beta_y, se = se_y_rep, pval = pval_y, n = as.integer(cfg$n_outcome),
                          stringsAsFactors = FALSE)
  } else {
    outcome <- data.frame(rsid = rsids, chr = chr, pos = pos, effect_allele = eff, other_allele = oth,
                          eaf = freq, beta = beta_y, se = se_y_rep, pval = pval_y, n = as.integer(cfg$n_outcome),
                          stringsAsFactors = FALSE)
  }
  outcome <- outcome[!absent, ]
  outcome <- outcome[order(outcome$chr, outcome$pos), ]

  truth <- data.frame(
    rsid = rsids, a_inc = a_inc, a_dec = a_dec, f_inc = round(f_inc, 4),
    gamma_true_sd = gamma, alpha_true = alpha, pleiotropic = pleiotropic,
    palindromic = seq_len(J) %in% pal, palindromic_ambiguous = pal_ambiguous,
    outcome_strand_flipped = strand_flipped, outcome_missing_code = missing_code,
    absent_in_outcome = absent, exposure_effect_is_inc = exp_eff_inc,
    outcome_effect_is_inc = out_eff_inc,
    stringsAsFactors = FALSE
  )
  list(exposure = exposure, outcome = outcome, truth = truth,
       beta_per_unit = spec$beta_per_unit, beta_per_sd = beta_per_sd)
}

# Draw unique synthetic rsIDs for all datasets at once so they never overlap.
draw_rsids <- function(n) sprintf("rs%d", sample(1000000:99999999, n))
