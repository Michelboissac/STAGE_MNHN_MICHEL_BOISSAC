######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
                                    #manuel :
#Il faut lancer le script dans un env conda qui contient :

#-wget
#-fastq-dump
#-fastqc
#-Transdescoders
#-Orthofinder
#-rnabloom

#(voir en dessous les lignes de commande pour installer)

#lancer le script de cette maniere depuis le repertoire ou le script est présent :

#bash ALL.sh -sra "" -illumina "" "" -nanopore "" ""

#exemple :

#bash ALL.sh -sra "SRR3217923 SRR16134549" -illumina "/mnt/beegfs/pmartinezsoares/Transcriptomes_bruts/data1/data_non_nettoyee/" "RSIOCR008 RSIOCR033" -nanopore "/mnt/beegfs/pmartinezsoares/Transcriptomes_bruts/data_nanopore/" "SQK-PCB111-24_barcode13.fastq.gz"

#-sra : telecharge des illuminas du ncbi
#-illumina : repertoire contenant des paires de fastq illuminas + bases des noms
#-nanopore : repertoire contenant un echantillon fatsq nanopore + bases des noms
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
    ##creation env conda :

#yes|conda create -n environnement_stage_crinoide

    ##Installation Transdescoders conda :

#conda install bioconda::transdecoder
#curl -L https://cpanmin.us | perl - App::cpanminus
#cpanm install DB_File
#cpanm install URI::Escape

    ##Installation Orthofinder conda :

#conda install bioconda::orthofinder

    ##FASTQC :
#yes|conda install bioconda/label/broken::fastqc


    ##SRA TOOLS (fastqdump split) :
#yes|conda install bioconda::sra-tools


    ##RNABLOOM :
#conda install -c bioconda rnabloom

######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
############################# PARAMETRES #############################################
############################# PARAMETRES #############################################
############################# PARAMETRES #############################################
############################# PARAMETRES #############################################
############################# PARAMETRES #############################################
######################################################################################
#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES
#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES
#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES#PARAMETRES
liste_nom_base_sra=$2
repertoire_travail_illumina=$4
liste_nom_base_illumina=$5
repertoire_travail_nanopore=$7
liste_nom_base_nanopore=$8
repertoire_travail=$(pwd)/

#liste des noms de SRA
liste_nom_base_sra_illumina="$liste_nom_base_sra $liste_nom_base_illumina" 
liste_nom_base_sra_illumina_nanopore="$liste_nom_base_sra $liste_nom_base_illumina $liste_nom_base_nanopore"
#parametres cluster :
CPU=28
memoire=250Go
job_name=crinoide
partition_type=type_2

#paramatres nettoyage (trimmomatic)
trimmomatic_cpu=8
trimmomatic_param="HEADCROP:15 LEADING:28 TRAILING:28 MINLEN:75"

#paramatre assemblage shorts reads illuminas (trinity)
trinity_cpu=28
trinity_max_memory=200G


#
#NOM DES DIFFERENTS SCRIPTS
TELECHARGE_SRA=TELECHARGE_SRA.sh
SRA_TO_FASTQ=SRA_TO_FASTQ.sh
NETTOYAGE_SRA=NETTOYAGE_SRA.sh
NETTOYAGE_ILLUMINA=NETTOYAGE_ILLUMINA.sh
QUALITE_illumina_non_nettoyee=QUALITE_illumina_non_nettoyee.sh
QUALITE_sra_non_nettoyee=QUALITE_sra_non_nettoyee.sh
QUALITE_nettoyee=QUALITE_nettoyee.sh
ASSEMBLAGE_ILLUMINA=ASSEMBLAGE_ILLUMINA.sh
ASSEMBLAGE_NANOPORE=ASSEMBLAGE_NANOPORE.sh
CDS=CDS.sh
ORTHOLOGS_PHYLOGENIE=ORTHOLOGS_PHYLOGENIE.sh
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
#INFORMATIONS SCRIPT#INFORMATIONS SCRIPT#INFORMATIONS SCRIPT#INFORMATIONS SCRIPT
# Étape 1 : WGET + FASTQDUMP    sra
    #TELECHARGE_SRA.sh ; wget
    #SRA_TO_FASTQ.sh ;   fastq-dump
# Étape 2 : NETTOYAGE           sra + illumina 
    #NETTOYAGE.sh ;      Trimmomatic (module)
# Étape 3 : ASSEMBLAGE          sra + illumina
    #ASSEMBLAGE.sh ;     Trinity     (module)
# Étape 4 : QUALITÉ             sra + illumina
    #QUALITE.sh ;        fastqc
# Étape 5 : CDS                 sra + illumina + nanopore
    #CDS.sh ;            Transdescoders (conda)
# Étape 6 : ORTHOLOGS + PHYLOGENIE   sra + illumina + nanopore
    #ORTHOLOGS_PHYLOGENIE.sh ;  Orthofinder (conda)

#ce script utilise les modules du cluster,
#dans un 1er temps creer des scripts de maniere dynamique en prenant les paramatres : 
#$repertoire_travail  et  $liste_nom_base

#puis ensuite lance ces scripts sur slurm avec des dependances entres les jobs afin de bien lancer un un script après l'autre
#l'Assemblage et la qualite sont réalisé en parallele (dependant du job de nettoyage)'

#certains outils ne sont pas sur les modules, il faut donc lancer le script dans environnment conda deja créer au préalable
#(l'environnement conda se lance avec module python/conda, mais on peut quitter le module python conda et rester dans l'environnement conda ensuite')
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
#TELECHARGEMENT#
function creation_script_telechargement(){

    repertoire_travail=$1
    liste_nom_base=$2
    nom_script=$3
    echo "#!/bin/bash

#repertoire_travail=\$1
#liste_nom_base=\$2

repertoire_travail=${repertoire_travail}
liste_nom_base=\"${liste_nom_base}\"


##############################################################################
function telechargement(){
    DOSSIER_OUTPUT=\$1
    mkdir \${DOSSIER_OUTPUT}
    NOM_BASE=\$2
    sample=\${DOSSIER_OUTPUT}\${NOM_BASE}.sra
    wget https://sra-pub-run-odp.s3.amazonaws.com/sra/\${NOM_BASE}/\${NOM_BASE} -O \${sample}
}	

#TELECHARGEMENT 
for NOM_BASE in \${liste_nom_base}
do
    DOSSIER_OUTPUT=\${repertoire_travail}SRA/
    telechargement \${DOSSIER_OUTPUT} \${NOM_BASE}   #&    : permet de paralleliser les telechargements, mais peut saturer le noeud principal, NE MARCHE PAS, CAR PASSE DIRECTEMENT A SRA_to_FASTQ
done

###############################################################################

" > ${repertoire_travail}${nom_script}

}
######################################################################################
#SRA TO FASTQ#
function creation_script_sra_to_fastq(){
    repertoire_travail=$1
    liste_nom_base=$2
    CPU=$3
    memoire=$4
    job_name=$5
    partition_type=$6
    nom_script=$7
    len=$(echo "$liste_nom_base" | wc -w)
    echo "#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=${CPU}

#SBATCH --job-name=${job_name}

#SBATCH --mem=${memoire}

#SBATCH --partition=${partition_type}

#SBATCH --array=1-${len}


#repertoire_travail=\$1
#liste_nom_base=\$2

repertoire_travail=${repertoire_travail}
liste_nom_base=\"${liste_nom_base}\"

##############################################################################
#commande tableau de job , parcours la liste_nom_base

NOM_BASE=\$(echo \$liste_nom_base | gawk -v INDICE=\$SLURM_ARRAY_TASK_ID 'BEGIN {FS=\" \";} {print \$INDICE;}')


function SRAtoFASTQ(){
    DOSSIER_INPUT=\$1
    DOSSIER_OUTPUT=\$2
    mkdir \${DOSSIER_OUTPUT}
    NOM_BASE=\$3
    fastq-dump --split-files \${DOSSIER_INPUT}\${NOM_BASE}.sra --outdir \${DOSSIER_OUTPUT}
}

DOSSIER_INPUT=\${repertoire_travail}SRA/
DOSSIER_OUTPUT=\${repertoire_travail}FASTQ/
SRAtoFASTQ \${DOSSIER_INPUT} \${DOSSIER_OUTPUT} \${NOM_BASE}

" > ${repertoire_travail}${nom_script}
}
######################################################################################
#QUALITE
function creation_script_qualite(){
    DOSSIERS=$1
    DOSSIER_OUTPUT=${DOSSIERS[0]}
    DOSSIER_INPUT=${DOSSIERS[1]}
    #repertoire_travail=$1
    
    liste_nom_base=$2
    CPU=$3
    memoire=$4
    job_name=$5
    partition_type=$6
    nom_script=$7
    echo "#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=${CPU}

#SBATCH --job-name=${job_name}

#SBATCH --mem=${memoire}

#SBATCH --partition=${partition_type}

#repertoire_travail=\$1


repertoire_travail=${repertoire_travail}

function QUALITE(){
     DOSSIER_INPUT=\$1
     DOSSIER_OUTPUT=\$2
     NOM_BASE=\$3
     

     mkdir \${DOSSIER_OUTPUT}
     fastqc \${DOSSIER_INPUT}\${NOM_BASE}* -o \${DOSSIER_OUTPUT}
}


DOSSIER_INPUT=${DOSSIER_INPUT}   #\${repertoire_travail}FASTQ/
DOSSIER_OUTPUT=${DOSSIER_OUTPUT}  #\${repertoire_travail}QUALITE_data_non_nettoyee/
liste_nom_base=\"${liste_nom_base}\"
for NOM_BASE in \$liste_nom_base
do
    QUALITE \${DOSSIER_INPUT} \${DOSSIER_OUTPUT} \${NOM_BASE}
done

" > ${repertoire_travail}${nom_script}

}
######################################################################################
#ASSEMBLAGE
function creation_script_assemblage(){
    repertoire_travail=$1
    liste_nom_base=$2
    CPU=$3
    memoire=$4
    job_name=$5
    partition_type=$6


    trinity_cpu=$7
    trinity_max_memory=$8
    nom_script=$9

    len=$(echo "$liste_nom_base" | wc -w)
    echo "#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=${CPU}

#SBATCH --job-name=${job_name}

#SBATCH --mem=${memoire}

#SBATCH --partition=${partition_type}

#SBATCH --array=1-${len}


#repertoire_travail=\$1
#liste_nom_base=\$2

repertoire_travail=${repertoire_travail}
liste_nom_base=\"${liste_nom_base}\"

##############################################################################
#commande tableau de job , parcours la liste_nom_base

NOM_BASE=\$(echo \$liste_nom_base | gawk -v INDICE=\$SLURM_ARRAY_TASK_ID 'BEGIN {FS=\" \";} {print \$INDICE;}')

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

    DOSSIER_INPUT=\$1
    DOSSIER_OUTPUT=\$2
    mkdir \${DOSSIER_OUTPUT}
    NOM_BASE=\$3
    READS1=\${DOSSIER_INPUT}\${NOM_BASE}_1P.fastq
    READS2=\${DOSSIER_INPUT}\${NOM_BASE}_2P.fastq
    Trinity --seqType fq --left \${READS1} --right \${READS2} --CPU ${trinity_cpu} --max_memory ${trinity_max_memory} --output \${DOSSIER_OUTPUT}trinity\${NOM_BASE}
    cp \${DOSSIER_OUTPUT}trinity\${NOM_BASE}/Trinity.fasta \${DOSSIER_OUTPUT}\${NOM_BASE}.fasta

    module purge
}
DOSSIER_INPUT=\${repertoire_travail}NETTOYAGE/
DOSSIER_OUTPUT=\${repertoire_travail}ASSEMBLAGE/
ASSEMBLAGE \${DOSSIER_INPUT} \${DOSSIER_OUTPUT} \${NOM_BASE}" > ${repertoire_travail}${nom_script}
}
######################################################################################
#NETTOYAGE
function creation_script_nettoyage(){
    DOSSIERS=$1
    DOSSIER_OUTPUT=${DOSSIERS[0]}
    DOSSIER_INPUT=${DOSSIERS[1]}
    liste_nom_base=$2
    CPU=$3
    memoire=$4
    job_name=$5
    partition_type=$6
    
    trimmomatic_cpu=$7
    trimmomatic_param=$8

    nom_script=$9




    
    len=$(echo "$liste_nom_base" | wc -w)

    echo "#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=${CPU}

#SBATCH --job-name=${job_name}

#SBATCH --mem=${memoire}

#SBATCH --partition=${partition_type}

#SBATCH --array=1-${len}



liste_nom_base=\"${liste_nom_base}\"

##############################################################################
#commande tableau de job , parcours la liste_nom_base
NOM_BASE=\$(echo \$liste_nom_base | gawk -v INDICE=\$SLURM_ARRAY_TASK_ID 'BEGIN {FS=\" \";} {print \$INDICE;}')

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

    DOSSIER_INPUT=\$1
    DOSSIER_OUTPUT=\$2
    mkdir \${DOSSIER_OUTPUT}
    NOM_BASE=\$3

    READS1=\${DOSSIER_INPUT}\${NOM_BASE}*1*            #\${DOSSIER_INPUT}\${NOM_BASE}_1.fastq
    READS2=\${DOSSIER_INPUT}\${NOM_BASE}*2*
    #trimmomatic PE -threads ${trimmomatic_cpu} \${READS1} \${READS2} -baseout \${DOSSIER_OUTPUT}\${NOM_BASE}.fastq ${trimmomatic_param}
    java -jar \$TRIM_HOME/trimmomatic.jar PE -threads ${trimmomatic_cpu} \${READS1} \${READS2} -baseout \${DOSSIER_OUTPUT}\${NOM_BASE}.fastq ${trimmomatic_param}
    module purge
}

DOSSIER_INPUT=${DOSSIER_INPUT}
DOSSIER_OUTPUT=${DOSSIER_OUTPUT}




NETTOYAGE \${DOSSIER_INPUT} \${DOSSIER_OUTPUT} \${NOM_BASE}

mkdir \${DOSSIER_OUTPUT}NETTOYAGE_U
mv \${DOSSIER_OUTPUT}*U.fastq \${DOSSIER_OUTPUT}NETTOYAGE_U/



##########################################################################
" > ${repertoire_travail}${nom_script}
}
######################################################################################
#RECHERCHE ORF
function creation_script_recherche_orf(){
    repertoire_travail=$1
    liste_nom_base=$2
    CPU=$3
    memoire=$4
    job_name=$5
    partition_type=$6
    nom_script=$7
    len=$(echo "$liste_nom_base" | wc -w)

    echo "#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=${CPU}

#SBATCH --job-name=${job_name}

#SBATCH --mem=${memoire}

#SBATCH --partition=${partition_type}

#SBATCH --array=1-${len}


#repertoire_travail=\$1
#liste_nom_base=\$2

repertoire_travail=${repertoire_travail}
liste_nom_base=\"${liste_nom_base}\"
##############################################################################
#commande tableau de job , parcours la liste_nom_base
NOM_BASE=\$(echo \$liste_nom_base | gawk -v INDICE=\$SLURM_ARRAY_TASK_ID 'BEGIN {FS=\" \";} {print \$INDICE;}')

function recherche_CDS(){
    NOM_BASE=\$1
    repertoire=\$2
    repertoire_output=\$3
   
    #
    output=\${repertoire_output}\${NOM_BASE}.pep
    TRANSCRIPTOME=\${repertoire}ASSEMBLAGE/*\${NOM_BASE}*.fasta

    #
    TransDecoder.LongOrfs -t \${TRANSCRIPTOME} 

    #
    repertoire_output_transdecoder=\${repertoire}\${NOM_BASE}.fasta.transdecoder_dir/
    output_transdecoder=\${repertoire_output_transdecoder}longest_orfs.pep
 
    #
    mv \${output_transdecoder} \${output}
    rm -r \${repertoire_output_transdecoder}
    rm -r \${repertoire}\${NOM_BASE}.fasta.transdecoder_dir.__checkpoints_longorfs/
}

repertoire=\${repertoire_travail}
repertoire_output=\${repertoire_travail}CDS/

#
mkdir \${repertoire_output}

recherche_CDS \${NOM_BASE} \${repertoire} \${repertoire_output}




" > ${repertoire_travail}${nom_script}
}

######################################################################################
function creation_script_recherche_orthologs_phylogenie(){

    
    repertoire_travail=$1

    CPU=$2
    memoire=$3
    job_name=$4
    partition_type=$5
    nom_script=$6


    echo "#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=${CPU}

#SBATCH --job-name=${job_name}

#SBATCH --mem=${memoire}

#SBATCH --partition=${partition_type}

#repertoire_travail=\$1


repertoire_travail=${repertoire_travail}

orthofinder -f CDS

" > ${nom_script}
}
######################################################################################
function assemblage_nanopore_rna_bloom(){

    DOSSIERS=$1
    DOSSIER_OUTPUT=${DOSSIERS[0]}
    DOSSIER_INPUT=${DOSSIERS[1]}
    liste_nom_base=$2
    CPU=$3
    memoire=$4
    job_name=$5
    partition_type=$6
    

    nom_script=$7

    len=$(echo "$liste_nom_base" | wc -w)

    echo "#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=${CPU}

#SBATCH --job-name=${job_name}

#SBATCH --mem=${memoire}

#SBATCH --partition=${partition_type}

#SBATCH --array=1-${len}


function assemblage(){
    nom_base=\$1
    repertoire_output=\$2
    repertoire_input=\$3

    read=\$repertoire_input\$nom_base
    assemblage_out=\$repertoire_output\$nom_base
    rnabloom -long \$read -stranded -t 28 -outdir \$assemblage_out
    cp \${assemblage_out}/rnabloom.transcripts.fa \${assemblage_out}.fasta
}



DOSSIER_INPUT=${DOSSIER_INPUT}
DOSSIER_OUTPUT=${DOSSIER_OUTPUT}
liste_nom_base=\"${liste_nom_base}\"
read=\$(echo \$liste_nom_base | gawk -v INDICE=\$SLURM_ARRAY_TASK_ID 'BEGIN {FS=\" \";} {print \$INDICE;}')

#


assemblage \$read \$DOSSIER_OUTPUT \$DOSSIER_INPUT
" > ${nom_script}
}
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
#CONSTRUCTION DYNAMIQUE DES SCRIPTS##CONSTRUCTION DYNAMIQUE DES SCRIPTS##CONSTRUCTION DYNAMIQUE DES SCRIPTS#
#CONSTRUCTION DYNAMIQUE DES SCRIPTS##CONSTRUCTION DYNAMIQUE DES SCRIPTS##CONSTRUCTION DYNAMIQUE DES SCRIPTS#
#CONSTRUCTION DYNAMIQUE DES SCRIPTS##CONSTRUCTION DYNAMIQUE DES SCRIPTS##CONSTRUCTION DYNAMIQUE DES SCRIPTS#
##CONSTRUCTION DYNAMIQUE DES SCRIPTS#    >  mettre des parentheses sur  $liste_nom_base > "$liste_nom_base"
##################################TELECHARGE
creation_script_telechargement $repertoire_travail "$liste_nom_base_sra" ${TELECHARGE_SRA}
##################################SRA_TO_FASTQ
creation_script_sra_to_fastq $repertoire_travail "$liste_nom_base_sra" $CPU $memoire SRA_TO_FASTQ $partition_type ${SRA_TO_FASTQ}
##################################NETTOYAGE
DOSSIER_INPUT=${repertoire_travail}FASTQ/
DOSSIER_OUTPUT=${repertoire_travail}NETTOYAGE/
DOSSIERS=("$DOSSIER_OUTPUT" "$DOSSIER_INPUT")
creation_script_nettoyage "$DOSSIERS" "$liste_nom_base_sra" $CPU $memoire NETTOYAGE_SRA $partition_type $trimmomatic_cpu "$trimmomatic_param" ${NETTOYAGE_SRA} 
#
DOSSIER_INPUT=$repertoire_travail_illumina
DOSSIER_OUTPUT=${repertoire_travail}NETTOYAGE/
DOSSIERS=("$DOSSIER_OUTPUT" "$DOSSIER_INPUT")
creation_script_nettoyage "$DOSSIERS" "$liste_nom_base_illumina" $CPU $memoire NETTOYAGE_ILLUMINA $partition_type $trimmomatic_cpu "$trimmomatic_param" ${NETTOYAGE_ILLUMINA} 
##################################QUALITE
#qualite illumina non nettoyee (input est indiqué par utilisateurs)
job_name=QUALITE
DOSSIER_INPUT=$repertoire_travail_illumina
DOSSIER_OUTPUT=${repertoire_travail}QUALITE_illumina_non_nettoyee/
DOSSIERS=("$DOSSIER_OUTPUT" "$DOSSIER_INPUT")
creation_script_qualite "$DOSSIERS" "$liste_nom_base_illumina" $CPU $memoire QUALITE $partition_type ${QUALITE_illumina_non_nettoyee}
#qualite illumina sra non nettoyee  (pas d'input')
DOSSIER_INPUT=${repertoire_travail}FASTQ/
DOSSIER_OUTPUT=${repertoire_travail}QUALITE_sra_non_nettoyee/
DOSSIERS=("$DOSSIER_OUTPUT" "$DOSSIER_INPUT")
creation_script_qualite "$DOSSIERS" "$liste_nom_base_sra" $CPU $memoire QUALITE $partition_type ${QUALITE_sra_non_nettoyee}
#qualite illumina nettoye (telechargé sra + illumina dossier)
DOSSIER_INPUT=${repertoire_travail}NETTOYAGE/
DOSSIER_OUTPUT=${repertoire_travail}QUALITE_nettoyee/
DOSSIERS=("$DOSSIER_OUTPUT" "$DOSSIER_INPUT")
creation_script_qualite "$DOSSIERS" "$liste_nom_base_sra_illumina" $CPU $memoire QUALITE $partition_type ${QUALITE_nettoyee}
##################################ASSEMBLAGE ILLUMINA
creation_script_assemblage $repertoire_travail "$liste_nom_base_sra_illumina" $CPU $memoire trinity $partition_type $trinity_cpu $trinity_max_memory ${ASSEMBLAGE_ILLUMINA}
###################################ASSEMBLAGE NANOPORE
DOSSIER_INPUT=${repertoire_travail_nanopore}
DOSSIER_OUTPUT=${repertoire_travail}ASSEMBLAGE/
DOSSIERS=("$DOSSIER_OUTPUT" "$DOSSIER_INPUT")
assemblage_nanopore_rna_bloom "$DOSSIERS" "$liste_nom_base_nanopore" $CPU $memoire rna_bloom $partition_type ${ASSEMBLAGE_NANOPORE}
##################################CDS
creation_script_recherche_orf $repertoire_travail "$liste_nom_base_sra_illumina_nanopore" $CPU $memoire CDS $partition_type ${CDS}
##################################ORTHOLOGS_PHYLOGENIE
creation_script_recherche_orthologs_phylogenie $repertoire_travail $CPU $memoire ORTHOLOGS_PHYLOGENIE $partition_type ${ORTHOLOGS_PHYLOGENIE}
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
######################################################################################
#EXECUTION DES SCRIPTS
function attente(){
    job=$1
    while squeue --job $job ;do
        echo "$job"
        sleep 10
    done
}
function telecharge_sra(){
    bash ${repertoire_travail}${TELECHARGE_SRA} "$repertoire_travail" "$liste_nom_base"
}
function sra_to_fastq(){
    
    job=$(sbatch --parsable ${repertoire_travail}${SRA_TO_FASTQ})
    attente $job
}
function nettoyage_illumina(){
    job=$(sbatch --parsable ${repertoire_travail}${NETTOYAGE_ILLUMINA})
    attente $job
}
function nettoyage_sra(){
    job=$(sbatch --parsable ${repertoire_travail}${NETTOYAGE_SRA})
    attente $job
}
function qualite_illumina_non_nettoyee(){
    job=$(sbatch --parsable ${repertoire_travail}${QUALITE_illumina_non_nettoyee}) 
}
function qualite_sra_non_nettoyee(){
    job=$(sbatch --parsable ${repertoire_travail}${QUALITE_sra_non_nettoyee}) 
}
function qualite_nettoyee(){
    job=$(sbatch --parsable ${repertoire_travail}${QUALITE_nettoyee})
}
function assemblage_illumina(){
    job=$(sbatch --parsable ${repertoire_travail}${ASSEMBLAGE_ILLUMINA})
    attente $job
}
function assemblage_nanopore(){
    job=$(sbatch --parsable ${repertoire_travail}${ASSEMBLAGE_NANOPORE})
    attente $job
}
function cds(){
    job=$(sbatch --parsable ${repertoire_travail}${CDS})
    attente $job
}
function orthologs_phylogenie(){
    job=$(sbatch --parsable ${repertoire_travail}${ORTHOLOGS_PHYLOGENIE})
    attente $job
}
#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS
#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS
#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS

if [ -z "$liste_nom_base_sra" ]; then
    echo "pas de SRA"
else
    echo "SRA : $liste_nom_base_sra"
    telecharge_sra
    sra_to_fastq
    qualite_sra_non_nettoyee
    nettoyage_sra
fi


if [ -z "$liste_nom_base_illumina" ]; then
    echo "pas d'ILLUMINAS deja telecharge'."
else
    echo "ILLUMINAS deja telecharge : $liste_nom_base_illumina"
    qualite_illumina_non_nettoyee
    nettoyage_illumina
fi


if [ -z "$liste_nom_base_sra" ] && [ -z "$liste_nom_base_illumina" ]; then
    echo "pas d'illuminas telecharge et de sra'"
else
    echo "illuminas + sra : $liste_nom_base_sra $liste_nom_base_illumina "
    qualite_nettoyee
    assemblage_illumina               
fi


if [ -z "$liste_nom_base_nanopore" ]; then
    echo "pas de NANOPORE"
else
    echo "NANOPORE deja telecharge : $liste_nom_base_nanopore"
    assemblage_nanopore               
fi
cds                               
orthologs_phylogenie             

#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS
#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS
#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS#EXECUTION DES SCRIPTS
#info : fastq-dump doit etre dans env conda, 


