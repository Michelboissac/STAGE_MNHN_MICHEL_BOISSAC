#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=SRA_TO_FASTQ

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#SBATCH --array=1-0


#repertoire_travail=$1
#liste_nom_base=$2

repertoire_travail=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/
liste_nom_base=""

##############################################################################
#commande tableau de job , parcours la liste_nom_base

NOM_BASE=$(echo $liste_nom_base | gawk -v INDICE=$SLURM_ARRAY_TASK_ID 'BEGIN {FS=" ";} {print $INDICE;}')


function SRAtoFASTQ(){
    DOSSIER_INPUT=$1
    DOSSIER_OUTPUT=$2
    mkdir ${DOSSIER_OUTPUT}
    NOM_BASE=$3
    fastq-dump --split-files ${DOSSIER_INPUT}${NOM_BASE}.sra --outdir ${DOSSIER_OUTPUT}
}

DOSSIER_INPUT=${repertoire_travail}SRA/
DOSSIER_OUTPUT=${repertoire_travail}FASTQ/
SRAtoFASTQ ${DOSSIER_INPUT} ${DOSSIER_OUTPUT} ${NOM_BASE}


