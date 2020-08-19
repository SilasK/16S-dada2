# Snakemake workflow: Dada2

[![Snakemake](https://img.shields.io/badge/snakemake-≥5-brightgreen.svg)](https://snakemake.bitbucket.io)
[![dada2](https://img.shields.io/badge/dada2-v1.14-yellow.svg)](https://snakemake.bitbucket.io)
[![Build Status](https://travis-ci.org/snakemake-workflows/amplicon-seq-dada2.svg?branch=master)](https://travis-ci.org/snakemake-workflows/amplicon-seq-dada2)

This is the template for a new Snakemake workflow. Replace this text with a comprehensive description covering the purpose and domain.
Insert your code into the respective folders, i.e. `scripts`, `rules`, and `envs`. Define the entry point of the workflow in the `Snakefile` and the main configuration in the `config.yaml` file.

## Authors

* Silas Kieser (@silask)

## Usage

### Step 1: Install workflow

If you simply want to use this workflow, download and extract the [latest release](https://github.com/snakemake-workflows/amplicon-seq-dada2/releases).
If you intend to modify and further develop this workflow, fork this repository. Please consider providing any generally applicable modifications via a pull request.

In any case, if you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository and, if available, its DOI (see above).

#### Requirements:

The pipeline has some dependencies which an be installed with conda:

```
conda env create -n dada2_env --file dependencies.yml

```

#### Databases:

For taxonomic annotation I use IDtaxa. A database e.g. the one from GTDB should be downloaded from [here](http://www2.decipher.codes/Downloads.html) and the path added to the config file.

### Step 2: Configure workflow

Configure the workflow according to your needs via editing the file `config.yaml`.

Create a sample table like [this one](.test/samples.tsv). You can use the script `prepare_sample_table.py` for it. The scripts searches for fastq(.gz) files inside a folder (structure). If you have paired end files they should have R1/R2 somewhere in the filename. If might be a good idea to simplify sample names.

```
prepare_sample_table.py path/to/fasqfiles
```


### Step 3: Execute workflow

Test your configuration by performing a dry-run via

    snakemake -n

Execute the workflow locally via

    snakemake --cores $N

using `$N` cores or run it in a cluster environment via

    snakemake --cluster qsub --jobs 100

or

    snakemake --drmaa --jobs 100

See the [Snakemake documentation](https://snakemake.readthedocs.io) for further details.

## Testing

You can test the pipeline with the script `test.py`.
