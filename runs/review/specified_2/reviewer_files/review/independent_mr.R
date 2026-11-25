# From-scratch IVW / Q / Egger on my independent harmonisation (review/real_harmonisation_independent.csv),
# plus palindromic-rule and word-count checks. Does not use the script's code paths.
d <- read.csv("review/real_harmonisation_independent.csv", stringsAsFactors = FALSE)
d <- d[d$used, ]
cm <- c(A="T", T="A", C="G", G="C")
# palindromic variants: decide strand by comparing EAF with outcome freq of the labelled A2
pal <- d$pal
f2  <- d$freq                                   # frequency of labelled A2
ea_is_a2 <- d$A2 == d$EFFECT_ALLELE
fEA_same <- ifelse(ea_is_a2, f2, 1 - f2)        # outcome freq of EA if strands agree
same <- (d$EAF < .5) == (fEA_same < .5)
# true allele of A2 in exposure labels: same strand -> A2; opposite -> comp(A2)
true_a2 <- ifelse(same, d$A2, cm[d$A2])
d$my_flip[pal] <- (true_a2 != d$EFFECT_ALLELE)[pal]
d$by <- ifelse(d$my_flip, -d$beta, d$beta)
bx <- d$BETA / 4.8; sx <- d$SE / 4.8; se <- d$se; w <- 1 / se^2
b  <- sum(w * bx * d$by) / sum(w * bx^2)
Q  <- sum(w * (d$by - b * bx)^2); n <- nrow(d)
phi <- max(1, sqrt(Q / (n - 1)))
cat(sprintf("n=%d  IVW=%.3f  se(RE)=%.3f  CI %.2f to %.2f  Q=%.2f (df %d) p=%.3g\n",
            n, b, phi / sqrt(sum(w * bx^2)), b - 1.96 * phi / sqrt(sum(w * bx^2)),
            b + 1.96 * phi / sqrt(sum(w * bx^2)), Q, n - 1, pchisq(Q, n - 1, lower.tail = FALSE)))
o <- ifelse(bx < 0, -1, 1); X <- bx * o; Y <- d$by * o
f <- lm(Y ~ X, weights = w); s <- summary(f)
cat(sprintf("Egger slope=%.3f  intercept=%.4f\n", coef(f)[2], coef(f)[1]))
cat("pchisq check for the report's Q=135.6, df=88: p =", signif(pchisq(135.6, 88, lower.tail = FALSE), 3), "\n")
# palindromic rule: were any dropped on outcome MAF alone (not in the plan)?
e <- read.delim("data/main/exposure_bmi_gwas.tsv"); l <- read.csv("results/harmonisation_log.csv")
dr <- l[grepl("palindromic, MAF", l$harmonisation_action), ]
print(data.frame(SNP = dr$SNP, exposure_MAF = round(pmin(dr$exposure_EAF, 1 - dr$exposure_EAF), 3),
                 outcome_MAF = round(pmin(dr$outcome_freq_A2, 1 - dr$outcome_freq_A2), 3)))
cat("report.md words:", length(strsplit(paste(readLines("report.md"), collapse = " "), "\\s+")[[1]]), "\n")
