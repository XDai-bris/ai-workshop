# Independent check of the script's flip decision using allele frequency.
# For non-palindromic variants (MAF away from 0.5) the outcome frequency of the exposure
# effect allele, implied by the script's flip decision, should be close to exposure EAF.
args <- commandArgs(trailingOnly = TRUE)
W <- args[1]
lg <- read.csv(file.path(W, "results/harmonisation_log.csv"), stringsAsFactors = FALSE)
comp <- function(a) c(A = "T", T = "A", C = "G", G = "C")[a]
u <- lg[lg$used & !grepl("^palindromic", lg$harmonisation_action), ]
# what the script did: flip TRUE only for "flipped: allele order swapped"
script_flip <- u$harmonisation_action == "flipped: allele order swapped"
# independent truth from alleles: is outcome A2 (after strand-alignment) the exposure EA?
a2_on_exp_strand <- ifelse(u$harmonisation_action == "none: alleles aligned" |
                           u$harmonisation_action == "flipped: allele order swapped",
                           u$outcome_A2,
                           ifelse(u$outcome_A2 %in% c("A","C","G","T"), comp(u$outcome_A2), NA))
true_flip <- a2_on_exp_strand != u$exposure_EA
freq_ea_script <- ifelse(script_flip, 1 - u$outcome_freq_A2, u$outcome_freq_A2)
freq_ea_true   <- ifelse(true_flip,   1 - u$outcome_freq_A2, u$outcome_freq_A2)
u$d_script <- abs(freq_ea_script - u$exposure_EAF)
u$d_true   <- abs(freq_ea_true   - u$exposure_EAF)
u$script_flip <- script_flip; u$true_flip <- true_flip
cat("Variants where script flip != allele-derived flip:", sum(script_flip != true_flip), "of", nrow(u), "\n")
cat("Of those, by action:\n"); print(table(u$harmonisation_action[script_flip != true_flip]))
bad <- u$d_script > 0.2
cat("Frequency-implied mismatch (|EAF - outcome freq of EA| > 0.2) under script's flip:", sum(bad), "\n")
cat("Same, under allele-derived flip:", sum(u$d_true > 0.2), "\n")
cat("Rows with freq mismatch under script flip == rows where script_flip != true_flip? ",
    all(bad[u$d_script > 0.2] == (script_flip != true_flip)[u$d_script > 0.2]), "\n")
cat("Max |diff| under allele-derived flip (excl. mismatch rows):", max(u$d_true), "\n")
write.csv(u[script_flip != true_flip, ], file.path(W, "review", "wrong_sign_variants.csv"), row.names = FALSE)
