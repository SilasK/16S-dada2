library(dada2)

sink(snakemake@log[[1]])

track.filt <- filterAndTrim(snakemake@input[['R1']],snakemake@output[['R1']], 
                            snakemake@input[['R2']],snakemake@output[['R2']], 
                            truncLen= snakemake@config[["truncLen"]],
                            maxN=0,
                            maxEE=snakemake@config[["maxEE"]], 
                            truncQ=snakemake@config[["truncQ"]],
                            compress=TRUE,
                            verbose=TRUE,
                            multithread=snakemake@threads,
                            rm.phix=TRUE)



row.names(track.filt) <- snakemake@params[["samples"]]

colnames(track.filt) = c('raw','filtered')

write.table(track.filt,snakemake@output[['nreads']],  sep='\t')
