# Usage (from the case/ folder): Rscript check_case.R
# Fits the correct pipeline and the planted bug (E2) to both datasets.
source("R/mr_functions.R")
set.seed(1)
plant_harmonise <- function(exp, out) {  # strand_flip_swapped left un-negated
  h <- harmonise(exp, out)
  i <- h$action == "strand_flip_swapped"; h$by[i] <- -h$by[i]; h
}
for (ds in c("control_positive", "main")) {
  e <- standardise_exposure(read_tsv(file.path(if (ds == "main") "project_template/data" else "extra_data", ds, "exposure_bmi_gwas.tsv")))
  o <- standardise_outcome(read_tsv(file.path(if (ds == "main") "project_template/data" else "extra_data", ds, "outcome_sbp_gwas.tsv")))
  h <- harmonise(e, o)
  cat("\n==", ds, "== actions:\n"); print(table(h$action))
  ok <- run_mr(h, scale = 4.8); ok$tag <- "correct"
  bad <- run_mr(plant_harmonise(e, o), scale = 4.8); bad$tag <- "plant: strand_flip_swapped not negated"
  r <- rbind(ok, bad); r[, 2:6] <- round(r[, 2:6], 3); print(r, row.names = FALSE)
  hk <- h[h$keep, ]; q <- sum((hk$by - coef(lm(hk$by ~ 0 + hk$bx, weights = 1/hk$sey^2)) * hk$bx)^2 / hk$sey^2)
  hb <- plant_harmonise(e, o); hb <- hb[hb$keep, ]; qb <- sum((hb$by - coef(lm(hb$by ~ 0 + hb$bx, weights = 1/hb$sey^2)) * hb$bx)^2 / hb$sey^2)
  cat(sprintf("Cochran Q correct %.1f vs plant %.1f on %d df; Egger intercept correct %.4f, plant %.4f\n", q, qb, nrow(hk) - 1,
      attr(ok, "egger_intercept")[1], attr(bad, "egger_intercept")[1]))
}
