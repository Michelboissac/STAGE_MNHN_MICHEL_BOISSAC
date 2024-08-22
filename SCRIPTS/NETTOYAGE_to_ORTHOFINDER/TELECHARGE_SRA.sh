#!/bin/bash

#repertoire_travail=$1
#liste_nom_base=$2

repertoire_travail=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/
liste_nom_base=""


##############################################################################
function telechargement(){
    DOSSIER_OUTPUT=$1
    mkdir ${DOSSIER_OUTPUT}
    NOM_BASE=$2
    sample=${DOSSIER_OUTPUT}${NOM_BASE}.sra
    wget https://sra-pub-run-odp.s3.amazonaws.com/sra/${NOM_BASE}/${NOM_BASE} -O ${sample}
}	

#TELECHARGEMENT 
for NOM_BASE in ${liste_nom_base}
do
    DOSSIER_OUTPUT=${repertoire_travail}SRA/
    telechargement ${DOSSIER_OUTPUT} ${NOM_BASE}   #&    : permet de paralleliser les telechargements, mais peut saturer le noeud principal, NE MARCHE PAS, CAR PASSE DIRECTEMENT A SRA_to_FASTQ
done

###############################################################################


