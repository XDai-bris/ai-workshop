R <- "<runs>/review/specified_5/ws"
l <- read.csv(file.path(R, "results/harmonisation_log.csv"), stringsAsFactors = FALSE)
o <- read.delim(file.path(R, "data/main/outcome_sbp_gwas.tsv"), stringsAsFactors = FALSE)
e <- read.delim(file.path(R, "data/main/exposure_bmi_gwas.tsv"), stringsAsFactors = FALSE)
comp <- c(A="T",T="A",C="G",G="C")
x <- merge(merge(l, e[, c("SNP","BETA")], by = "SNP"), o[, c("rsid","beta")], by.x = "SNP", by.y = "rsid")
x$kind <- ifelse(x$harmonisation_action == "strand: complemented, no flip",
                 ifelse(x$outcome_A2 == comp[x$exposure_EA], "strand: complemented, no flip [A2=comp(EA)]",
                        "strand: complemented, no flip [A2=comp(OA)]"), x$harmonisation_action)
pick <- x[!duplicated(x$kind), ]
options(width = 250)
print(pick[, c("SNP","exposure_EA","exposure_OA","exposure_EAF","outcome_A1","outcome_A2","outcome_freq_A2","BETA","beta","kind")], row.names = FALSE)
