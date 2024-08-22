#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=NETTOYAGE_ILLUMINA

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#SBATCH --array=1-0



liste_nom_base=""

##############################################################################
#commande tableau de job , parcours la liste_nom_base
NOM_BASE=$(echo $liste_nom_base | gawk -v INDICE=$SLURM_ARRAY_TASK_ID 'BEGIN {FS=" ";} {print $INDICE;}')

###############################################################################

function NETTOYAGE(){
    #module purge
    #module load userspace/tr17.10
    #module load python/conda
    module purge
    module load biology
    module load userspace/tr17.10
    module load java-JRE-OpenJDK
    module load trimmomatic/0.39

    DOSSIER_INPUT=$1
    DOSSIER_OUTPUT=$2
    mkdir ${DOSSIER_OUTPUT}
    NOM_BASE=$3

    READS1=${DOSSIER_INPUT}${NOM_BASE}*1*            #${DOSSIER_INPUT}${NOM_BASE}_1.fastq
    READS2=${DOSSIER_INPUT}${NOM_BASE}*2*
    #trimmomatic PE -threads 8 ${READS1} ${READS2} -baseout ${DOSSIER_OUTPUT}${NOM_BASE}.fastq HEADCROP:15 LEADING:28 TRAILING:28 MINLEN:75
    java -jar $TRIM_HOME/trimmomatic.jar PE -threads 8 ${READS1} ${READS2} -baseout ${DOSSIER_OUTPUT}${NOM_BASE}.fastq HEADCROP:15 LEADING:28 TRAILING:28 MINLEN:75
    module purge
}

DOSSIER_INPUT=
DOSSIER_OUTPUT=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/NETTOYAGE/




NETTOYAGE ${DOSSIER_INPUT} ${DOSSIER_OUTPUT} ${NOM_BASE}

mkdir ${DOSSIER_OUTPUT}NETTOYAGE_U
mv ${DOSSIER_OUTPUT}*U.fastq ${DOSSIER_OUTPUT}NETTOYAGE_U/



##########################################################################

