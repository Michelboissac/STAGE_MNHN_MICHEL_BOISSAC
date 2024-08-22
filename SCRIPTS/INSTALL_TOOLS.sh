                #INSTALLATION DES OUTILS

#creation environnement conda sur le cluster
yes|conda create -n michel_stage

#SRA TOOLS (fastq-dump split)  2.8.0
yes|conda install bioconda::sra-tools

#TRIMMOMATIC Trimmomatic 0.39 : 
yes|conda install bioconda::trimmomatic

#FASTQC FastQC v0.11.2 :
yes|conda install bioconda/label/broken::fastqc

#MultiQC v1.21
pip install multiqc

#TRINITY date.2011_11_26 
yes|conda install bioconda::trinity 
yes|conda install -c bioconda jellyfish
yes|conda install bioconda::bowtie

#TRINITY 2.11.0
module load biology
module load samtools
module load jellyfish
module load bowtie2
module load userspace/tr17.10
module load java-JRE-OpenJDK
module load salmon
module load python/3.6.3
module load trinityRNASeq/2.11.0

#RNA-Bloom v2.0.1
conda install -c bioconda rnabloom

#BUSCO 5.2.2
module load python/conda
source activate busco

#TRANSDECODERS   TransDecoder.LongOrfs 5.5.0
conda install bioconda::transdecoder
curl -L https://cpanmin.us | perl - App::cpanminus
cpanm install DB_File
cpanm install URI::Escape

#ORTHOFINDER OrthoFinder version 2.5.5 Copyright (C) 2014 David Emms
conda install bioconda::orthofinder

#PHYLOPYTHO python https://github.com/dunnlab/phylopytho ; Version: 1.0.1 ;
conda create -n phylopytho -c conda-forge -c bioconda dendropy pytest
conda activate phylopytho
pip install git+https://github.com/dunnlab/phylopytho.git

#PARGENES  Version 3, 29 June 2007
git clone --recursive https://github.com/BenoitMorel/ParGenes.git
./install.sh

#MAFFT v7.453 (2019/Nov/8)
conda install bioconda::mafft

#GBLOCKS 0.91b                     
conda install bioconda::gblocks

#MINIMAP2 ; alignement reads nanopore sur genomes pour verif identification
conda install bioconda::minima

#pysam 0.16.0.1 : statistiques cigar %mismatch alignement
pip3.8 install pysam
import pysam 

#samtools flagstats 1.10 ; %GAP alignement















"
