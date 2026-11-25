# Makes a PATCHED COPY of the analysis script inside review/ (the original is not touched).
# Patch: line 99-100 case (outcome A2 is the complement of the exposure OTHER allele) must flip the sign.
args <- commandArgs(trailingOnly = TRUE)
W <- args[1]
src <- readLines(file.path(W, "analysis/mr_analysis.R"))
i <- grep("a2 == comp(oa) && a1 == comp(ea)", src, fixed = TRUE)
stopifnot(length(i) == 1)
stopifnot(grepl("dat\\$flip\\[i\\] <- FALSE", src[i + 1]))
src[i + 1] <- sub("<- FALSE; dat\\$action\\[i\\] <- \"strand: complemented, no flip\"",
                  "<- TRUE;  dat$action[i] <- \"strand: complemented, flipped\"", src[i + 1])
stopifnot(grepl("complemented, flipped", src[i + 1]))
writeLines(src, file.path(W, "review/mr_analysis_PATCHED_copy.R"))
cat("patched line", i + 1, ":", src[i + 1], "\n")
