l <- read.csv("results/harmonisation_log.csv", stringsAsFactors=FALSE)
comp <- c(A="T",T="A",C="G",G="C")
nc <- l[l$harmonisation_action=="strand: complemented, no flip",]
nc$kind <- ifelse(nc$outcome_A2==comp[nc$exposure_EA],"A2=comp(EA): no flip correct","A2=comp(OA): should flip")
print(table(nc$kind))
print(head(nc[nc$kind=="A2=comp(OA): should flip",],4))
