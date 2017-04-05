#!/bin/bash
  
    EXIT() {
        parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`
        if [ $parent_script = "bash" ] ; then
            echo; echo -e " \e[90m exited by : $0 \e[39m " ; echo
            exit 2
        else
            echo ; echo -e " \e[90m exited by : $0 \e[39m " ; echo
            kill -9 `ps --pid $$ -oppid=`;
            exit 2
        fi    
    }

      
    CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $CURRENT_PATH
    

   while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) KEY=${1%%=*}
               VALUE=${1#*=}
               case "$KEY" in
                    ("ontology")   ontology=$VALUE                    
                    ;;
                    ("prefixFile") PrefixFile=$VALUE
                    ;;                
               esac
         ;;
         help)  echo
		echo " Total Arguments : Two                    "
                echo
		echo "   ontology=    :  IP Host                "
		echo "   prefixFile=  :  output File of prefixs "
		echo
                EXIT;
     esac
     shift
    done    
    
    ontology=${ontology:-"../SI/ontology/ontology.owl"}
    PrefixFile=${PrefixFile:-"../SI/ontology/prefix.txt"}

      
    tput setaf 2
    echo 
    echo -e " #####################################    "
    echo -e " ######### Info Prefixer #############    "
    echo -e " -------------------------------------    "
    echo -e " \e[90m$0               \e[32m            "
    echo
    echo -e " \e[91m Ontology -->  $ontology \e[32m    "
    echo -e " \e[91m Out File -->  $PrefixFile \e[32m  "
    echo
    echo -e " #####################################    "
    echo 
    sleep 0

    if [ ! -f $ontology ]  ; then
        echo
        echo -e "\e[91m Ontology $ontology not found ! \e[39m "
        EXIT
    fi
    
    grep '<rdf:RDF xmlns="' $ontology  | \
    sed -e 's/<rdf:RDF xmlns="//'      | \
    sed -e 's/"//g'                    | \
    sed 's/[[:blank:]]//g'             | \
       
        while read -r base ; do
        
        
        echo "PREFIX : $base" > $PrefixFile              
        
    done
        
    echo "PREFIX rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns#" >> $PrefixFile
    echo "PREFIX rdfs: http://www.w3.org/2000/01/rdf-schema#"      >> $PrefixFile
    echo "PREFIX xsd: http://www.w3.org/2001/XMLSchema#"            >> $PrefixFile
  
  
    grep '<owl:imports rdf:resource=' $ontology  | \
    sed -e 's/<owl:imports rdf:resource="//'     | \
    sed -e 's/"\/>//'                            | \
    sed 's/[[:blank:]]//g'                       | \
     
    while read -r ontology ; do
      
      name="${ontology##*/}"
      
      name_without_extension="$(cut -d'.' -f1 <<<"$name")"
      
      echo "PREFIX $name_without_extension: $ontology#"  >> $PrefixFile
      
    done    
    
    tput setaf 2
    echo 
    echo " Info : $PrefixFile created "
    echo     
    tput setaf 7
  
  
  exit 

