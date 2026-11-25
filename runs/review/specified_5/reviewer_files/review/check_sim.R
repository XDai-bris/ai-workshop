# run from review/run : compare script actions to simulated truth
W <- ".."
l <- read.csv("results/harmonisation_log.csv", stringsAsFactors = FALSE)
t <- read.csv(file.path(W, "sim/truth.csv"), stringsAsFactors = FALSE)
x <- merge(t, l, by = "SNP")
x$act <- sub(",.*", "", x$harmonisation_action)
print(table(x$situation, x$harmonisation_action))
# was the sign decision right? script negates iff action ends with "flipped" (but not "no flip")
x$script_negates <- grepl("flipped: allele|, flipped$", x$harmonisation_action) & x$used
x$should <- x$true_sign_needed == "negate outcome beta"
u <- x[x$used, ]
cat("\nSign decision wrong, by situation:\n")
print(table(u$situation, wrong = u$script_negates != u$should))
