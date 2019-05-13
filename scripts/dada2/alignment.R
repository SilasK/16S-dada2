#library(dada2)
library(DECIPHER)
library(phangorn)
sink(snakemake@log[[1]])
seqtab = readRDS(snakemake@input[['rds']])

seqs <- colnames(seqtab)


#seqs <- getSequences(seqtab)
names(seqs) <- seqs # This propagates to the tip labels of the tree
alignment <- AlignSeqs(DNAStringSet(seqs), anchor=NA)

writeXStringSet(alignment,snakemake@output[['alignment']])


phang.align <- phyDat(as(alignment, "matrix"), type="DNA")
dm <- dist.ml(phang.align)


treeNJ <- NJ(dm) # Note, tip order != sequence order
fit = pml(treeNJ, data=phang.align)

## negative edges length changed to 0!

fitGTR <- update(fit, k=4, inv=0.2)
fitGTR <- optim.pml(fitGTR, model="GTR", optInv=TRUE, optGamma=TRUE,
                    rearrangement = "stochastic", control = pml.control(trace = 0))

write.tree(fitGTR$tree,snakemake@output[['tree']])
