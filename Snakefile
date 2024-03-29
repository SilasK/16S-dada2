import os
import pandas as pd

#configfile: "config.yaml"

sample_table_file=config.get('sampletable','samples.tsv')

if not os.path.exists(sample_table_file):

    logger.critical("Couldn't find sampletable!"
                    f"I looked for {sample_table_file} relativ to working directory.\n"
                    "Create one with the script prepare_sample_table.py \n"
                    "You can also specify the path to the sample table in the config file."
                    )
    exit(1)

SampleTable = pd.read_table(sample_table_file,index_col=0)



SAMPLES = list(SampleTable.index)

JAVA_MEM_FRACTION=0.85
CONDAENV ='envs'
PAIRED_END= ('R2' in SampleTable.columns)
FRACTIONS= ['R1']
if PAIRED_END: FRACTIONS+= ['R2']

def get_taxonomy_names():

    if 'idtaxa_dbs' in config and config['idtaxa_dbs'] is not None:
        return config['idtaxa_dbs'].keys()
    else:
        return []


rule all:
    input:
        "stats/Nreads_filtered.txt",
        "model/ErrorRates_R1.rds",
         "output/seqtab.tsv",
         "figures/Lengths/Sequence_Length_distribution_abundance.pdf",
         "taxonomy/rep_seq.fasta",
         'stats/Nreads.tsv',
         expand("taxonomy/{ref}.tsv", ref=get_taxonomy_names())

rule all_taxonomy:
    input:
        expand("taxonomy/{ref}_gg.tsv", ref=get_taxonomy_names()),
        expand("taxonomy/{ref}.tsv", ref=get_taxonomy_names()),

rule all_tree:
    input:
        "taxonomy/otu_tree.nwk",


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
