#ce script permet de separer les 400 000 orthogroups en 100 listes de 4000 orthogroups, pour accellerer l'etape' de pruning de paralogs avec phylopytho


function division_modulo_100_liste_1_2_3_4_to_1_101_201(){
    liste=$1
    dossier_output=$2


    # creer les fichiers textes avec les 100 listes d'orthogroup'
    mkdir -p ${dossier_output}LISTES_ORTHOGROUPS/
    for ((compteur = 1; compteur <= 100; compteur++)); 
    do
        touch "${dossier_output}LISTES_ORTHOGROUPS/liste_${compteur}.txt"
    done


    # remplie les 100 listes avec modulo 100
    compteur=1
    for nom_base in $liste;
    do 
        echo $nom_base >> ${dossier_output}LISTES_ORTHOGROUPS/liste_${compteur}.txt
        if [[ $compteur -gt 99 ]]; then
            compteur=0
        fi
        compteur=$(( $compteur + 1 ))
    done
}



dossier_output=/mnt/beegfs/pmartinezsoares/Transcriptomes_bruts/TRANSCRIPTOMES_ALIEN/ORTHOLOGS/

dossier_input=/mnt/beegfs/pmartinezsoares/Transcriptomes_bruts/TRANSCRIPTOMES_ALIEN/CDS/OrthoFinder/Results_Jun30/Resolved_Gene_Trees/

dossier_sequence=/mnt/beegfs/pmartinezsoares/Transcriptomes_bruts/TRANSCRIPTOMES_ALIEN/CDS/OrthoFinder/Results_Jun30/Orthogroup_Sequences/

liste=$(ls ${dossier_input})



division_modulo_100_liste_1_2_3_4_to_1_101_201 "${liste}" ${dossier_output}


