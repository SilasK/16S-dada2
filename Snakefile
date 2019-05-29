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


rule all_profile:
    input: expand("figures/Quality_profiles/{direction}/{sample}_{direction}.pdf",sample=SAMPLES,direction=['R1','R2'])
        #"quality_control/readlength.tsv"

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







rule bbmap_qc:
    input:
        unpack( lambda wc: dict(SampleTable.loc[wc.sample]))
    output:
        expand("quality_control/{{sample}}/{file}",
               file=['base_hist.txt','quality_by_pos.txt','readlength.txt','gc_hist.txt','boxplot_quality.txt'])
    params:
        inputs = lambda wc,input: f"in={input.R1} in2={input.R2}" if PAIRED_END else f"in={input.R1}",
        verifypaired = "t" if PAIRED_END else "f",
        subfolder = lambda wc,output: os.path.dirname(output[0])
    log:
        "logs/QC/{sample}.log"
    conda:
        "%s/required_packages.yaml" % CONDAENV
    threads:
        config["threads"]
    resources:
        mem = config["java_mem"],
        java_mem = int(config["java_mem"] * JAVA_MEM_FRACTION)
    shell:
        """
        mkdir -p {params.subfolder}
        reformat.sh {params.inputs} \
            iupacToN=t \
            touppercase=t \
            qout=33 \
            overwrite=true \
            verifypaired={params.verifypaired} \
            \
            bhist={params.subfolder}/base_hist.txt \
            qhist={params.subfolder}/quality_by_pos.txt \
            lhist={params.subfolder}/readlength.txt \
            gchist={params.subfolder}/gc_hist.txt \
            gcbins=auto \
            bqhist={params.subfolder}/boxplot_quality.txt \
            \
            threads={threads} \
            -Xmx{resources.java_mem}G 2> {log}
        """

rule combine_read_length:
    input:
        expand("quality_control/{sample}/readlength.txt",sample=SAMPLES)
    output:
        "quality_control/readlength.tsv"
    run:
        RL = pd.DataFrame()
        for i,s in enumerate(SAMPLES):
            RL[s]= pd.read_table(input[i],index_col=0,squeeze=True)
        RL.T.to_csv(output[0],sep='\t')

include: "rules/dada2.smk"
include: "rules/taxonomy.smk"
