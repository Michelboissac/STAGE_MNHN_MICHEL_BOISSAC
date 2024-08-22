#! /usr/bin/gawk -f  

BEGIN{FS="\t";buffer="";count=0;}
{
    count=count+1;

    buffer=sprintf("%s\t%s",buffer,$1);
    
    
    if(count==4){
        print buffer;
        count=0;
        buffer="";
    }
}


