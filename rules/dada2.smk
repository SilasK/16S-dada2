# An example collection of Snakemake rules imported in the main Snakefile.


rule plotQualityProfile:
    input:
        lambda wc: SampleTable[wc.direction].values
    output:
        expand("figures/Quality_profiles/{{direction}}/{sample}_{{direction}}.pdf",sample=SAMPLES)
    conda:
        "../envs/dada2.yaml"
    script:
        "../scripts/dada2/plotQualityProfile.R"




rule filter:
    input:
        R1= SampleTable.R1.values,
        R2= SampleTable.R2.values
    output:
        R1= expand("filtered/{sample}_R1.fastq.gz",sample=SAMPLES),
        R2 = expand("filtered/{sample}_R2.fastq.gz",sample=SAMPLES),
        nreads= temp("stats/Nreads_filtered.txt")
    params:
        samples=SAMPLES
    threads:
        config['threads']
    conda:
        "../envs/dada2.yaml"
    log:
        "logs/dada2/filter.txt"
    script:
        "../scripts/dada2/filter.R"


rule learnErrorRates:
    input:
        R1= rules.filter.output.R1,
        R2= rules.filter.output.R2
    output:
        errR1= "model/ErrorRates_R1.rds",
        errR2 = "model/ErrorRates_R2.rds",
        plotErr1="figures/ErrorRates_R1.pdf",
        plotErr2="figures/ErrorRates_R2.pdf"
    threads:
        config['threads']
    conda:
        "../envs/dada2.yaml"
    log:
        "logs/dada2/learnErrorRates.txt"
    script:
        "../scripts/dada2/learnErrorRates.R"


rule dereplicate:
    input:
        R1= rules.filter.output.R1,
        R2= rules.filter.output.R2,
        errR1= rules.learnErrorRates.output.errR1,
        errR2= rules.learnErrorRates.output.errR2
    output:
        seqtab= temp("output/seqtab_with_chimeras.rds"),
        nreads= temp("stats/Nreads_dereplicated.txt")
    params:
        samples=SAMPLES
    threads:
        config['threads']
    conda:
        "../envs/dada2.yaml"
    log:
        "logs/dada2/dereplicate.txt"
    script:
        "../scripts/dada2/dereplicate.R"

rule removeChimeras:
    input:
        seqtab= rules.dereplicate.output.seqtab
    output:
        rds= "output/seqtab_nochimeras.rds",
        nreads=temp("stats/Nreads_chimera_removed.txt")
    threads:
        config['threads']
    conda:
        "../envs/dada2.yaml"
    log:
        "logs/dada2/removeChimeras.txt"
    script:
        "../scripts/dada2/removeChimeras.R"


rule filterLength:
    input:
        seqtab= rules.removeChimeras.output.rds
    output:
        plot_seqlength= "figures/Lengths/Sequence_Length_distribution.pdf",
        plot_seqabundance= "figures/Lengths/Sequence_Length_distribution_abundance.pdf",
        rds= "output/seqtab.rds",
        tsv=  "output/seqtab.tsv",
    threads:
        1
    conda:
        "../envs/dada2.yaml"
    log:
        "logs/dada2/filterLength.txt"
    script:
        "../scripts/dada2/filterLength.R"



rule IDtaxa:
    input:
        seqtab= "output/seqtab.rds",
        ref= lambda wc: config['idtaxa_dbs'][wc.ref]
    output:
        taxonomy= "taxonomy/{ref}.tsv",
    threads:
        config['threads']
    log:
        "logs/dada2/IDtaxa_{ref}.txt"
    script:
        "../scripts/dada2/IDtaxa.R"

localrules: get_ggtaxonomy

rule get_ggtaxonomy:
    input:
        rules.IDtaxa.output
    output:
        taxonomy= "taxonomy/{ref}_gg.tsv",
    threads:
        1
    log:
        "logs/dada2/get_ggtaxonomy_{ref}.txt"
    run:

        import pandas as pd

        tax = pd.read_csv(input[0],sep='\t',index_col=0)

        out= tax.dropna(how='all',axis=1).dropna(how='all',axis=0)

        out= out.apply(lambda col: col.name[0]+'_'+col.dropna())
        out= out.apply(lambda row: ';'.join(row.dropna()),axis=1)
        out.name='Taxonomy'


        out.to_csv(output[0],sep='\t',header=True)







rule get_rep_seq:
    input:
        "output/seqtab.tsv",
    output:
        "taxonomy/rep_seq.fasta"
    run:
        with open(input[0]) as infile:
            seqs = infile.readline().strip().replace('"','').split()
        with open(output[0],'w') as outfile:
            for s in seqs:
                outfile.write(f">{s}\n{s}\n")
