#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=QUALITE

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#repertoire_travail=$1


repertoire_travail=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/

function QUALITE(){
     DOSSIER_INPUT=$1
     DOSSIER_OUTPUT=$2
     NOM_BASE=$3
     

     mkdir ${DOSSIER_OUTPUT}
     fastqc ${DOSSIER_INPUT}${NOM_BASE}* -o ${DOSSIER_OUTPUT}
}


DOSSIER_INPUT=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/FASTQ/   #${repertoire_travail}FASTQ/
DOSSIER_OUTPUT=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/QUALITE_sra_non_nettoyee/  #${repertoire_travail}QUALITE_data_non_nettoyee/
liste_nom_base=""
for NOM_BASE in $liste_nom_base
do
    QUALITE ${DOSSIER_INPUT} ${DOSSIER_OUTPUT} ${NOM_BASE}
done


