# Compare a run's harmonisation log + estimates with the simulated truth.
# Usage: Rscript compare.R <rundir> <datadir>
a <- commandArgs(trailingOnly = TRUE); run <- a[1]; dd <- a[2]
options(width = 200, digits = 4)
lg  <- read.csv(file.path(run, "results/harmonisation_log.csv"), stringsAsFactors = FALSE)
tr  <- read.csv(file.path(dd, "truth.csv"), stringsAsFactors = FALSE)
ex  <- read.delim(file.path(dd, "exposure_bmi_gwas.tsv"), stringsAsFactors = FALSE)
oc  <- read.delim(file.path(dd, "outcome_sbp_gwas.tsv"), stringsAsFactors = FALSE)
es  <- read.csv(file.path(run, "results/estimates.csv"), stringsAsFactors = FALSE)

m <- merge(tr, lg, by = "SNP"); m <- merge(m, ex[, c("SNP", "BETA")], by = "SNP"); m <- merge(m, oc[, c("rsid", "beta")], by.x = "SNP", by.y = "rsid", all.x = TRUE)
m$script_flip <- m$harmonisation_action == "flipped: allele order swapped" | grepl(", flipped$", m$harmonisation_action)
m$by_h <- ifelse(m$script_flip, -m$beta, m$beta)

cat("== used/dropped decisions vs truth ==\n")
print(table(category = m$category, expected_used = m$expected_used, script_used = m$used))

u <- m[m$expected_used & m$used, ]
u$flip_ok <- u$script_flip == u$expected_flip
u$sign_ok <- sign(u$by_h) == sign(u$BETA)     # true effect positive => harmonised outcome beta has the exposure beta's sign
cat("\n== per category, among used variants: flip correct? / harmonised sign matches exposure sign? ==\n")
print(aggregate(cbind(flip_ok, sign_ok) ~ category, data = u, FUN = function(x) sprintf("%d/%d", sum(x), length(x))))
cat("\nOverall flip correct:", sum(u$flip_ok), "/", nrow(u), "   sign agrees:", sum(u$sign_ok), "/", nrow(u), "\n")

cat("\n== estimates (truth = 2.0 mmHg per kg/m2) ==\n")
print(es[, c("method", "estimate", "se", "ci_lower", "ci_upper", "n_snps")])
ivw <- es[1, ]
cat(sprintf("IVW z vs 2.0: %.1f SE;  covers truth: %s\n", (ivw$estimate - 2) / ivw$se, ivw$ci_lower <= 2 & 2 <= ivw$ci_upper))
write.csv(m, file.path(run, "compare_detail.csv"), row.names = FALSE)
