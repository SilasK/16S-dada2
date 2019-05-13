library(dada2)
library(ggplot2)

sink(snakemake@log[[1]])

seqtab= readRDS(snakemake@input[['seqtab']]) # seqtab

# Length of sequences

seq_lengths= nchar(getSequences(seqtab))

l_hist= as.data.frame(table(seq_lengths))
colnames(l_hist) <- c("LENGTH","COUNT")

ggplot(l_hist,aes(x=LENGTH,y=COUNT)) + 
  geom_histogram(stat="identity") + 
  ggtitle("Sequence Lengths by SEQ Count") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5,size=10)) +
  theme(axis.text.y=element_text(size=10))

ggsave(snakemake@output[['plot_seqlength']])

table2 <- tapply(colSums(seqtab), seq_lengths, sum)
table2 <- data.frame(key=names(table2), value=table2,stringsAsFactors = F)
colnames(table2) <- c("LENGTH","ABUNDANCE")


ggplot(table2,aes(x=LENGTH,y=ABUNDANCE)) + 
  geom_histogram(stat="identity") + 
  ggtitle("Sequence Lengths by SEQ Abundance") +
  theme_bw() +
  theme(axis.text.x=element_text(angle=90,hjust=1,vjust=0.5,size=10)) +
  theme(axis.text.y=element_text(size=10))

ggsave(snakemake@output[['plot_seqabundance']])


most_common_length= as.numeric(table2[[which.max(table2$ABUNDANCE),'LENGTH']])



max_diff=snakemake@config[['max_length_variation']]


right_length= abs(seq_lengths- most_common_length)< max_diff
seqtab=seqtab[,right_length]

saveRDS(seqtab, snakemake@output[['rds']]) 
write.table(seqtab,snakemake@output[['tsv']],sep =  "\t")

  


removed_fraction = sum(table2[!abs(as.numeric(table2$LENGTH)- most_common_length) <max_diff, 'ABUNDANCE']) / sum(table2$ABUNDANCE)

print(paste0(removed_fraction," sequence are removed because they are shorter than expected: ",most_common_length,"+-", max_diff )  )



if (removed_fraction >0.1)
{
  message("Removed a high fraction of reads")
}

