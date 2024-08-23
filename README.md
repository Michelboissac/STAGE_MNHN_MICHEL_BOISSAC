# STAGE_MNHN_MICHEL_BOISSAC

Le repertoire SCRIPTS contient les scripts les plus importants de mon stage.

COMMANDES.sh = Totalité des lignes de commande de tout les outils utilisés avec leurs parametres

INFORMATIONS_ORTHOFINDER.sh = Informations à propos d'OrthoFInder

INFOS_PARALLELISATION_CLUSTER.sh  = lignes de commandes en debut de script utilisée pour paralleliser des taches sur le cluster HPC que j'ai utilisé

INSTALL_TOOLS.sh  = Installation des outils utilise lors de mon stage

NETTOYAGE_to_ORTHOFINDER/ contient le script ALL.sh qui s'execute sur le cluster HPC PCIA de l’UAR 2700 2AD.
ALL.sh permet de creer des scripts dynamiquement pour telecharger des échantillons ILLUMINA de la base de donnée SRA du NCBI, permet de nettoyer les données ILLUMINA, et d'assembler des données ILLUMINA et NANOPORE
de faire une recherche de CDS dans les transcriptomes, puis lancer OrthoFInder. ALL.sh lance ensuite ces scripts sur le cluster, en parallelisant chaque jeux de données.

Tout les commentaires necessaire sont dans ALL.sh pour executer le script. Chaque script genere dynamiquement peut etre lancé independament si l'on modifie #SBATCH --partition=${partition_type} ainsi que $liste_nom_base
  
ORTHOGROUPS_to_ORTHOLOGUES/ contient les scripts utilisés pour le masquing monophyly des orthogroupes , permettant de générer des clusters d'orthologues
1_fabrication_liste.sh a été utilisé car le nombre d'orthogroupe etait très important, alors j'ai créer 100 listes d'orthogroupe grace à ce script, puis le script 2_PRUNED_SCRIPT.sh executer "Treeprune" de maniere paralleliser sur les 100 jeux de données d'orthogroupes.
  
ORTHOLOGUES_to_PHYLOGENIE/ contient le code permettant de faire des alignements de séquences multiples sur l'ensemble des données.


