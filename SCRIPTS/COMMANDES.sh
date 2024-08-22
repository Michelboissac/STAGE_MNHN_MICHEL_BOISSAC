
#TELECHARGEMENT DES SRAS
wget https://sra-pub-run-odp.s3.amazonaws.com/sra/${SRA}/${SRA} -O ${SRA}.sra

#CREATION DES READS1 ET READS2 AVEC LE SRA   (fastq-dump 2.8.0)
fastq-dump --split-files ./${SRA}.sra

#NETTOYAGE SUR LES DATAS TRANSFEREE (ayant une bonne qualité de sequencage, mais une signature gc sur les 15 premieres bases correspondant à un adapatateur) (Trimmomatic 0.39)
trimmomatic PE -threads 8 ${READS1} ${READS2} -baseout ${OUT} HEADCROP:15

#NETTOYAGE SUR LES DATAS TELECHARGE SRA (ayant des qualité de sequencage variables, et une signature gc sur les 15 premieres bases correspondant à un adapatateur) (Trimmomatic 0.39)
trimmomatic PE -threads 8 ${READS1} ${READS2} -baseout ${OUT} HEADCROP:15 LEADING:28 TRAILING:28 MINLEN:75

#QUALITE DE READS (fastqc v0.11.2)
fastqc ${format} -o fastqc_out

#RESUME EN 1 FICHIERS TOUTES LES QUALITES DE READS (multiqc v1.21)
multiqc fastqc_out

#ASSEMBLAGE DES READS ILLUMINAS #TRINITY date.2011_11_26  #TRINITY 2.11.0
Trinity --seqType fq --left ${READS1} --right ${READS2} --CPU 28 --max_memory 200G --output ${OUT}

#ASSEMBLAGE DES READS NANOPORES #RNA-Bloom v2.0.1
rnabloom -long ${read} -stranded -t 28 -outdir ${OUT}

#BUSCOS : mesure completude des genomes  #BUSCO 5.2.2
busco --download eukaryota #telecharge les genes buscos eucaryotes
busco -i ${TRANSCRIPTOME} -l metazoa_odb10 -o ${OUT} -m tran --offline  

#RECHERCHE DE CDS DANS LES TRANSCRIPTOMES #TRANSDECODERS   TransDecoder.LongOrfs 5.5.0
TransDecoder.LongOrfs -t ${TRANSCRIPTOME} -G "Mitochondrial-Echinoderm"

#INFERENCE ORTOHGROUPES, ARBRES DE GENES, ARBRES D ESPECES, DUPLICATION PERTES COALESCENCE pour ORTHOLOGUES.  OrthoFinder version 2.5.5
orthofinder -f ${CDS}
orthofinder -f ${CDS} -M msa #alignement seq multiple + inference arbres
    #On obtient des arbres d'orthogroupes resolus, contenant toutes les duplications'

#Dans chaques arbres resolus, on remplace  :
#TAXON_TRINITY_ID et TAXON_rb_ID > TAXON@ID, pour pouvoir utiliser treeprune de phylopytho
#treeprune realise le masking monophyly, puis le pruning paralogs   ; (#PHYLOPYTHO python https://github.com/dunnlab/phylopytho ; Version: 1.0.1 ;)
treeprune ${resolved_tree} ${output_pruned_tree}

#separe le fichiers contenant tout les clusters d orthologues de l arbre d orthogroupe en plusieurs fichiers  (csplit 8.22)
csplit ${pruned_tree} '/[&R]/' '{*}'

#On recupere ensuite les sequences de chaque arbres de cluster d orthologues elagués, puis on realigne avec mafft (#MAFFT v7.453 (2019/Nov/8) )
mafft ${SEQUENCES_ORTHOLOG} > ${MSA_ORTHOLOG}

#Remplace >TAXON@ID par >TAXON (sed 4.7)
sed 's/@.*//' ${MSA}  > ${output}

#Nettoie les alignements de sequences multiples (#GBLOCKS 0.91b )                    
Gblocks ${dossier_input}${MSA} -t=p -b1=10% -b2=10% -b3=10 -b4=5 -b5=a

#Inference d arbres pour chaque MSA, puis infernece d arbre d espece avec astral (#PARGENES  Version 3, 29 June 2007)
python ${chemin_vers_pargenes} -a ${MSAs} -o ${OUTPUT} -c 32 -d aa --use-astral --scheduler fork -m



##################################################################################################################

