

rule build_tree:
    input:
        rds= "output/seqtab.rds",
    output:
        alignment= "taxonomy/alignment.fasta",
        tree= "taxonomy/otu_tree.nwk",
    threads:
        1
    log:
        "logs/taxonomy/alignment.txt"
    script:
        "../scripts/dada2/alignment.R"
