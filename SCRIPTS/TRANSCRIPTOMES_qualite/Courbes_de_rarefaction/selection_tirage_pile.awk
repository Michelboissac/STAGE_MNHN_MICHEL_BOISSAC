#! /usr/bin/gawk -f  
BEGIN{FS="\t";buffer="";read_select=0;}
{

      read_num=NR
      if (read_select==0){          #prend le 1er element de la pile
          getline tmp < pile
          ligne=tmp RT
          split(ligne,elements,"\t")
          read_select=elements[1]
      }

      if (read_select==read_num){   #verifie que ligne correspond au tirage
          print $0 > output;        #print la ligne dans output
          getline tmp < pile
          ligne=tmp RT              #prend l'element suivant de la pile'
          split(ligne, elements,"\t")
          read_select=elements[1]
      }

}


#ce script verifie la concordance entre le numero de ligne et les numeros issus du tirage.

#les numeros issus du tirages sont dans la pile, 
