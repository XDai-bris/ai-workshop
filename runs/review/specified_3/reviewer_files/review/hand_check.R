# Hand check on the REAL data: independent re-derivation of the outcome sign for each log action.
# Run from review/:  Rscript hand_check.R      (reads ../ files only)
lg  <- read.csv("../results/harmonisation_log.csv", stringsAsFactors = FALSE)
ex  <- read.delim("../data/main/exposure_bmi_gwas.tsv", stringsAsFactors = FALSE, na.strings = c("NA", ""))
out <- read.delim("../data/main/outcome_sbp_gwas.tsv", stringsAsFactors = FALSE, na.strings = c("NA", ""))
d <- merge(merge(lg, ex[, c("SNP", "BETA")], by = "SNP"), out[, c("rsid", "beta")], by.x = "SNP", by.y = "rsid", all.x = TRUE)
comp <- c(A = "T", T = "A", C = "G", G = "C")
# Independent rule for NON-palindromic variants: the outcome beta is for A2.
#  A2 equals EA (or complement of EA)  -> beta already refers to EA   -> sign +1
#  A2 equals OA (or complement of OA)  -> beta refers to OA, negate   -> sign -1
d$my_sign <- NA
nonpal <- !(paste0(pmin(d$exposure_EA, d$exposure_OA), pmax(d$exposure_EA, d$exposure_OA)) %in% c("AT", "CG"))
ok <- d$used & nonpal
a2 <- d$outcome_A2[ok]; ea <- d$exposure_EA[ok]; oa <- d$exposure_OA[ok]
d$my_sign[ok] <- ifelse(a2 == ea | a2 == comp[ea], 1, ifelse(a2 == oa | a2 == comp[oa], -1, NA))
d$script_sign <- ifelse(!d$used, NA, ifelse(grepl("^flipped|, flipped$", d$harmonisation_action), -1, 1))
d$sub <- ifelse(d$harmonisation_action == "strand: complemented, no flip",
                ifelse(d$outcome_A2 == comp[d$exposure_EA], "complement, A2=comp(EA)", "complement, A2=comp(OA)"), "")
cat("Non-palindromic: hand sign vs script sign, by action\n")
x <- d[ok, ]; x$agree <- x$my_sign == x$script_sign
print(aggregate(agree ~ harmonisation_action + sub, x, function(v) sprintf("%d/%d agree", sum(v), length(v))))
cat("\nOne example per action (first row of each):\n")
ex1 <- do.call(rbind, lapply(split(d[d$used, ], paste(d$harmonisation_action, d$sub)[d$used]), function(g) g[1, ]))
print(ex1[, c("SNP", "exposure_EA", "exposure_OA", "exposure_EAF", "outcome_A1", "outcome_A2", "outcome_freq_A2", "beta", "harmonisation_action", "sub", "my_sign", "script_sign")], row.names = FALSE)
cat("\nAll used palindromic rows:\n")
print(d[d$used & !nonpal, c("SNP", "exposure_EA", "exposure_OA", "exposure_EAF", "outcome_A1", "outcome_A2", "outcome_freq_A2", "beta", "harmonisation_action", "script_sign")], row.names = FALSE)
