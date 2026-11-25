# Simulate summary stats in the dictionary's formats. TRUE effect theta = 2.0 mmHg per kg/m2 (no pleiotropy).
# usage: Rscript make_sim.R <outdir> <noise_scale>   (noise_scale 1 = realistic, 1e-4 = near noise-free)
args <- commandArgs(TRUE); outdir <- args[1]; ns <- as.numeric(args[2])
set.seed(42); theta <- 2.0; SD <- 4.8
cm <- c(A="T",T="A",C="G",G="C")
nonpal <- list(c("A","C"),c("A","G"),c("T","C"),c("T","G"),c("C","A"),c("G","A"),c("C","T"),c("G","T"))
pal    <- list(c("A","T"),c("T","A"),c("C","G"),c("G","C"))
rows <- list(); k <- 0
add <- function(scn, n, palin, maf_ok=TRUE, same_strand, a2_is_ea, extra="") {
  for (i in seq_len(n)) {
    k <<- k + 1
    p <- if (palin) pal[[sample(4,1)]] else nonpal[[sample(length(nonpal),1)]]
    eaf <- if (maf_ok) { f <- runif(1,0.08,0.42); if (runif(1)<.5) f else 1-f } else runif(1,0.44,0.56)
    bsd <- sample(c(-1,1),1)*runif(1,0.03,0.07)          # exposure beta, SD units, for EA
    rows[[k]] <<- data.frame(scn=scn, SNP=sprintf("sim%03d",k), EA=p[1], OA=p[2], EAF=eaf, bsd=bsd,
                             same=same_strand, a2ea=a2_is_ea, extra=extra, stringsAsFactors=FALSE)
  }
}
add("nonpal aligned (A2=EA)",           25, FALSE, same_strand=TRUE,  a2_is_ea=TRUE)
add("nonpal swapped (A2=OA)",           25, FALSE, same_strand=TRUE,  a2_is_ea=FALSE)
add("nonpal opp strand, A2=comp(EA)",   25, FALSE, same_strand=FALSE, a2_is_ea=TRUE)
add("nonpal opp strand, A2=comp(OA)",   25, FALSE, same_strand=FALSE, a2_is_ea=FALSE)
add("pal same strand, A2=EA",            6, TRUE,  same_strand=TRUE,  a2_is_ea=TRUE)
add("pal same strand, A2=OA",            6, TRUE,  same_strand=TRUE,  a2_is_ea=FALSE)
add("pal opp strand, label A2=OA(=comp EA)", 6, TRUE, same_strand=FALSE, a2_is_ea=TRUE)
add("pal opp strand, label A2=EA(=comp OA)", 6, TRUE, same_strand=FALSE, a2_is_ea=FALSE)
add("pal MAF>0.42 (expect drop)",        6, TRUE,  maf_ok=FALSE, same_strand=TRUE,  a2_is_ea=TRUE)
add("pal MAF>0.42 opp (expect drop)",    4, TRUE,  maf_ok=FALSE, same_strand=FALSE, a2_is_ea=FALSE)
add("nonpal, outcome -9 (expect drop)",  4, FALSE, same_strand=TRUE,  a2_is_ea=TRUE, extra="miss")
add("nonpal, freq -9 only (keep)",       3, FALSE, same_strand=FALSE, a2_is_ea=FALSE, extra="freqmiss")
add("pal, freq -9 (cannot infer: drop)", 2, TRUE,  same_strand=TRUE,  a2_is_ea=TRUE, extra="freqmiss")
add("not in outcome (expect drop)",      4, FALSE, same_strand=TRUE,  a2_is_ea=TRUE, extra="absent")
d <- do.call(rbind, rows)
d$bkg <- d$bsd / SD
d$by_ea_true <- theta * d$bkg                         # true effect of EA on SBP, mmHg per allele
d$true_a2 <- ifelse(d$a2ea, d$EA, d$OA)               # which TRUE allele (exposure strand) is "A2"
d$sign_expected <- ifelse(d$a2ea, 1, -1)              # beta_out (for A2) = sign * effect of EA
d$se <- 0.03 * ns * runif(nrow(d), .8, 1.2)
d$beta_out <- d$sign_expected * d$by_ea_true + rnorm(nrow(d), 0, d$se)
d$freq_true_a2 <- pmin(.99, pmax(.01, ifelse(d$a2ea, d$EAF, 1-d$EAF) + rnorm(nrow(d), 0, .01)))
# outcome labels are on the forward strand: complemented if the strands differ
d$A2 <- unname(ifelse(d$same, d$true_a2, cm[d$true_a2]))
other_true <- ifelse(d$a2ea, d$OA, d$EA)
d$A1 <- unname(ifelse(d$same, other_true, cm[other_true]))
ex <- data.frame(SNP=d$SNP, CHR=1, POS=1000+seq_len(nrow(d)), EFFECT_ALLELE=d$EA, OTHER_ALLELE=d$OA, EAF=round(d$EAF,4),
                 BETA=d$bsd, SE=0.0026, P=1e-20, N=300000)
oc <- data.frame(rsid=d$SNP, chr=1, pos=ex$POS, A1=d$A1, A2=d$A2, freq=round(d$freq_true_a2,4),
                 beta=d$beta_out, se=d$se, pval=0.05, n=750000, stringsAsFactors=FALSE)
m <- d$extra=="miss";     oc[m, c("beta","se","pval")] <- -9
m <- d$extra=="freqmiss"; oc$freq[m] <- -9
oc <- oc[d$extra!="absent", ]
dir.create(outdir, recursive=TRUE, showWarnings=FALSE)
write.table(ex, file.path(outdir,"exposure_bmi_gwas.tsv"), sep="\t", quote=FALSE, row.names=FALSE)
write.table(oc[sample(nrow(oc)),], file.path(outdir,"outcome_sbp_gwas.tsv"), sep="\t", quote=FALSE, row.names=FALSE)
write.csv(d[,c("scn","SNP","EA","OA","EAF","bsd","A1","A2","sign_expected","extra")], file.path(outdir,"truth.csv"), row.names=FALSE)
cat("simulated", nrow(ex), "instruments; true theta =", theta, "\n")
