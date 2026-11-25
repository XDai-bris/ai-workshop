# Seed criteria (fixed before searching, 2026-11-24):
#  correct pipeline: control_positive CI of IVW, Egger, WM all include 0.30; main IVW CI includes 0.25
#  planted bug (strand_flip_swapped not negated): control IVW CI upper < 0.25 (clear known-answer failure)
#  first seed >= 20261124 that meets all of these
# Usage (from the case/ folder): Rscript select_case_seed.R
source("R/sim_functions.R"); source("R/mr_functions.R")
fit <- function(cfg, plant) {
  set.seed(cfg$seed); rs <- draw_rsids(cfg$n_snps * 2); out <- list()
  for (k in 1:2) {
    nm <- names(cfg$datasets)[k]
    sim <- simulate_dataset(cfg$datasets[[nm]], cfg, rs[(k - 1) * cfg$n_snps + seq_len(cfg$n_snps)])
    h <- harmonise(standardise_exposure(sim$exposure), standardise_outcome(sim$outcome))
    if (plant) { i <- h$action == "strand_flip_swapped"; h$by[i] <- -h$by[i] }
    out[[nm]] <- run_mr(h, scale = 4.8, nboot = 200)
  }
  out
}
inci <- function(r, v) r$ci_lower <= v & r$ci_upper >= v
for (s in 20261124L + 0:300) {
  cfg <- default_config(); cfg$seed <- s
  cfg$datasets <- list(control_positive = list(beta_per_unit = 0.30, pleio_frac = 0, pleio_mean = 0, pleio_sd = 0),
                       main = list(beta_per_unit = 0.25, pleio_frac = 0, pleio_mean = 0, pleio_sd = 0))
  ok <- fit(cfg, FALSE)
  if (!all(inci(ok$control_positive, 0.30)) || !inci(ok$main[1, ], 0.25)) next
  bad <- fit(cfg, TRUE)
  if (bad$control_positive$ci_upper[1] >= 0.25) next
  cat("seed", s, "\n"); print(ok); print(bad); break
}
