library(dada2)
sink(snakemake@log[[1]])
sink(snakemake@log[[1]])



sam.names= snakemake@params[["samples"]]
filtFs = snakemake@input[['R1']]
filtRs = snakemake@input[['R2']]

load(snakemake@input[['errR1']]) # errF
load(snakemake@input[['errR2']]) #errR



# derep - merge
mergers <- vector("list", length(sam.names))
dadaFs <- vector("list", length(sam.names))
names(mergers) <- sam.names
names(dadaFs) <- sam.names

names(filtFs) <- sam.names
names(filtRs) <- sam.names



for(sam in sam.names) {
  cat("Processing:", sam, "\n")

  derepF <- derepFastq(filtFs[[sam]])
  ddF <- dada(derepF, err=errF, multithread=snakemake@threads)

  dadaFs[[sam]] <- ddF
  derepR <- derepFastq(filtRs[[sam]])
  ddR <- dada(derepR, err=errR, multithread=snakemake@threads)

  merger <- mergePairs(ddF, derepF, ddR, derepR)
  mergers[[sam]] <- merger
}
rm(derepF); rm(derepR)


## ---- seqtab ----
seqtab.all <- makeSequenceTable(mergers)

## ---- save seqtab ----

saveRDS(seqtab.all, snakemake@output[['seqtab']])


## get N reads

getNreads <- function(x) sum(getUniques(x))

track <- cbind( sapply(dadaFs, getNreads), sapply(mergers, getNreads))
colnames(track) <- c( "denoised", "merged")
write.table(track,snakemake@output[['nreads']],sep='\t')
