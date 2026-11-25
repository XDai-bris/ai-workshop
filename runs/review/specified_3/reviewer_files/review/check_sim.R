# Compare what the (unchanged) script did with the known truth in the simulation.
# Run from review/:  Rscript check_sim.R
tr  <- read.csv("sim_data/truth.csv", stringsAsFactors = FALSE)
lg  <- read.csv("run_sim2/results/harmonisation_log.csv", stringsAsFactors = FALSE)
ex  <- read.delim("sim_data/exposure_bmi_gwas.tsv", stringsAsFactors = FALSE)
out <- read.delim("sim_data/outcome_sbp_gwas.tsv", stringsAsFactors = FALSE)
d <- merge(merge(lg, tr, by = "SNP"), out[, c("rsid", "beta", "se")], by.x = "SNP", by.y = "rsid")
d <- merge(d, ex[, c("SNP", "BETA", "SE")], by = "SNP")
d <- d[d$used, ]
act <- d$harmonisation_action
script_flip <- grepl("^flipped|, flipped$", act)           # same rule as flip flag in the script
d$script_by <- ifelse(script_flip, -d$beta, d$beta)       # outcome beta the script used
d$sign_ok   <- sign(d$script_by) == sign(d$true_by_ea)
cat("Outcome sign correct, by simulated allele situation (rows = used variants):\n")
print(aggregate(sign_ok ~ kind, d, function(x) sprintf("%d/%d", sum(x), length(x))))
cat("\nAction text vs situation:\n"); print(table(d$kind, d$harmonisation_action))

# Estimates under four combinations: (units as script / as dictionary) x (orientation as script / as truth)
ivw <- function(bx, by, se) { w <- 1 / se^2; sum(w * bx * by) / sum(w * bx^2) }
bx_script <- d$BETA / 4.8; bx_correct <- d$BETA * 4.8
cat("\nIVW point estimate, true effect = 0.8 mmHg per kg/m2:\n")
cat(sprintf("  script units (BETA/4.8), script orientation : %6.2f\n", ivw(bx_script,  d$script_by, d$se)))
cat(sprintf("  script units (BETA/4.8), true orientation   : %6.2f   (x23.04 = 4.8^2 too big)\n", ivw(bx_script, d$true_by_ea, d$se)))
cat(sprintf("  correct units (BETA*4.8), script orientation: %6.2f\n", ivw(bx_correct, d$script_by, d$se)))
cat(sprintf("  correct units (BETA*4.8), true orientation  : %6.2f\n", ivw(bx_correct, d$true_by_ea, d$se)))
