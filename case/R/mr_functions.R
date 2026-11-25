# Reference two-sample MR pipeline: standardise, harmonise, IVW / MR-Egger / weighted median.
# Base R only. Defaults implement the correct analysis; the arguments exist so that
# check_generator.R can reproduce specific mistakes (trap ablation).

complement <- function(x) unname(c(A = "T", C = "G", G = "C", T = "A")[x])
is_palindromic <- function(a1, a2) complement(a1) == a2

read_tsv <- function(path) {
  read.delim(path, sep = "\t", stringsAsFactors = FALSE, check.names = FALSE)
}

standardise_exposure <- function(d) {
  data.frame(SNP = d$SNP, ea = d$EFFECT_ALLELE, oa = d$OTHER_ALLELE, eaf = d$EAF,
             beta = d$BETA, se = d$SE, stringsAsFactors = FALSE)
}

# assume_a1_effect: mistake, treat A1 as the effect allele (dictionary says beta refers to A2).
# minus9_is_missing: correct handling of the -9 missing code.
standardise_outcome <- function(d, assume_a1_effect = FALSE, minus9_is_missing = TRUE) {
  if (all(c("A1", "A2") %in% names(d))) {
    if (assume_a1_effect) {
      ea <- d$A1; oa <- d$A2
    } else {
      ea <- d$A2; oa <- d$A1
    }
    eaf <- d$freq
  } else {
    ea <- d$effect_allele; oa <- d$other_allele; eaf <- d$eaf
  }
  out <- data.frame(SNP = d$rsid, ea = ea, oa = oa, eaf = eaf, beta = d$beta, se = d$se,
                    stringsAsFactors = FALSE)
  drop <- is.na(out$beta) | is.na(out$se)
  if (minus9_is_missing) drop <- drop | out$beta == -9 | out$se == -9
  out[!drop, ]
}

# naive = TRUE: mistake, align on effect-allele letter only (no strand or palindrome handling).
harmonise <- function(exp, out, maf_threshold = 0.42, naive = FALSE) {
  m <- merge(exp, out, by = "SNP", suffixes = c(".x", ".y"))
  n <- nrow(m)
  by <- m$beta.y
  keep <- rep(TRUE, n)
  action <- character(n)
  for (i in seq_len(n)) {
    ex <- m$ea.x[i]; ox <- m$oa.x[i]; ey <- m$ea.y[i]; oy <- m$oa.y[i]
    if (naive) {
      if (ey == ex) action[i] <- "aligned" else { by[i] <- -by[i]; action[i] <- "swapped" }
      next
    }
    if (is_palindromic(ex, ox)) {
      maf <- min(m$eaf.x[i], 1 - m$eaf.x[i])
      if (maf > maf_threshold) { keep[i] <- FALSE; action[i] <- "palindromic_ambiguous"; next }
      # Letters cannot tell strand apart: the outcome effect allele is the same physical allele
      # as the exposure effect allele if its frequency matches.
      same <- abs(m$eaf.y[i] - m$eaf.x[i]) < abs(m$eaf.y[i] - (1 - m$eaf.x[i]))
      if (!same) by[i] <- -by[i]
      action[i] <- if (same) "palindromic_inferred_same" else "palindromic_inferred_flip"
    } else if (ey == ex && oy == ox) {
      action[i] <- "aligned"
    } else if (ey == ox && oy == ex) {
      by[i] <- -by[i]; action[i] <- "swapped"
    } else if (complement(ey) == ex && complement(oy) == ox) {
      action[i] <- "strand_flip"
    } else if (complement(ey) == ox && complement(oy) == ex) {
      by[i] <- -by[i]; action[i] <- "strand_flip_swapped"
    } else {
      keep[i] <- FALSE; action[i] <- "allele_mismatch"
    }
  }
  data.frame(SNP = m$SNP, bx = m$beta.x, sex = m$se.x, by = by, sey = m$se.y,
             action = action, keep = keep, stringsAsFactors = FALSE)
}

mr_ivw <- function(bx, by, sey) {
  s <- summary(lm(by ~ 0 + bx, weights = 1 / sey^2))
  list(b = coef(s)[1, 1], se = coef(s)[1, 2] / min(1, s$sigma))
}

mr_egger <- function(bx, by, sey) {
  sgn <- sign(bx)
  bx <- abs(bx); by <- by * sgn
  s <- summary(lm(by ~ bx, weights = 1 / sey^2))
  k <- 1 / min(1, s$sigma)
  list(b = coef(s)[2, 1], se = coef(s)[2, 2] * k,
       intercept = coef(s)[1, 1], intercept_se = coef(s)[1, 2] * k)
}

weighted_median <- function(b_iv, w) {
  o <- order(b_iv)
  b <- b_iv[o]
  w <- w[o] / sum(w)
  s <- cumsum(w) - 0.5 * w
  below <- max(which(s < 0.5))
  b[below] + (b[below + 1] - b[below]) * (0.5 - s[below]) / (s[below + 1] - s[below])
}

mr_weighted_median <- function(bx, by, sex, sey, nboot = 1000) {
  w <- bx^2 / sey^2  # first-order inverse-variance weights of the ratio estimates
  est <- weighted_median(by / bx, w)
  boot <- replicate(nboot, {
    weighted_median(rnorm(length(by), by, sey) / rnorm(length(bx), bx, sex), w)
  })
  list(b = est, se = sd(boot))
}

# Run all three methods on a harmonised table. Estimates are scaled by `scale`
# (divide per-SD estimates by SD_BMI to get mmHg per kg/m^2).
run_mr <- function(h, scale = 1, nboot = 1000) {
  h <- h[h$keep, ]
  ivw <- mr_ivw(h$bx, h$by, h$sey)
  egg <- mr_egger(h$bx, h$by, h$sey)
  wm <- mr_weighted_median(h$bx, h$by, h$sex, h$sey, nboot = nboot)
  res <- data.frame(
    method = c("IVW", "MR-Egger", "Weighted median"),
    estimate = c(ivw$b, egg$b, wm$b) / scale,
    se = c(ivw$se, egg$se, wm$se) / scale,
    n_snps = nrow(h),
    stringsAsFactors = FALSE
  )
  res$ci_lower <- res$estimate - 1.96 * res$se
  res$ci_upper <- res$estimate + 1.96 * res$se
  attr(res, "egger_intercept") <- c(est = egg$intercept, se = egg$intercept_se)
  res
}
