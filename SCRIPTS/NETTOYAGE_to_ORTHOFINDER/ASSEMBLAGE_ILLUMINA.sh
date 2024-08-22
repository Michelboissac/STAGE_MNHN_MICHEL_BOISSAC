#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=trinity

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#SBATCH --array=1-0


#repertoire_travail=$1
#liste_nom_base=$2

repertoire_travail=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/
liste_nom_base=" "

##############################################################################
#commande tableau de job , parcours la liste_nom_base

NOM_BASE=$(echo $liste_nom_base | gawk -v INDICE=$SLURM_ARRAY_TASK_ID 'BEGIN {FS=" ";} {print $INDICE;}')

#############################################################################
function ASSEMBLAGE(){
    #TRINITY
    module purge
    module load biology
    module load samtools
    module load jellyfish
    module load bowtie2
    module load userspace/tr17.10
    module load java-JRE-OpenJDK
    module load salmon
    module load python/3.6.3
    module load trinityRNASeq/2.11.0

    DOSSIER_INPUT=$1
    DOSSIER_OUTPUT=$2
    mkdir ${DOSSIER_OUTPUT}
    NOM_BASE=$3
    READS1=${DOSSIER_INPUT}${NOM_BASE}_1P.fastq
    READS2=${DOSSIER_INPUT}${NOM_BASE}_2P.fastq
    Trinity --seqType fq --left ${READS1} --right ${READS2} --CPU 28 --max_memory 200G --output ${DOSSIER_OUTPUT}trinity${NOM_BASE}
    cp ${DOSSIER_OUTPUT}trinity${NOM_BASE}/Trinity.fasta ${DOSSIER_OUTPUT}${NOM_BASE}.fasta

    module purge
}
DOSSIER_INPUT=${repertoire_travail}NETTOYAGE/
DOSSIER_OUTPUT=${repertoire_travail}ASSEMBLAGE/
ASSEMBLAGE ${DOSSIER_INPUT} ${DOSSIER_OUTPUT} ${NOM_BASE}
