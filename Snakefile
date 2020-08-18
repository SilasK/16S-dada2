import os
import pandas as pd

#configfile: "config.yaml"
SampleTable = pd.read_table(config['sampletable'],index_col=0)
SAMPLES = list(SampleTable.index)

JAVA_MEM_FRACTION=0.85
CONDAENV ='envs'
PAIRED_END= ('R2' in SampleTable.columns)
FRACTIONS= ['R1']
if PAIRED_END: FRACTIONS+= ['R2']

rule all:
    input:
        "stats/Nreads_filtered.txt",
        "model/ErrorRates_R1.rds",
         "output/seqtab.tsv",
         "figures/Lengths/Sequence_Length_distribution_abundance.pdf",
         #expand("taxonomy/{ref}.tsv",ref= config['idtaxa_dbs'].keys()),
         "taxonomy/rep_seq.fasta",
         'stats/Nreads.tsv',
         "taxonomy/otu_tree.nwk"

rule taxonomy:
    input:
        expand("taxonomy/{ref}_gg.tsv", ref='Silva'),
        expand("taxonomy/{ref}.tsv", ref='Silva'),


rule all_profile:
    input: expand("figures/Quality_profiles/{direction}/{sample}_{direction}.pdf",sample=SAMPLES,direction=['R1','R2'])


rule all_filtered:
    input: "stats/Nreads_filtered.txt",



rule combine_read_counts:
    input:
        'stats/Nreads_filtered.txt',
        'stats/Nreads_dereplicated.txt',
        'stats/Nreads_chimera_removed.txt'
    output:
        'stats/Nreads.tsv',
        plot= 'stats/Nreads.pdf'
    run:
        import pandas as pd
        import matplotlib
        import matplotlib.pylab as plt

        D= pd.read_table(input[0],index_col=0)


        D= D.join(pd.read_table(input[1],index_col=0))
        D= D.join(pd.read_table(input[2],squeeze=True,index_col=0))

        D.to_csv(output[0],sep='\t')
        matplotlib.rcParams['pdf.fonttype']=42
        D.plot.bar(width=0.7,figsize=(D.shape[0]*0.3,5))
        plt.ylabel('N reads')
        plt.savefig(output.plot)







include: "rules/dada2.smk"
include: "rules/taxonomy.smk"
