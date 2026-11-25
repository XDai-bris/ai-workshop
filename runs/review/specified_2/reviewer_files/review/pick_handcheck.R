# One variant per harmonisation action in results/harmonisation_log.csv, with raw rows for hand-checking.
l  <- read.csv("results/harmonisation_log.csv", stringsAsFactors = FALSE)
e  <- read.delim("data/main/exposure_bmi_gwas.tsv", stringsAsFactors = FALSE)
o  <- read.delim("data/main/outcome_sbp_gwas.tsv", stringsAsFactors = FALSE)
ci <- read.csv("review/real_harmonisation_independent.csv", stringsAsFactors = FALSE)
pick <- do.call(rbind, lapply(split(l, l$harmonisation_action), function(x) x[1, ]))
# extra pick: a "D" variant (complement of OTHER allele) -- first one in the log
dsnp <- ci$SNP[ci$case == "D: complement, A2=comp(OA)"][1]
pick <- rbind(pick, l[l$SNP == dsnp, ][1, ])
m <- merge(pick[, c("SNP", "harmonisation_action")],
           e[, c("SNP", "EFFECT_ALLELE", "OTHER_ALLELE", "EAF", "BETA")], by = "SNP", all.x = TRUE)
m <- merge(m, o[, c("rsid", "A1", "A2", "freq", "beta")], by.x = "SNP", by.y = "rsid", all.x = TRUE)
m$case <- ci$case[match(m$SNP, ci$SNP)]
options(width = 250)
print(m[order(m$harmonisation_action), ], row.names = FALSE)
