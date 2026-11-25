W <- ".."
args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 1) W <- args[1]
lg <- read.csv(file.path(W, "results/harmonisation_log.csv"), stringsAsFactors = FALSE)
print(table(lg$harmonisation_action, lg$used))
comp <- function(a) c(A = "T", T = "A", C = "G", G = "C")[a]
cl <- lg[grepl("^strand", lg$harmonisation_action), ]
cl$case <- ifelse(cl$outcome_A2 == comp(cl$exposure_EA),
                  "A2=comp(EA) [no flip correct]", "A2=comp(OA) [flip needed]")
print(table(cl$case))
cat("\nFirst row of each action:\n")
options(width = 250)
print(lg[!duplicated(lg$harmonisation_action), ], row.names = FALSE)
cat("\nFirst row of each strand sub-case:\n")
print(cl[!duplicated(cl$case), ], row.names = FALSE)
