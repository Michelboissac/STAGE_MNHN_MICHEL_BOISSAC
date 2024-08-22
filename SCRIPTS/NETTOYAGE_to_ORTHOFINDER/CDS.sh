#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=CDS

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#SBATCH --array=1-0


#repertoire_travail=$1
#liste_nom_base=$2

repertoire_travail=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/WORFLOW/
liste_nom_base="  "
##############################################################################
#commande tableau de job , parcours la liste_nom_base
NOM_BASE=$(echo $liste_nom_base | gawk -v INDICE=$SLURM_ARRAY_TASK_ID 'BEGIN {FS=" ";} {print $INDICE;}')

function recherche_CDS(){
    NOM_BASE=$1
    repertoire=$2
    repertoire_output=$3
   
    #
    output=${repertoire_output}${NOM_BASE}.pep
    TRANSCRIPTOME=${repertoire}ASSEMBLAGE/*${NOM_BASE}*.fasta

    #
    TransDecoder.LongOrfs -t ${TRANSCRIPTOME} 

    #
    repertoire_output_transdecoder=${repertoire}${NOM_BASE}.fasta.transdecoder_dir/
    output_transdecoder=${repertoire_output_transdecoder}longest_orfs.pep
 
    #
    mv ${output_transdecoder} ${output}
    rm -r ${repertoire_output_transdecoder}
    rm -r ${repertoire}${NOM_BASE}.fasta.transdecoder_dir.__checkpoints_longorfs/
}

repertoire=${repertoire_travail}
repertoire_output=${repertoire_travail}CDS/

#
mkdir ${repertoire_output}

recherche_CDS ${NOM_BASE} ${repertoire} ${repertoire_output}





