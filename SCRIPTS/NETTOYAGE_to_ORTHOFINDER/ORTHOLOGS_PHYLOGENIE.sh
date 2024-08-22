#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=ORTHOLOGS_PHYLOGENIE

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#repertoire_travail=$1


repertoire_travail=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/

orthofinder -f CDS


