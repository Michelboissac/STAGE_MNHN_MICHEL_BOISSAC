#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=tirage1

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#SBATCH --array=1-53


RANDOM=20102000


REPERTOIRE_RESULTATS=20240729RESULTATS_tirages
repertoire_A=A_tsv_mis_en_forme
repertoire_B=B_tsv_paste
repertoire_C=C_tirage_aleatoire
repertoire_D=D_fastq_aleatoire
repertoire_pile=pile
repertoire_temp=temp
extension=P.fq

#
#SRA1.fastq--->SRA1.tsv---|                           --->1SRA1.fastq-------|              
#    (A)                (B)--->SRA.tsv--->1SRA.tsv--->(D)                 (E)  --->TRINITY
#SRA2.fastq--->SRA2.tsv---|       (C)|--              --->1SRA1.fastq-------|             
#                                    |--    
#                                    |--->2SRA.tsv 
#                                    |--->3... etc    
#
#

function temps_calcul(){
    debut=$1
    fin=$2
    etape=$3
    output=${REPERTOIRE_RESULTATS}/temps.txt

    jour_debut=$(echo $debut|gawk 'BEGIN {FS=":";}{print $1;}')
    heure_debut=$(echo $debut|gawk 'BEGIN {FS=":";}{print $2;}')
    minute_debut=$(echo $debut|gawk 'BEGIN {FS=":";}{print $3;}')
    seconde_debut=$(echo $debut|gawk 'BEGIN {FS=":";}{print $4;}')

    jour_fin=$(echo $fin|gawk 'BEGIN {FS=":";}{print $1;}')
    heure_fin=$(echo $fin|gawk 'BEGIN {FS=":";}{print $2;}')
    minute_fin=$(echo $fin|gawk 'BEGIN {FS=":";}{print $3;}')
    seconde_fin=$(echo $fin|gawk 'BEGIN {FS=":";}{print $4;}')


    TEMPS=$(echo Temps : $((jour_fin-jour_debut)) jours , $((heure_fin-heure_debut)) heures , $((minute_fin-minute_debut)) minutes , $((seconde_fin-seconde_debut)) secondes)
    
    echo " ">> $output
    echo $etape >> $output
    echo "  "$TEMPS >> $output
    echo "      debut : "$debut >> $output
    echo "      fin   : "$fin >> $output
    
}


# temp    #fichier temp dans lequel les fichiers intermediaires creer pour realiser les tirage aleatoire seront stockés.
function creation_repertoire(){

    if [ ! -d ${REPERTOIRE_RESULTATS} ]; then
        mkdir ${REPERTOIRE_RESULTATS}
    else
        echo ${REPERTOIRE_RESULTATS} "existe"
    fi


    for repertoire in $repertoire_A $repertoire_B $repertoire_C $repertoire_D $repertoire_temp $repertoire_pile
    do
        if [ ! -d ${REPERTOIRE_RESULTATS}/$repertoire ]; then
            mkdir ${REPERTOIRE_RESULTATS}/$repertoire
        else
            echo $repertoire "existe"
        fi
    done


}


function supprime_repertoire(){

    for repertoire in $repertoire_A $repertoire_B $repertoire_C $repertoire_temp $repertoire_pile
    do
        rm -r ${REPERTOIRE_RESULTATS}/$repertoire
    done

}


#(A) creer les fichiers SRA1.tsv et SRA2.tsv avec les informations de chaque READ sur une meme ligne separé par des tabulations 
function mise_en_forme_reads(){
    debut=$(date +"%e:%H:%M:%S")

    NOM_BASE=$1
    READS_fastq1=${NOM_BASE}_1${extension}
    READS_fastq2=${NOM_BASE}_2${extension}

    
    READS_tsv1=${REPERTOIRE_RESULTATS}/$repertoire_A/${NOM_BASE}_1${extension}.tsv
    READS_tsv2=${REPERTOIRE_RESULTATS}/$repertoire_A/${NOM_BASE}_2${extension}.tsv
    echo ${NOM_BASE} etape A : mise_en_forme_reads


    #zcat $READS_fastq1|head -n 1000|gawk -f fastqtotsv.awk > $READS_tsv1                  #changer pour avoir HEAD seulement !!!!!!!!!!!!!!!!!!
    #zcat $READS_fastq2|head -n 1000|gawk -f fastqtotsv.awk > $READS_tsv2                  #changer pour avoir HEAD seulement
    cat $READS_fastq1|gawk -f fastqtotsv.awk > $READS_tsv1                                #changer pour avoir HEAD seulement
    cat $READS_fastq2|gawk -f fastqtotsv.awk > $READS_tsv2                                #zcat et cat aussi   ;;; changer pour avoir HEAD seulement

    fin=$(date +"%e:%H:%M:%S")
    temps_calcul "${debut}" "${fin}" "${NOM_BASE} : etape A :"

}


#(B) creer un fichier SRA.tsv en collant les colonnes de SRA1.tsv et SRA2.tsv
function PASTE_tete_queue(){
    debut=$(date +"%e:%H:%M:%S")


    NOM_BASE=$1
    READS_1=${REPERTOIRE_RESULTATS}/$repertoire_A/${NOM_BASE}_1${extension}.tsv
    READS_2=${REPERTOIRE_RESULTATS}/$repertoire_A/${NOM_BASE}_2${extension}.tsv
    OUT=${REPERTOIRE_RESULTATS}/$repertoire_B/${NOM_BASE}${extension}.tsv
    echo ${NOM_BASE} etape B : PASTE_tete_queue
    paste -d "\t" $READS_1 $READS_2 > $OUT

    
    fin=$(date +"%e:%H:%M:%S")
    temps_calcul "${debut}" "${fin}" "${NOM_BASE} : etape B :"

    rm $READS_1
    rm $READS_2

}





#(C) realise N tirages aleatoire sur les lignes du fichier SRA.tsv, puis creer N fichiers avec ces tirages aleatoires.
function tirages_aleatoire(){
    debut=$(date +"%e:%H:%M:%S")

    NOM_BASE=$1
    nbr_tirages=$2    #plus petit que nbr_reads
    #nom des fichiers intermediaires
    READSSOURCE=${REPERTOIRE_RESULTATS}/$repertoire_B/${NOM_BASE}${extension}.tsv                         #INPUT : fichier .tsv avec la tete et la queue sur chaque ligne
    OUTPUT=${REPERTOIRE_RESULTATS}/$repertoire_C/${nbr_tirages}${NOM_BASE}${extension}.tsv       #OUTPUT : fichier .tsv avec "n" lignes tirées au hasard (avec la tete et la queue)
    
    nbr_reads=$(grep -c '' "$READSSOURCE")  #compte le nombre de ligne du fichier .tsv
    
    #fichiers intermediaires stockés dans le dossier "pile", la pilehasardtrie permet au script awk de piocher les lignes issue du tirage aleatoire dans le fichier .tsv avec la tete et la queue sur la meme ligne.
    pile=${REPERTOIRE_RESULTATS}/$repertoire_pile/${nbr_tirages}${NOM_BASE}pile.txt
    pilehasard=${REPERTOIRE_RESULTATS}/$repertoire_pile/${nbr_tirages}${NOM_BASE}pilehasard.txt
    pilehasardtrie=${REPERTOIRE_RESULTATS}/$repertoire_pile/${nbr_tirages}${NOM_BASE}pilehasard_triee.txt
    
    echo ${NOM_BASE} reads : ${nbr_tirages} etape C : tirages_aleatoire
    echo le fichier contient $nbr_reads lignes le tirage doit etre inferieur
    #creation d'une suite de nombres : 1 2 3 4 5 ....
    seq ${nbr_reads} > ${pile}


    #Tirage aleatoire dans la suite de nombre precedente: 5 10 6 2 1 
    cat ${pile} | sort -R -T ${REPERTOIRE_RESULTATS}/${repertoire_temp}| head -n ${nbr_tirages} > ${pilehasard}

    rm $pile
    #Trie en ordre croissant : 1 2 5 6 10
    cat ${pilehasard} | sort -n -T ${REPERTOIRE_RESULTATS}/${repertoire_temp}> ${pilehasardtrie}
    

    rm ${pilehasard}
    #creation de l'output ' avec les n tirages aleatoire : on obtient des fichies .tsv pour chaque ligne la tete et la queue 
    touch ${OUTPUT}
    cat ${READSSOURCE}|gawk -v pile=${pilehasardtrie} -v output=${OUTPUT} -f selection_tirage_pile.awk
    rm ${pilehasardtrie}
    rm $READSSOURCE
    fin=$(date +"%e:%H:%M:%S")
    temps_calcul "${debut}" "${fin}" "${NOM_BASE} tirage ${nbr_tirages} : etape C :"


   

}




#(D) tsv>fastq
function mise_en_forme_fastq(){
    debut=$(date +"%e:%H:%M:%S")

    NOM_BASE=$1
    N_READS=$2
    INPUT=${REPERTOIRE_RESULTATS}/$repertoire_C/${N_READS}${NOM_BASE}${extension}.tsv
    OUTPUT1=${REPERTOIRE_RESULTATS}/$repertoire_D/${N_READS}${NOM_BASE}${extension}.tsv._1.fastq
    OUTPUT2=${REPERTOIRE_RESULTATS}/$repertoire_D/${N_READS}${NOM_BASE}${extension}.tsv._2.fastq

    echo ${NOM_BASE} reads : ${N_READS} etape D : mise_en_forme_fastq

    cat $INPUT|gawk -v queue=${OUTPUT1} -v tete=${OUTPUT2} -f tsvtofastq.awk  

    
    fin=$(date +"%e:%H:%M:%S")
    temps_calcul "${debut}" "${fin}" "${NOM_BASE} tirage ${N_READS} : etape D :"
    rm $INPUT
}
#(E) execute trinity sur la tete et la queue du fichier de tirage aleatoire.
function trinity(){
    debut=$(date +"%e:%H:%M:%S")
    NOM_BASE=$1
    N_READS=$2
    READS1=${REPERTOIRE_RESULTATS}/$repertoire_D/${N_READS}${NOM_BASE}${extension}.tsv._1.fastq
    READS2=${REPERTOIRE_RESULTATS}/$repertoire_D/${N_READS}${NOM_BASE}${extension}.tsv._2.fastq
    OUTPUT=${REPERTOIRE_RESULTATS}/trinity${N_READS}${NOM_BASE}

    echo ${NOM_BASE} reads : ${N_READS} etape E : trinity

    Trinity --seqType fq --left $READS1 --right $READS2 --CPU 28 --max_memory 50G --output $OUTPUT
 
    
    fin=$(date +"%e:%H:%M:%S")
    temps_calcul "${debut}" "${fin}" "${NOM_BASE} tirage ${N_READS} : etape E :"
    rm $READS1
    rm $READS2
}


#() fonction principale qui execute toute les etapes (A),(B),(C),(D),(E)
function creation_sra_aleatoire(){
    NOM_BASE_SRA=$1


    nbr_lignes=$(grep  -c "@" ${NOM_BASE_SRA}_1P.fq)
    nbr_lignes_1=$(( ${nbr_lignes}/5 ))
    nbr_lignes_2=$(( ${nbr_lignes_1}*2))
    nbr_lignes_3=$(( ${nbr_lignes_1}*3))
    nbr_lignes_4=$(( ${nbr_lignes_1}*4))
    nbr_lignes_5=$(( ${nbr_lignes_1}*5))

    READS_liste="${nbr_lignes_1} ${nbr_lignes_2} ${nbr_lignes_3} ${nbr_lignes_4} ${nbr_lignes_5}" 

    mise_en_forme_reads ${NOM_BASE_SRA}   #(A)
    PASTE_tete_queue ${NOM_BASE_SRA}      #(B)

    for READS in $READS_liste
    do
        tirages_aleatoire ${NOM_BASE_SRA} ${READS}    #(C)
        mise_en_forme_fastq ${NOM_BASE_SRA} ${READS}  #(D)
        trinity ${NOM_BASE_SRA} ${READS}              #(E) 
        
    done


}



creation_repertoire 

#commande tableau de job , parcours la liste_nom_base
liste_nom_base="CR148_FRAS210067601-1a_trim RSIOCR033_trim RSIOCR069_trim CR169_FRAS210067605-1a_trim RSIOCR034_trim RSIOCR070_trim CRP_FRAS210132049-1r_trim RSIOCR045_trim RSIOCR071_trim ROV07_B06_trim RSIOCR051_trim RSIOCR109_trim ROV09_B07_trim RSIOCR052_trim RSIOCR115_trim ROV09_B11_trim RSIOCR053_trim RSIOCR119_trim ROV11_B10_trim RSIOCR054_trim RSIOCR127_trim ROV11_B16_trim RSIOCR058_trim RSIOCR128_trim RSIOCR006_trim RSIOCR059_trim RSIOCR135_trim RSIOCR008_trim RSIOCR067_trim DRR023764_trim SRR2844622_trim SRR2859800_trim ERR10908643_trim SRR2845003_trim SRR3097584_trim SRR12278769_trim SRR2845424_trim SRR3217896_trim SRR13996249_trim SRR2846073_trim SRR5564111_trim SRR16292889_trimSRR2846076_trim SRR5564112_trim SRR1695483_trim SRR2846085_trim SRR5564113_trim SRR21615206_trim SRR2846095_trim SRR6650067_trim SRR22923304_trim SRR2847917_trim SRR9663031_trim"


INPUT=$(echo $liste_nom_base|gawk -v INDICE=$SLURM_ARRAY_TASK_ID 'BEGIN {FS=" ";}{print $INDICE;}')

creation_sra_aleatoire ${INPUT}



#for INPUT in ROV07_B06_trim
#do 

 #   READS_liste='5000000 10000000 20000000 40000000 50000000'                                  #CHANGER !!!!!!!!!!!!!!!!!
  #  creation_sra_aleatoire ${INPUT} "${READS_liste}"

    
#done


#supprime_repertoire

#chmod +x script_tirage.sh
#./script_tirage.sh









