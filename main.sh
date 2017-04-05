#!/bin/bash

# $1 IP_HOST  
# $2 NAME_SPACE  
# $3 Read_Write_Port 
# $4 Read_Only_Port
# $5 WhichSI 
# $6 DATAB_BASE { [postgresql] - mysql } 

    CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $CURRENT_PATH
    ROOT_PATH="${CURRENT_PATH/}"
  
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
    
    while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) KEY=${1%%=*}
               VALUE=${1#*=}
               case "$KEY" in
                    ("ip")              IP_HOST=$VALUE                    
                    ;;
                    ("rw")              Read_Write_Port=$VALUE
                    ;;                    
                    ("ro")              Read_Only_Port=$VALUE
                    ;;
                    ("si")              WhichSI=$VALUE
                    ;;
                    ("db")              DATABASE=$VALUE
                    ;;      
  		    ("ext_obda")        EXTENSION_OBDA=$VALUE
		    ;;      
		    ("ext_graph")       EXTENSION_SPEC=$VALUE
		    ;;                    
                    ("class_file_name") CLASS_FILE=$VALUE
                    ;;                    
                    ("namespace")       NAME_SPACE=$VALUE
               esac
	 ;;
         help)  echo
		echo " Total Arguments : Six                                                     "
                echo
		echo "   ip=               :  IP_HOST ( or Hostname )                            "
		echo "   namespace=        :  NAME_SPACE                                         "
		echo "   rw=               :  Read_Write_Port                                    "
		echo "   ro=               :  Read_Only_Port                                     "
		echo "   si=               :  WhichSI  : DEFAULT { SI folder }                   "
		echo "   db=               :  DATA_BASE { [postgresql] - mysql }                 "
		echo "   ext_obda=         :  Extension of obda files. Ex : ext_obda=obda       "
		echo "   ext_graph=        :  Extension of specs graphs. Ex : ext_graph=graphml "
		echo "   class_file_name=  :  class file name. Ex : class_file_name=class.txt    "
		echo
                EXIT;
     esac
     shift
    done    
    
    IP_HOST=${IP_HOST:-localhost}    
    Read_Write_Port=${Read_Write_Port:-7777}
    Read_Only_Port=${Read_Only_Port:-8888}
    WhichSI=${WhichSI:-}
    DATABASE=${DATABASE:-postgresql}
    NAME_SPACE=${NAMESPACE:-data}

    #CLASS FILE 
    CLASS_FILE=${CLASS_FILE:-"class.txt"}
    CLASS_VALUE=""
    COLUMN=""

    ## EXTENSIONS
    EXTENSION_OBDA=${EXTENSION_OBDA:-"obda"}
    EXTENSION_SPEC=${EXTENSION_SPEC:-"graphml"}

    #./scripts/00_install_libs.sh db=$DATABASE
      
    ./scripts/01_use_si.sh si=$WhichSI
     
    if [ -z "$WhichSI" ] ; then
            
        GET_SI="scripts/conf/SELECTED_SI_INFO"
       
        if [ ! -f $GET_SI ]  ; then
          echo
          echo -e "\e[91m Missing $GET_SI ! \e[39m "
        fi
        
        SI=$(head -1 $GET_SI)        
            
        if [ "$SI" == "" ] ; then  
          SI="$ROOT_PATH/SI" 
        fi
    else
       SI="$ROOT_PATH/SI/$WhichSI"     
    fi
      
         
    ## Used for BACH PROCESSING
    TMP_OBDA_FOLDER="work-tmp/obda_tmp"
        
    ## TRANSFERT TO USE SCRIT
    mkdir -p $TMP_OBDA_FOLDER/
        
    ## Specs Location 
    INPUT_SPEC="$SI/input"
         
    ## Temp Specs Folder
    INPUT_TEMP_SPEC="work-tmp/input_tmp"
                  
    ## Output OBDA files 
    OUTPUT_OBDA="$SI/output/01_obda"
         
    DEFAULT_MAPPING_NAME="mapping.$EXTENSION_OBDA"
        
    ## Connexion 
    CONNECTION_FILE_PATTERN="$INPUT_SPEC/connexion/connexion"
    CONNECTION_FILE="$CONNECTION_FILE_PATTERN.$EXTENSION_SPEC"
    ONTOP_FOLDER="data/ontop"
    CORESE_FOLDER="data/corese"
                
    SI_FILE=$SI/csv/semantic_si.csv
        
    if [ ! -f $SI_FILE ]; then
      echo
      echo -e "\e[91m --> CSV not found at path : $SI_FILE ! Abort \e[39m"
      echo
      EXIT
    fi
	         
    cp $SI_FILE $SI/csv/si.csv
        
    chmod -R +x scripts/*
        
    ./scripts/utils/check_commands.sh java curl psql-mysql mvn
        
    ./scripts/12_docker_nginx.sh stop
    
    ./scripts/12_docker_nginx.sh start
      
    ./scripts/05_init_si_data.sh "-a" "-f"
            
    ./scripts/11_nano_start_stop.sh stop
      
    ./scripts/03_extract_prefixs_from_owl.sh
                
    echo
    echo -e "\e[94m --> Treat CSV : $SI_FILE \e[39m"
    echo
    sleep 0.5
      
    ./scripts/04_corese_clone_valide_csv.sh
        
    ./scripts/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$Read_Write_Port ro=$Read_Only_Port # TO DELL
                            
       	
    ########################"
    ########################
    #  DDR                ##
    ########################
    ########################	
	
    for specs in `find $INPUT_SPEC/ -type d -name "*shared*" ` ;  do  
        
        # Copy Connexiobn File ( graphml ) [ Optionnal ]

         if [  -f "$CONNECTION_FILE"  ]; then
            cp -p $CONNECTION_FILE $INPUT_TEMP_SPEC
         fi

         for specs_ddr in `find $specs -type f -name "*.$EXTENSION_SPEC" ` ;  do 

           cp $specs_ddr $INPUT_TEMP_SPEC
              
         done

         # Check if $INPUT_SPEC Folder contains more than 0 file ( connexion.graphml included [ Optionnal ] )

         if [ `ls -l $INPUT_TEMP_SPEC | egrep -c '^-'` -gt 0 ] ; then 
              
            #SPEC_FOLDER="$(dirname "$specs")"                     
                 
            if [ -f $specs/$CLASS_FILE ] ; then
                    
              LINE_ONE=$(head -n 1 $specs/$CLASS_FILE )                     
              LINE_TWO=$(sed -n '2p' $specs/$CLASS_FILE )
                       
              IFS=$'=' read -ra KEY_VALUE <<< "$LINE_ONE" 
              CLASS_VALUE=${KEY_VALUE[1]}
              IFS=$'=' read -ra KEY_VALUE <<< "$LINE_TWO" 
              COLUMN=${KEY_VALUE[1]}
                
            fi 	

            ./scripts/06_gen_mapping.sh input=../$INPUT_TEMP_SPEC  output=$OUTPUT_OBDA/$DEFAULT_MAPPING_NAME ext=.$EXTENSION_SPEC  class=$CLASS_VALUE  column="$COLUMN"

            # FOR EACH OBDA MAPPING GENERATED FROM SPEC - obdaMapping in `find $OUTPUT_OBDA/* -type f `

            for obdaMapping in ` ls -p $OUTPUT_OBDA | grep -v / ` ; do

               echo ;  echo " --> Treat OBDA File  -  $obdaMapping " ; echo
                                  
               cp -rf $OUTPUT_OBDA/$obdaMapping $TMP_OBDA_FOLDER/

               mv $TMP_OBDA_FOLDER/$obdaMapping $TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME

               ./scripts/07_ontop_gen_triples.sh obda="../$TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME"
             
               ./scripts/08_corese_infer.sh
               
               CURRENT_DATE_TIME=`date +%d_%m_%Y__%H_%M_%S`
               
               mkdir -p $SI/output/03_corese/shared/$CURRENT_DATE_TIME
                         
               mv $SI/output/03_corese/*.* $SI/output/03_corese/shared/$CURRENT_DATE_TIME                  
                       
               ./scripts/05_init_si_data.sh "-a" 
                     
               sleep 0.5
                                           
            done
               
         fi
            
    done

    
    ########################"
    ########################
    #  THE REST SPECS     ##
    ########################
    ########################
	          
    for specs in `find $INPUT_SPEC/* -type d -not -name '*connexion*' -not -name '*shared*' -not -path "*/shared/*" `; do
             
       if [ `ls -l $specs | egrep -c '^-'` -gt 0 ] ; then           
         
          echo " + Treat Specs Folder --> $specs "
              
          # Copy Connexiobn File ( graphml ) [ Optionnal ]
              
          if [  -f $CONNECTION_FILE  ]; then
	      cp -p $CONNECTION_FILE $INPUT_TEMP_SPEC
	  fi               
              
          # FOR EACH SPEC - Copy File by File from $specs folder to files $INPUT_TEMP_SPEC folder

          for spec in `find $specs/*.$EXTENSION_SPEC -type f `; do
                
              cp $spec $INPUT_TEMP_SPEC
              
          done
              
          # Check if $INPUT_SPEC Folder contains more than 0 files ( connexion.graphml included [ Optionnal ]) 
               
          if [ `ls -l $INPUT_TEMP_SPEC | egrep -c '^-'` -gt 0 ] ; then 
               
              #SPEC_FOLDER="$(dirname "$specs")"                     
                    
              if [ -f $specs/$CLASS_FILE ] ; then
                    
                 LINE_ONE=$(head -n 1 $specs/$CLASS_FILE )                     
                 LINE_TWO=$(sed -n '2p' $specs/$CLASS_FILE )
                       
                 IFS=$'=' read -ra KEY_VALUE <<< "$LINE_ONE" 
                 CLASS=${KEY_VALUE[1]}
                 IFS=$'=' read -ra KEY_VALUE <<< "$LINE_TWO" 
                 COLUMN=${KEY_VALUE[1]}
                       
              fi   
		
              ./scripts/06_gen_mapping.sh input=../$INPUT_TEMP_SPEC output=$OUTPUT_OBDA/$DEFAULT_MAPPING_NAME ext=.$EXTENSION_SPEC class="$CLASS" column="$COLUMN"

              # FOR EACH OBDA MAPPING GENERATED FROM SPEC - obdaMapping in `find $OUTPUT_OBDA/* -type f `
                    
              for obdaMapping in ` ls -p $OUTPUT_OBDA | grep -v / ` ; do
                    
                 echo ;  echo " + Treat Mapping File -->  $obdaMapping " ; echo
                         
                 cp -rf $OUTPUT_OBDA/$obdaMapping $TMP_OBDA_FOLDER/
                       
                 mv $TMP_OBDA_FOLDER/$obdaMapping $TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME
                      
                 ./scripts/07_ontop_gen_triples.sh obda="../$TMP_OBDA_FOLDER/$DEFAULT_MAPPING_NAME"                     
                                               
                 ./scripts/08_corese_infer.sh
                                
                 ./scripts/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$Read_Write_Port ro=$Read_Only_Port 

                 ./scripts/11_nano_start_stop.sh start rw
                          
                 ./scripts/09_load_data.sh
                         
                  SPARQL_FILE=$(dirname "${spec}")/sparql.txt                    
                    
                  CURRENT_DATE_TIME=`date +%d_%m_%Y__%H_%M_%S`
                      
                  ./scripts/10_portal_query.sh $SPARQL_FILE $SI/output/04_synthesis/$obdaMapping"_"$CURRENT_DATE_TIME.ttl
                     
                  ./scripts/11_nano_start_stop.sh stop
                 
                  ./scripts/05_init_si_data.sh "-output" "-tmp"
              
                  sleep 0.5
                                                                       
              done                     
                         
              ./scripts/05_init_si_data.sh "-a"
                    
          fi
                                      
       fi
            
    done
        
    ./scripts/12_docker_nginx.sh stop

    ./scripts/05_init_si_data.sh "-a" "-f"
         
    ./scripts/02_build_config.sh  ip=$IP_HOST namespace=$NAME_SPACE rw=$Read_Write_Port ro=$Read_Only_Port 
         
    ./scripts/11_nano_start_stop.sh start rw
         
    ./scripts/09_load_data.sh $SI/output/04_synthesis/ application/rdf+xml
         
    ./scripts/11_nano_start_stop.sh stop
                  
    ./scripts/11_nano_start_stop.sh start ro
  
    ## read -rsn1

