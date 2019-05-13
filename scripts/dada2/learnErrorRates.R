library(dada2)
library(ggplot2)
sink(snakemake@log[[1]])


errF <- learnErrors(snakemake@input[['R1']], nbases=snakemake@config[["learn_nbases"]], multithread=snakemake@threads,randomize = TRUE)
errR <- learnErrors(snakemake@input[['R2']], nbases=snakemake@config[["learn_nbases"]], multithread=snakemake@threads,randomize = TRUE)

save(errF,file=snakemake@output[['errR1']])
save(errR,file=snakemake@output[['errR2']])



## ---- plot-rates ----
plotErrors(errF,nominalQ=TRUE)
ggsave(snakemake@output[['plotErr1']])
plotErrors(errR,nominalQ=TRUE)
ggsave(snakemake@output[['plotErr2']])




