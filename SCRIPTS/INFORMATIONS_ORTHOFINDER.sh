
#################################################################################################################
                #INFORMATIONS SUR ORTHOFINDER

#etape orthofinder

1) trouver les orthogroups    (orthofinder 1)
2) inferer des arbres des genes NON ENRACINEE   (dendroblast or msa)
3) inferer un arbres des especes NON ENRACINEE
4) enraciner l arbre des especes
5) enraciner les arbres des genes
6) resoudre les arbres des genes


        FASTA            >         ORTHOGROUPS         > ARBRES GENES NON ENRACINEE > ARBRE ESPECES NON ENRACINEE > ARBRE ENRACINEE > ARBRES GENES ENRACINEE > ARBRES GENES ENRACINEE RESOLED
                        (1)                           (2)                          (3)                           (4)                                         DLC
                   (orthofinder 1)                   (msa)                       (stag)                         (stride)
                                      |(a) alignement seq multiples               
                                      |avec (mafft)
                                      |               +
                                      |(b) maximum de vraisemblance 
                                      |sur alignements pour 
                                      |inferer arbres
                                      |________________________
                                      |       (dendroblast)
                                      |bootstrap + blast avec 
                                      |(diamond) > matrice distance
                                      |inference arbre

# 1 orthogroup = 1 alignement = 1arbre de gene


