#!/bin/bash
  
  # 1 - INPUT                   : Default : SI/yedSpec/tmp
  # 2 - OUTPUT                  : Default : SI/output/01_obda/mapping.obda
  # 3 - EXTENSION               : Default : ".graphml"
  # 4 - CSV_FILE                : Default : SI/csv/si.csv
  # 5 - PRF=                    : Default : SI/csv/config/si.properties
  # 6 - JS=                     : Default : SI/csv/config/si.js
  # 7 - INCLUDE_GRAPH_VARIAVLES : Default : "".  -ig : Treat only listed variables in graph

  
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
  ROOT_PATH="${CURRENT_PATH/}"
  PARENT_DIR="$(dirname "$ROOT_PATH")"

   while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) KEY=${1%%=*}
               VALUE=${1#*=}
               case "$KEY" in
                    ("input")                INPUT=$VALUE                    
                    ;;
                    ("output")               OUTPUT=$VALUE
                    ;;                    
                    ("ext")                  EXTENSION=$VALUE
                    ;;
                    ("class")                CLASS=$VALUE
                    ;;
                    ("column")               COLUMN=$VALUE
                    ;;      
  		    ("prefixFile")           PREFIX_FILE=$VALUE
		    ;;      
		    ("defaultPrefix")        DEFAULT_PREFIX=$VALUE
		    ;;                    
                    ("connecFile")           CONNEC_FILE=$VALUE
                    ;;                    
                    ("csvFile")              CSV_FILE=$VALUE
                    ;;                    
                    ("prf")                  PRF=$VALUE
                    ;;                    
                    ("js")                   JS=$VALUE
                    ;;                    
                    ("includeGraphVariable") INCLUDE_GRAPH_VARIAVLES=$VALUE
               esac
	 ;;
         help)  echo
		echo " Total Arguments : Twelve                                                                        "
                echo 
		echo "   input=                 :  Folder containing Modelization ( graphs )                           "
		echo "   output=                :  Output Mapping FOlder                                               "
		echo "   ext=                   :  Extension of Graphs                                                 "
		echo "   class=                 :  Discriminator class                                                 "
		echo "   column=                :  Discriminator Column                                                "
		echo "   prefixFile=            :  Prefix File Path                                                    "
		echo "   defaultPrefix=         :  Default Prefix ( if not indeicated in graph )                       "
		echo "   connecFile=            :  Connection file                                                     "
		echo "   csvFile=               :  CSV File 			                                       "
		echo "   prf=                   :  Property file App configuration                                     "
		echo "   js=                    :  JS File                                                             "
		echo "   includeGraphVariable=  :  Treat Variables indicated in Graph. Ex : include_graph_variable=-ig "
		echo
                EXIT ;
     esac
     shift
  done   

  CLASS_TAG="-class "
  COLUMN_TAG="-column "
   
  SELECTED_SI="conf/SELECTED_SI_INFO"
  
  if [ ! -f $SELECTED_SI ]  ; then
     echo
     echo -e "\e[91m Missing $SELECTED_SI ! \e[39m "
     EXIT
  fi
 
  SI=$(head -1 $SELECTED_SI)        
     
  if [ "$SI" == "" ] ; then  
    SI="$PARENT_DIR/SI" 
  fi
     
  INPUT=${INPUT:-"$PARENT_DIR/work-tmp/input_tmp"} 
  OUTPUT=${OUTPUT:-"$SI/output/01_obda/mapping.obda"}
  EXTENSION=${EXTENSION:-".graphml"}
     
  CLASS=${CLASS:-""}
  COLUMN=${COLUMN:-""}
         
  PREFIX_FILE=${PREFIX_FILE:-"$PARENT_DIR/SI/ontology/prefix.txt"}
  DEFAULT_PREFIX=${DEFAULT_PREFIX:-"oboe-core"} 
  CONNEC_FILE=${CONNEC_FILE:-"$SI/connection.txt"}  
  
      
  CSV_FILE=${CSV_FILE:-"-csv $SI/csv/si.csv"}
  PRF=${PRF:-"-prf $SI/csv/config/si.properties"}
  JS=${JS:-"-js $SI/csv/config/si.js"}
  
  INCLUDE_GRAPH_VARIAVLES=${INCLUDE_GRAPH_VARIAVLES:-""}  # -ig parameter

  if [ -z "$CLASS" ]; then
     CLASS_TAG=""
  fi
  
  if [ -z "$COLUMN" ]; then
     COLUMN_TAG=""
  fi

  tput setaf 2
  echo 
  echo -e " ############################################### "
  echo -e " ######## Info Generation ###################### "
  echo -e " ----------------------------------------------  "
  echo -e "\e[90m$0            \e[32m                       "
  echo
  echo -e " ##  INPUT         : $INPUT                      "
  echo -e " ##  EXTENTION     : $EXTENSION                  "
  echo
  echo -e " ##  CSV_FILE      : $CSV_FILE                   "
    
  if [ "$CLASS" != "" ] ; then   
  echo -e " ##  CLASS         : $CLASS                      "
  else 
  echo -e " ##  CLASS         : *  ( Treate all csv Lines ) "
  fi
  
  if [ "$COLUMN" != "" ] ; then   
  echo -e " ##  COLUMN        : $COLUMN                     "
  fi
      
  if [ -z "$INCLUDE_GRAPH_VARIAVLES" ] ; then   
  echo -e " ##  GRAPH_VAR     : FALSE "
  else 
  echo -e " ##  GRAPH_VAR_INC : $INCLUDE_GRAPH_VARIAVLES    "
  fi
  
  echo -e " ##  Prop File     : $PRF                        "
  echo -e " ##  JS File       : $JS                         "
 
  echo
  echo -e " ##  OUTPUT        : $OUTPUT                     "
  echo
  echo -e " ############################################### "
  echo 
  sleep 2
  tput setaf 7

  if [ ! -d $INPUT ] ; then
     echo -e "\e[91m $INPUT is not a valid Directory ! \e[39m "
     EXIT
  fi

  echo -e "\e[90m Starting Generation... \e[39m "
  echo

  # TREAT CSV
  java -cp ../libs/yedGen.jar entypoint.Main -d          $INPUT                   \
                                             -out        $OUTPUT                  \
                                             -ext        $EXTENSION               \
                                             -prefixFile $PREFIX_FILE             \
                                             -def_prefix $DEFAULT_PREFIX          \
                                             -connecFile $CONNEC_FILE             \
                                                         $CSV_FILE                \
                                                         $PRF                     \
                                                         $JS                      \
                                                         $CLASS_TAG "$CLASS"      \
                                                         $COLUMN_TAG "$COLUMN"    \
                                                         $INCLUDE_GRAPH_VARIAVLES                                                  

<<COMMENT

# TREAT Only variables enumerated in Graph
  java -cp ../libs/yedGen.jar entypoint.Main -d   $INPUT     \
                                             -out $OUTPUT    \
                                             -ext $EXTENSION \
                                             -ig 
COMMENT


  echo -e "\e[36m Mapping generated in : $OUTPUT \e[39m "
  echo
  
