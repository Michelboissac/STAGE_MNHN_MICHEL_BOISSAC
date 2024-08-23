# STAGE_MNHN_MICHEL_BOISSAC

Le repertoire SCRIPTS contient les scripts les plus importants de mon stage.
COMMANDES.sh = Totalité des lignes de commande de tout les outils utilisés avec leurs parametres
INFORMATIONS_ORTHOFINDER.sh = Informations à propos d'OrthoFInder
INFOS_PARALLELISATION_CLUSTER.sh  = lignes de commandes en debut de script utilisée pour paralleliser des taches sur le cluster HPC que j'ai utilisé
INSTALL_TOOLS.sh  = Installation des outils utilise lors de mon stage

NETTOYAGE_to_ORTHOFINDER/
  ALL.sh
  ASSEMBLAGE_ILLUMINA.sh
  ASSEMBLAGE_NANOPORE.sh
  CDS.sh
  NETTOYAGE_ILLUMINA.sh
  NETTOYAGE_SRA.sh
  ORTHOLOGS_PHYLOGENIE.sh
  QUALITE_illumina_non_nettoyee.sh
  QUALITE_nettoyee.sh
  QUALITE_sra_non_nettoyee.sh
  SRA_TO_FASTQ.sh
  TELECHARGE_SRA.sh
  
ORTHOGROUPS_to_ORTHOLOGUES/
  1_fabrication_liste.sh
  2_PRUNED_SCRIPT.sh
  
ORTHOLOGUES_to_PHYLOGENIE/
  1_fabrication_liste.sh
  2_PRUNED_SCRIPT.sh


TRANSCRIPTOMES_qualite/Courbes_de_rarefaction/
  20240731script_tirage_V2_fonction_tirage (copie).sh
  fastqtotsv.awk
  selection_tirage_pile.awk
  tsvtofastq.awk
