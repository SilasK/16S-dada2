#! /usr/bin/env python

import os
from snakemake.shell import shell

data_path= 'example_data'

if not os.path.exists(data_path):

    shell("wget https://mothur.s3.us-east-2.amazonaws.com/wiki/miseqsopdata.zip")
    shell("unzip  miseqsopdata.zip")

sample_table='samples.tsv'

if os.path.exists(sample_table):  os.remove(sample_table)


# Create sample table

shell('prepare_sample_table.py miseqsopdata/MiSeq_SOP')

# simplify names in sample table (optional)

import pandas as pd
D= pd.read_table(sample_table,sep='\t', index_col=0)
D.index = D.index.map(lambda s: s.split('-')[0])
assert D.index.is_unique
D.to_csv(sample_table,sep='\t')


# run the pipeline

shell("snakemake --configfile config.yaml -j1 -d .test")
