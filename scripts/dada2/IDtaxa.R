library(dada2)
library(DECIPHER)
sink(snakemake@log[[1]])

packageVersion("DECIPHER")

seqtab= readRDS(snakemake@input[['seqtab']]) # seqtab


dna <- DNAStringSet(getSequences(seqtab)) # Create a DNAStringSet from the ASVs

load(snakemake@input[['ref']]) #trainingSet


ids <- IdTaxa(dna, trainingSet, strand="top", processors=snakemake@threads , verbose=FALSE) # use all processors

ranks <- c("domain", "phylum", "class", "order", "family", "genus", "species") # ranks of interest
# Convert the output object of class "Taxa" to a matrix analogous to the output from assignTaxonomy
taxid <- t(sapply(ids, function(x) {
  m <- match(ranks, x$rank)
  taxa <- x$taxon[m]
  taxa[startsWith(taxa, "unclassified_")] <- NA
  taxa
}))
colnames(taxid) <- ranks; rownames(taxid) <- getSequences(seqtab)


write.table(taxid,snakemake@output[['taxonomy']],sep='\t')








