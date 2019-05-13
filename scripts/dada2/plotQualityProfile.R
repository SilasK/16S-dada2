library(dada2)
library(ggplot2)
#sink(snakemake@log[[1]])


for (i in 1:length(snakemake@input))
{
  plotQualityProfile(snakemake@input[[i]])
  ggsave(snakemake@output[[i]])
}


                   

