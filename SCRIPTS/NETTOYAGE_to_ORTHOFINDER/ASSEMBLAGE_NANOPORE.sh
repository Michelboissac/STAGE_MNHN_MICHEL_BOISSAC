#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=rna_bloom

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#SBATCH --array=1-0


function assemblage(){
    nom_base=$1
    repertoire_output=$2
    repertoire_input=$3

    read=$repertoire_input$nom_base
    assemblage_out=$repertoire_output$nom_base
    rnabloom -long $read -stranded -t 28 -outdir $assemblage_out
    cp ${assemblage_out}/rnabloom.transcripts.fa ${assemblage_out}.fasta
}



DOSSIER_INPUT=
DOSSIER_OUTPUT=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/ASSEMBLAGE/
liste_nom_base=""
read=$(echo $liste_nom_base | gawk -v INDICE=$SLURM_ARRAY_TASK_ID 'BEGIN {FS=" ";} {print $INDICE;}')

#


assemblage $read $DOSSIER_OUTPUT $DOSSIER_INPUT

