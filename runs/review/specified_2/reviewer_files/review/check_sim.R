# Per-scenario comparison: script's action/used (from sim log) vs the known truth.
sim <- commandArgs(TRUE)[1]
t <- read.csv(file.path("review", sim, "data/truth.csv"), stringsAsFactors = FALSE)
l <- read.csv(file.path("review", sim, "results/harmonisation_log.csv"), stringsAsFactors = FALSE)
d <- merge(t, l[, c("SNP", "harmonisation_action", "used")], by = "SNP", sort = FALSE)
# Truth: used? and does the script's implied sign equal the required sign?
# required: outcome beta (for A2) must be multiplied by -1 iff sign_expected == -1  (A2 true allele = OA)
d$flip_needed <- d$sign_expected == -1
d$script_flip <- grepl("flipped: allele order|, flipped$", d$harmonisation_action)
d$should_use <- d$extra %in% c("", "freqmiss") & !grepl("MAF>0.42|^pal, freq -9", d$scn)
d$sign_ok <- ifelse(d$used, d$flip_needed == d$script_flip, NA)
agg <- aggregate(cbind(n = 1, used = d$used, should_use = d$should_use,
                       sign_wrong = d$used & !d$sign_ok) ~ scn, data = d, FUN = sum)
print(agg, row.names = FALSE)
cat("\nused where it should be dropped:", sum(d$used & !d$should_use),
    " | dropped where it should be used:", sum(!d$used & d$should_use),
    " | used with WRONG sign:", sum(d$used & !d$sign_ok), "of", sum(d$used), "\n")
print(table(d$scn, d$harmonisation_action)[, , drop = FALSE][0, ])  # (header only)
write.csv(d, file.path("review", sim, "sim_check.csv"), row.names = FALSE)
