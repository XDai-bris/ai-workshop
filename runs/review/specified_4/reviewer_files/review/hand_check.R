# Hand check on the real data. Runs the UNCHANGED script (via source, inside review/hand/) to get its internal
# per-variant harmonised outcome beta (dat$beta_out_h), then prints it beside a by-hand expectation.
a <- commandArgs(trailingOnly = TRUE); W <- a[1]
real_args <- file.path(W, "data/main")
dir.create(file.path(W, "review/hand"), showWarnings = FALSE)
setwd(file.path(W, "review/hand"))
commandArgs <- function(trailingOnly = FALSE) real_args
invisible(capture.output(source(file.path(W, "analysis/mr_analysis.R"))))
options(width = 250, digits = 4)

pick <- c(none = "rs19369461", swapped = "rs94071924",
          comp_A2_is_comp_EA = "rs62087431", comp_A2_is_comp_OA = "rs73176882",
          pal_same_noflip = "rs49900600", pal_opp_flipped = "rs93437852", pal_opp_noflip = "rs58559743",
          pal_ambiguous_dropped = "rs90247876", missing_dropped = "rs77134306", absent_dropped = "rs50795004")
# by-hand expectation (derived from the alleles and frequencies as reasoned in the review text):
hand <- c(none = "keep sign", swapped = "negate", comp_A2_is_comp_EA = "keep sign", comp_A2_is_comp_OA = "negate",
          pal_same_noflip = "keep sign", pal_opp_flipped = "negate", pal_opp_noflip = "keep sign",
          pal_ambiguous_dropped = "drop", missing_dropped = "drop", absent_dropped = "drop")
d <- dat[match(pick, dat$SNP), c("SNP", "EFFECT_ALLELE", "OTHER_ALLELE", "EAF", "A1", "A2", "freq", "beta", "action", "flip", "beta_out_h")]
d$case <- names(pick); d$hand <- hand[d$case]
d$hand_beta_out_h <- ifelse(d$hand == "keep sign", d$beta, ifelse(d$hand == "negate", -d$beta, NA))
d$script_sign <- ifelse(is.na(d$beta_out_h), "dropped", ifelse(sign(d$beta_out_h) > 0, "+", "-"))
d$hand_sign   <- ifelse(is.na(d$hand_beta_out_h), "dropped", ifelse(sign(d$hand_beta_out_h) > 0, "+", "-"))
d$match <- d$script_sign == d$hand_sign
print(d[, c("case", "SNP", "EFFECT_ALLELE", "OTHER_ALLELE", "EAF", "A1", "A2", "freq", "beta", "beta_out_h", "script_sign", "hand_sign", "match")], row.names = FALSE)
cat("\naction labels:\n"); print(d[, c("case", "action")], row.names = FALSE)
