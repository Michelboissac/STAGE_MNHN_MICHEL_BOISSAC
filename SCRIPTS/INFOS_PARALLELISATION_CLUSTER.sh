################################################################################################################
                #PARALLELISATION SUR LE CLUSTER :

#Pour paralleliser des taches sur des noeuds differents du cluster,
#jai utilisé "#SBATCH --array=1-66" suivis de "$SLURM_ARRAY_TASK_ID",
#pour recuperer dans une liste de 66 elements, tout les elements, 
#et lancer une fonction sur chaque elements en meme temps


#!/usr/bin/bash 

#SBATCH --nodes=1

#SBATCH --ntasks-per-node=28

#SBATCH --job-name=nom

#SBATCH --mem=250Go

#SBATCH --partition=type_2

#SBATCH --array=1-66

liste_nom_base="nom1 nom2 nom3 ... ... ... nom66"

NOM_BASE=$(echo $liste_nom_base|gawk -v INDICE=$SLURM_ARRAY_TASK_ID 'BEGIN {FS=" ";}{print $INDICE;}')


