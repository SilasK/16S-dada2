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

ddF <- dada(filtFs, err=errF, multithread=snakemake@threads, pool=TRUE)
ddR <- dada(filtRs, err=errR, multithread=snakemake@threads, pool=TRUE)

mergers <- mergePairs(ddF, filtFs, ddR, filtRs)

## ---- seqtab ----
seqtab.all <- makeSequenceTable(mergers)

## ---- save seqtab ----

saveRDS(seqtab.all, snakemake@output[['seqtab']])


## get N reads

getNreads <- function(x) sum(getUniques(x))

track <- cbind( sapply(dadaFs, getNreads), sapply(mergers, getNreads))
colnames(track) <- c( "denoised", "merged")
write.table(track,snakemake@output[['nreads']],sep='\t')
