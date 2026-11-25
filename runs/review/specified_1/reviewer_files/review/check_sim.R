setwd("<runs>/review/specified_1/ws/review/sim")
t <- read.csv("truth.csv"); h <- read.csv("run/results/harmonisation_log.csv")
d <- merge(t, h, by = "SNP")
o <- read.delim("data/outcome_sbp_gwas.tsv")
d <- merge(d, o[, c("rsid", "beta")], by.x = "SNP", by.y = "rsid", all.x = TRUE)
# the script negates the outcome beta exactly when the action text ends in "flipped" or is "flipped: allele order swapped"
d$flip <- grepl("flipped: allele order|, flipped$", d$harmonisation_action)
d$sign_script <- ifelse(d$used, ifelse(d$flip, -1, 1) * sign(d$beta), NA)
print(table(d$cat, d$harmonisation_action))
u <- d[d$used, ]
u$wrong <- u$sign_script != u$expected_sign
print(aggregate(wrong ~ cat, u, function(x) paste(sum(x), "of", length(x))))
write.csv(d, "../sim_check_table.csv", row.names = FALSE)
