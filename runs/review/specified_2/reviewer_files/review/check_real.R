# Independent harmonisation of the real data; compare with results/harmonisation_log.csv
cm <- c(A="T",T="A",C="G",G="C")
e <- read.delim("data/main/exposure_bmi_gwas.tsv", stringsAsFactors=FALSE)
o <- read.delim("data/main/outcome_sbp_gwas.tsv", stringsAsFactors=FALSE)
l <- read.csv("results/harmonisation_log.csv", stringsAsFactors=FALSE)
d <- merge(e, o, by.x="SNP", by.y="rsid", sort=FALSE)
d <- d[d$beta != -9, ]
# Which allele (in exposure labels) does the outcome effect refer to?  outcome A2, possibly on other strand.
# Rule: effect is for EA if A2==EA or A2==comp(EA) (non-palindromic); for OA if A2==OA or A2==comp(OA).
d$pal <- (d$EFFECT_ALLELE==cm[d$OTHER_ALLELE])
d$case <- ifelse(d$pal, "palindromic",
  ifelse(d$A2==d$EFFECT_ALLELE & d$A1==d$OTHER_ALLELE, "A: aligned",
  ifelse(d$A2==d$OTHER_ALLELE & d$A1==d$EFFECT_ALLELE, "B: swapped",
  ifelse(d$A2==cm[d$EFFECT_ALLELE] & d$A1==cm[d$OTHER_ALLELE], "C: complement, A2=comp(EA)",
  ifelse(d$A2==cm[d$OTHER_ALLELE] & d$A1==cm[d$EFFECT_ALLELE], "D: complement, A2=comp(OA)", "mismatch")))))
d$my_flip <- d$case %in% c("B: swapped","D: complement, A2=comp(OA)")
d <- merge(d, l[,c("SNP","harmonisation_action","used")], by="SNP", sort=FALSE)
d$script_flip <- grepl("flipped: allele order", d$harmonisation_action) |
                 d$harmonisation_action=="palindromic: same strand (inferred from EAF), flipped" |
                 d$harmonisation_action=="palindromic: strand flipped (inferred from EAF), flipped"
print(table(case=d$case, script_action=d$harmonisation_action))
np <- d[!d$pal & d$used, ]
cat("\nNon-palindromic used: n =", nrow(np), "; my flip != script flip:", sum(np$my_flip != np$script_flip), "\n")
# frequency sanity check: outcome freq of EA after my harmonisation should be ~ EAF
np$fEA <- ifelse(np$my_flip, 1-np$freq, np$freq)
np$fEA_script <- ifelse(np$script_flip, 1-np$freq, np$freq)
cat("mean |EAF - outcome freq of EA|  mine:", round(mean(abs(np$EAF-np$fEA)),3), " script:", round(mean(abs(np$EAF-np$fEA_script)),3), "\n")
print(np[np$case=="D: complement, A2=comp(OA)", c("SNP","EFFECT_ALLELE","OTHER_ALLELE","EAF","A1","A2","freq","beta","fEA","fEA_script")][1:6,], row.names=FALSE)
write.csv(d, "review/real_harmonisation_independent.csv", row.names=FALSE)
