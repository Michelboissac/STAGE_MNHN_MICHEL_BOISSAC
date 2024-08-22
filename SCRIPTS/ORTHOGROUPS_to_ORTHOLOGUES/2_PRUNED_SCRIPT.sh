#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=orthologs

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#SBATCH --array=1-100


#ce script prend en entree un arbe de gene resolu (avec les noms d espece )
#puis realise le masking monophyly et le pruning paralog avec la librairie phylopytho de python https://github.com/dunnlab/phylopytho
#on creer ensuite un arbre par cluster d orthologs (=nbr de paralogs ds orthogroup)

#installation phylopytho
#conda create -n phylopytho -c conda-forge -c bioconda dendropy pytest
#conda activate phylopytho
#pip install git+https://github.com/dunnlab/phylopytho.git



#PARGENES
#$ git clone --recursive https://github.com/BenoitMorel/ParGenes.git
#./install.sh

# conda install bioconda::mafft
# conda install bioconda::gblocks

function tree_copie_name_a(){
    
    tree=$1
    dossier_input=$2
    dossier_output=$3
    echo "copie ${tree} de input vers output, et remplace _TRINITY_ et _rb_ par des @ pour avoir : TAXON@ID"
    cp ${dossier_input}${tree}.txt ${dossier_output}${tree}/${tree}.a.txt
    sed -i 's/_TRINITY_/@/g' ${dossier_output}${tree}/${tree}.a.txt
    sed -i 's/_rb_/@/g' ${dossier_output}${tree}/${tree}.a.txt

}

function pruning_tree(){

    tree=$1
    dossier_output=$2
    echo "realise le monophyly masking et le paralogs pruning sur ${tree} "
    treeprune ${dossier_output}${tree}/${tree}.a.txt ${dossier_output}${tree}/${tree}.arbre_elague.txt
    mv ${dossier_output}${tree}/${tree}.a.txt ${dossier_output}${tree}/${tree}.arbre_non_elague.txt
}


function cluster_orthologs(){
    tree=$1
    dossier_output=$2
    echo "creer un arbre par cluster d ortholog (=nombre de paralogs dans l orthogroup)"
    #creer de nouveaux fichiers avec les arbres de lcusters d orthologs du fichiers pruned.txt separé par [&R]
    cd  ${dossier_output}${tree}/

    csplit ${dossier_output}${tree}/${tree}.arbre_elague.txt '/[&R]/' '{*}'
    cd ${dossier_output}
    mv ${dossier_output}xx* ${dossier_output}${tree}/
    rm ${dossier_output}${tree}/xx00   #vide
    mkdir ${dossier_output}${tree}/${tree}_cluster_ortholog/

    
    for fichier in ${dossier_output}${tree}/*; do
        echo $fichier
        sed -i 's/\[&R\]//g' $fichier       #enleve [&R]
        sed -i 's/^[[:space:]]*//' $fichier     #enleve les espaces 



        num_cluster=$(echo "$fichier" | sed 's/.*xx//')
        echo $num_cluster
    

        nouveau=${dossier_output}${tree}/${tree}_cluster_ortholog/${tree}cluster_ortholog${num_cluster}.txt

        mv $fichier $nouveau
    done
}

function recherche_sequences_cluster_ortholog(){
    orthogroup=$1
    tree=$2
    dossier_output=$3
    nom_output=$4

    ##copie les sequences de l orthogroup ou du msa d orthofinder en mettant sur une meme ligne >TAXON@ID\tSEQUENCE
    cat ${orthogroup} |gawk 'BEGIN {FS="";sequence=""}{ 
if($1==">"){print sequence; sequence=$0"\t";}
else{sequence=sprintf("%s%s",sequence,$0);}
 }
END{print sequence;}'> ${dossier_output}${tree}/${tree}.${nom_output}.orthogroup
    sed -i 's/_TRINITY_/@/g' ${dossier_output}${tree}/${tree}.${nom_output}.orthogroup
    sed -i 's/_rb_/@/g' ${dossier_output}${tree}/${tree}.${nom_output}.orthogroup

    #prend la liste de tout les clusters d'orthologs dans le repertoire creer par la fonction 'cluster_orthologs'

    trees=${dossier_output}${tree}/${tree}_cluster_ortholog/
    sequences=${dossier_output}${tree}/${tree}_${nom_output}/

    mkdir $sequences
   
    for tree_cluster_ortholog in $(ls $trees);
    do
       #creer un fichier txt avec tous les TAXON@ID de l arbre de cluster d ortholog
      cat ${trees}$tree_cluster_ortholog |gawk 'BEGIN {FS="";}{ gsub(/\(/, "");gsub(/\)/, ""); gsub(/,/, "\n"); print;}
      ' > ${sequences}${tree_cluster_ortholog}.temp1           #enleve toutes les parentheses de larbre et remplace les , par des retours lignes

     cat ${sequences}${tree_cluster_ortholog}.temp1 |gawk 'BEGIN {FS=":";}{ print $1}
     ' > ${sequences}${tree_cluster_ortholog}.temp2                 #prend TAXON@ID dans la ligne TAXON@ID:valeur


    if [ -f "${sequences}${tree_cluster_ortholog}.${nom_output}" ]; then
        rm "${sequences}${tree_cluster_ortholog}.${nom_output}"
    fi
        for seq in $(cat ${sequences}${tree_cluster_ortholog}.temp2);
        do
            grep ">$seq" ${dossier_output}${tree}/${tree}.${nom_output}.orthogroup >> ${sequences}${tree_cluster_ortholog}.${nom_output}
            sed -i 's/\t/\n/g' ${sequences}${tree_cluster_ortholog}.${nom_output}
        done


        rm ${sequences}${tree_cluster_ortholog}.temp1
        rm ${sequences}${tree_cluster_ortholog}.temp2

       nbr_taxons=$(grep -c ">" ${sequences}${tree_cluster_ortholog}.${nom_output})
       mv ${sequences}${tree_cluster_ortholog}.${nom_output} ${sequences}${tree_cluster_ortholog}.${nbr_taxons}.${nom_output}
    done    

    rm ${dossier_output}${tree}/${tree}.${nom_output}.orthogroup
}



function copie_sequences_nbr_taxons(){
    dossier_output=$1
    tree=$2

   for seq in $( ls ${dossier_output}${tree}/${tree}_seq/ ) ;
   do
    nbr=${seq#*txt.}
    nbr=${nbr%.seq}
    echo $nbr
    cp ${dossier_output}${tree}/${tree}_seq/$seq ${dossier_output}ORTHOLOGS_TAXONS/$nbr/
   done


}

####################################################################################################################
function main(){   
    nom_base=$1
    dossier_output=$2
    dossier_sequence=$3
    dossier_msa=$4
    tree=${nom_base}_tree
    mkdir ${dossier_output}${tree}

    orthogroup=${dossier_sequence}${nom_base}.fa
    orthofinder_msa=${dossier_msa}${nom_base}.fa

    tree_copie_name_a ${tree} ${dossier_input} ${dossier_output}
    pruning_tree ${tree} ${dossier_output}
    cluster_orthologs ${tree} ${dossier_output}
    recherche_sequences_cluster_ortholog ${orthogroup} ${tree} ${dossier_output} seq
    copie_sequences_nbr_taxons ${dossier_output} ${tree}


}
###################################################################



function creation_repertoire_vide_orthologs_taxons(){
    dossier_output=$1
    #creation des repertoires 1 à 66 (nombre de taxon dans le cluster .')
    for ((i = 1; i <= 66; i++)); do
    mkdir -p "${dossier_output}ORTHOLOGS_TAXONS/$i"
    done
}


####################################################################################################################
dossier_output=/mnt/beegfs/pmartinezsoares/Transcriptomes_bruts/TRANSCRIPTOMES_ALIEN/ORTHOLOGS/

dossier_input=/mnt/beegfs/pmartinezsoares/Transcriptomes_bruts/TRANSCRIPTOMES_ALIEN/CDS/OrthoFinder/Results_Jun30/Resolved_Gene_Trees/

dossier_sequence=/mnt/beegfs/pmartinezsoares/Transcriptomes_bruts/TRANSCRIPTOMES_ALIEN/CDS/OrthoFinder/Results_Jun30/Orthogroup_Sequences/

#pargenes=/home/mboissac/Bureau/crinoide_stage/stage_mnhn_crinoide/phylopytho/ParGenes/pargenes/pargenes.py


#dossier_msa=
####################################################################################################################

#dossier_sequence=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/DATAS/ORTHOFINDER/Results_Jun30/Orthogroup_Sequences/ #MultipleSequenceAlignments/
#dossier_input=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/DATAS/ORTHOFINDER/Results_Jun30/Resolved_Gene_Trees/
#dossier_output=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/DATAS/orthologs/ #

#dossier_output=/home/mboissac/Bureau/crinoide_stage/stage_mnhn_crinoide/phylopytho/
#dossier_msa=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/DATAS/ORTHOFINDER/Results_Jun30/MultipleSequenceAlignments/
#pargenes=/home/mboissac/Bureau/crinoide_stage/stage_mnhn_crinoide/phylopytho/ParGenes/pargenes/pargenes.py
####################################################################################################################


liste=$(ls ${dossier_input})



creation_repertoire_vide_orthologs_taxons ${dossier_output}


repertoire_listeS=${dossier_output}LISTES_ORTHOGROUPS/
listeS=$(ls $repertoire_listeS)



liste=$(echo $listeS|gawk -v INDICE=$SLURM_ARRAY_TASK_ID 'BEGIN {FS=" ";}{print $INDICE;}')



#pour chaque orthogroup d une liste
parallel=0
for nom_base in $(cat ${repertoire_listeS}${liste}) ;
do 
    parallel=$(( $parallel + 1 ))
    nom_base=$(echo "$nom_base" | sed 's/_.*//')
    echo ":::::::::::::::::::$nom_base::::::::::::::::::::::::::::::::::"

    echo $parallel
    if [[ $parallel -gt 100 ]]; then     #lorsque il y a 100 taches paralleles,
        main ${nom_base} ${dossier_output} ${dossier_sequence} ${dossier_msa}    
        parallel=0

    else
        echo $parallel
        main ${nom_base} ${dossier_output} ${dossier_sequence} ${dossier_msa} &    #permcet de paralleliser 100 taches d affilee
    fi
done










