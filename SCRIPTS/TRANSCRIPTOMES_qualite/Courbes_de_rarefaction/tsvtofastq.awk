#! /usr/bin/gawk -f  


BEGIN{FS="\t";buffer="";count=0;}
{
    
    print $2 > queue;
    print $3 > queue;
    print $4 > queue;
    print $5 > queue;

   
    print $7 > tete;
    print $8 > tete;
    print $9 > tete;
    print $10 > tete;


}

