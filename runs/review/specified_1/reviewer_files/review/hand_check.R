setwd("<runs>/review/specified_1/ws")
h <- read.csv("results/harmonisation_log.csv")
e <- read.delim("data/main/exposure_bmi_gwas.tsv"); o <- read.delim("data/main/outcome_sbp_gwas.tsv")
d <- merge(merge(h, e[, c("SNP", "BETA")], by = "SNP"), o[, c("rsid", "beta")], by.x = "SNP", by.y = "rsid", all.x = TRUE)
d <- d[match(h$SNP, d$SNP), ]
comp <- c(A = "T", T = "A", C = "G", G = "C")
# hand rule: outcome beta is for A2 (forward strand). Need effect of exposure EA.
# Allele that A2 is on the exposure strand: A2 itself (same strand) or comp(A2) (opposite).
# Sign multiplier = +1 if that allele is EA, -1 if it is OA.
hand <- function(r) {
  ea <- r$exposure_EA; oa <- r$exposure_OA; a2 <- r$outcome_A2
  if (is.na(a2)) return(NA)
  if (a2 == ea) return(1); if (a2 == oa) return(-1)
  if (comp[[a2]] == ea) return(1); if (comp[[a2]] == oa) return(-1); NA
}
d$hand_mult <- sapply(seq_len(nrow(d)), function(i) hand(d[i, ]))
d$script_mult <- ifelse(!d$used, NA, ifelse(grepl("flipped: allele order|, flipped$", d$harmonisation_action), -1, 1))
d$agree <- d$hand_mult == d$script_mult
# non-palindromic rows only for the hand rule (palindromic strand is unknowable without frequency)
pal <- paste0(pmin(d$exposure_EA, d$exposure_OA), pmax(d$exposure_EA, d$exposure_OA)) %in% c("AC", "CG") & d$exposure_EA %in% c("A","T","C","G")
pal <- (d$exposure_EA == comp[d$exposure_OA])
d$pal <- pal
cat("--- non-palindromic: script vs hand, by action\n")
print(table(d$harmonisation_action[!pal & d$used], d$agree[!pal & d$used], useNA = "ifany"))
cat("--- one example per action\n")
ex <- d[!duplicated(d$harmonisation_action), ]
print(ex[, c("SNP", "exposure_EA", "exposure_OA", "exposure_EAF", "outcome_A1", "outcome_A2", "outcome_freq_A2", "beta", "harmonisation_action", "hand_mult", "script_mult")], row.names = FALSE)
cat("--- palindromic rows\n")
print(d[pal, c("SNP", "exposure_EA", "exposure_OA", "exposure_EAF", "outcome_A1", "outcome_A2", "outcome_freq_A2", "beta", "harmonisation_action")], row.names = FALSE)
cat("--- complemented-no-flip rows where hand says flip: ", sum(d$harmonisation_action == "strand: complemented, no flip" & d$hand_mult == -1, na.rm = TRUE), "\n")
