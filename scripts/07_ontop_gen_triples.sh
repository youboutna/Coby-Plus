#!/bin/bash
 
 CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 cd $CURRENT_PATH
 ROOT_PATH="${CURRENT_PATH/}"
 PARENT_DIR="$(dirname "$ROOT_PATH")"


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
                    ("owl")        OWL=$VALUE                    
                    ;;
                    ("obda")       OBDA=$VALUE
                    ;;                    
                    ("output")     OUTPUT=$VALUE
                    ;;
                    ("query")      QUERY=$VALUE
                    ;;
                    ("ttl")        TTL=$VALUE
                    ;;      
  		    ("batch")      BATCH=$VALUE
		    ;;      
		    ("pageSize")   PAGESIZE=$VALUE
		    ;;                    
                    ("fragment")   FRAGMENT=$VALUE
                    ;;                    
                    ("flushCount") FLUSHCOUNT=$VALUE
                    ;;                    
                    ("merge")      MERGE=$VALUE
                    ;;                    
                    ("xms")        XMS=$VALUE
                    ;;                    
                    ("xmx")        XMX=$VALUE
               esac
	 ;;
         help)  echo
		echo " Total Arguments : Twelve                                                                          "
                echo 
		echo "   owl=        :  Path of the Ontology                                                             "
		echo "   obda=       :  OBDA File Path                                                                   "
		echo "   output=     :  Output Files                                                                     "
		echo '   query=      :  Sparql Query for extraction. Ex : query="SELECT ?S ?P ?O { ?S ?P ?O }"           '
		echo "   ttl=        :  Turtle Output. Ex : ttl=ttl                                                      "
		echo "   batch=      :  Enable batch. batch=batch                                                        "
		echo "   pageSize=   :  Number of rows which are extracted from DB ( with Batch ). Ex : pageSize=200000  "
		echo "   fragment=   :  Number of triples by file  "
		echo "   flushCount= :  total line in memory before flush to file. Ex flushCount=500000                  "
		echo "   merge=      :  Includ Ontology in each turtle file ( case : Batch ). Ex : merge=merge           "
		echo "   xms=        :  XMS. Ex xms=500m                                                                 "
		echo "   xmx=        :  XMX. Ex : xmx=2g                                                                 "
		echo
                EXIT;
     esac
     shift
  done   


 RELATIVE_PATHPATH_OWL="ontology/ontology.owl"
 RELATIVE_PATHPATH_OBDA="work-tmp/obda_tmp/mapping.obda"
 RELATIVE_PATHPATH_OUTPUT="output/02_ontop/ontopGen.ttl"
 DEFAULT_QUERY="SELECT ?S ?P ?O { ?S ?P ?O } "
 DEFAULT_TTL="ttl"
 #DEFAULT_BACTH="batch"
 DEFAULT_BACTH=""
 DEFAULT_PAGE_SIZE="200000"
 DEFAULT_FRAGMENT="1000000"
 DEFAULT_FLUSH_COUNT="500000"
 DEFAULT_MERGE="" 
 # DEFAULT_MERGE="-merge" 
 DEFAULT_XMS="10g"
 DEFAULT_XMX="10g"

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
      
  PARENT_SI="$(dirname "$SI")"

  OWL=${OWL:-"$PARENT_SI/$RELATIVE_PATHPATH_OWL"}
  OBDA=${OBDA:-"$PARENT_DIR/$RELATIVE_PATHPATH_OBDA"}
  OUTPUT=${OUTPUT:-"$SI/$RELATIVE_PATHPATH_OUTPUT"}
  QUERY=${QUERY:-"$DEFAULT_QUERY"}
  TTL="-"${TTL:-"$DEFAULT_TTL"}
  
  BATCH="-"${BATCH:-"$DEFAULT_BACTH"}
  PAGESIZE="-pageSize "${PAGESIZE:-"$DEFAULT_PAGE_SIZE"}
  FRAGMENT="-f "${FRAGMENT:-"$DEFAULT_FRAGMENT"}
  FLUSHCOUNT="-flushCount "${FLUSHCOUNT:-"$DEFAULT_FLUSH_COUNT"}
  MERGE="-"${MERGE:-"$DEFAULT_MERGE"}
  XMS="-Xms"${XMS:-"$DEFAULT_XMS"}
  XMX="-Xmx"${XMX:-"$DEFAULT_XMX"}
     
  tput setaf 2
  echo 
  echo -e " ######################################### "
  echo -e " ######## Info Generation ################ "
  echo -e " ----------------------------------------- "
  echo -e "\e[90m$0      \e[32m                       "
  echo
  echo -e " ##  OWL        : $OWL                     "
  echo -e " ##  OBDA       : $OBDA                    "
  echo -e " ##  OUTPUT     : $OUTPUT                  "
  echo -e " ##  QUERY      : $QUERY                   "
  echo -e " ##  BATCH      : $BATCH                   "
  echo -e " ##  TTL        : $TTL                     "
  echo -e " ##  MERGE      : $MERGE                   "
  echo -e " ##  FLUSHCOUNT : $FLUSHCOUNT              "
  echo -e " ##  PAGESIZE   : $PAGESIZE                "
  echo -e " ##  FRAGMENT   : $FRAGMENT                "
  echo -e " ##  XMS        : $XMS                     "
  echo -e " ##  XMX        : $XMX                     "
  echo
  echo -e " ######################################### "
  echo 
  sleep 2
  tput setaf 7

  if [ ! -f $OWL ] ; then
     echo -e "\e[91m Missing OWL File [[ $OWL ]] ! \e[39m "
     EXIT
  fi

  if [ ! -f $OBDA ]  ; then
     echo -e "\e[91m Missing OBDA File [[ $OBDA ]] ! \e[39m "
     EXIT
  fi
  echo -e "\e[90m Strating Generation... \e[39m "
  echo
 
  java  $XMS $XMX -cp ../libs/Ontop-Materializer.jar entry.Main_1_18  \
  -owl  "$OWL"                                                        \
  -obda "$OBDA"                                                       \
  -out  "$OUTPUT"                                                     \
  -q    "$QUERY"                                                      \
   $TTL  $BATCH $PAGESIZE  $MERGE $FRAGMENT  $FLUSHCOUNT
   
  echo
  echo -e "\e[36m Triples Generated in : $OUTPUT \e[39m "
  echo
        
  
