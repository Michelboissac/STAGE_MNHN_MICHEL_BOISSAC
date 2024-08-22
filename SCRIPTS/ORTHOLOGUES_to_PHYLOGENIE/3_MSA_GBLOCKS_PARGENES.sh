function MSA(){

    dossier_input=$1
    dossier_output=$2


    mkdir -p $dossier_output
    for seq in $(ls ${dossier_input});
    do
        INPUT=${dossier_input}$seq
        OUTPUT=${dossier_output}$seq.msa
        mafft $INPUT > $OUTPUT
    done
}
function taxon_a_id_to_taxon(){
    dossier_input=$1
    dossier_output=$2
    mkdir -p $dossier_output
    for alignement in $(ls $dossier_input);
    do
    echo $alignement
    sed 's/@.*//' ${dossier_input}${alignement}  > ${dossier_output}${alignement}.a.txt

    done
}
function gblocks_msa(){
   dossier_input=$1
   dossier_output=$2

   dossier_output_gb_html=${dossier_output}html/
   dossier_output_gb=${dossier_output}GBLOCKS/

   mkdir -p $dossier_output_gb_html
   mkdir -p $dossier_output_gb

   for MSA in $(ls $dossier_input)
   do
   
   Gblocks ${dossier_input}${MSA} -t=p -b1=10% -b2=10% -b3=10 -b4=5 -b5=a
   #-t=p   : type of sequence : proteins
   #-b1 : Minimum Number Of Sequences For A Conserved Position (50% of the number of sequences + 1) ; Any integer bigger than half the number of sequences and smaller or equal than the total number of sequences
   #-b2 : Minimum Number Of Sequences For A Flank Position ; (85% of the number of sequences) 	Any integer equal or bigger than Minimum Number Of Sequences For A Conserved Position
   #-b3 : Maximum Number Of Contiguous Nonconserved Positions (8) ; Any integer
   #-b4 : Minimum Length Of A Block (10) Any integer equal or bigger than 2
   #-b5 : Allowed Gap Positions (None, With Half, All) ; n, h, a

   mv ${dossier_input}${MSA}-gb.htm ${dossier_output_gb_html}${MSA}-gb.htm
   mv ${dossier_input}${MSA}-gb ${dossier_output_gb}${MSA}-gb

   done

}

dossier_travail_output=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/DATAS/EXPLORATION_ORTHOLOGS/EXPLORATION_ORTHOLOGS/
dossier_travail_input=/media/mboissac/Expansion/STAGE_MICHEL_CRINOIDES/DATAS/ORTHOLOGS_TAXONS/

listes_clusters_orthologs_nombres_taxons=$(ls ${dossier_travail_input})

for clusters in $listes_clusters_orthologs_nombres_taxons;
do
    echo ${clusters}
    dossier_input=${dossier_travail_input}${clusters}/
    dossier_output=${dossier_travail_output}MSA/${clusters}/
    #MSA ${dossier_input} ${dossier_output} &

    dossier_input=${dossier_travail_output}MSA/${clusters}/
    dossier_output=${dossier_travail_output}MSA_A/${clusters}/
    taxon_a_id_to_taxon ${dossier_input} ${dossier_output} &

    dossier_input=${dossier_travail_output}MSA_A/${clusters}/
    dossier_output=${dossier_travail_output}GBLOCKS_A/${clusters}/
    #gblocks_msa ${dossier_input} ${dossier_output}


done










