#!/bin/bash

  # Default Arguments 
    # OWL="../mapping/ontology.owl"
    # TTL="../output/ontop/ontopMaterializedTriples.ttl"
    # QUERY=" SELECT ?S ?P ?O { ?S ?P ?O } "
    # OUTPUT="../output/corese"
    # f="100000"
    # F="ttl"
  
  RELATIVE_PATH_OWL="ontology/ontology.owl"
  RELATIVE_PATH_TTL="output/02_ontop/"
  DEFAULT_OUTPUT="output/03_corese/"
  DEFAULT_QUERY="SELECT ?S ?P ?O { ?S ?P ?O . filter( !isBlank(?S) ) . filter( !isBlank(?O) )  } "
  # DEFAULT_QUERY="SELECT ?S ?P ?O { ?S ?P ?O } "
  # TOTAL TRIPLES PER FILE
  DEFAULT_FRAGMENT="-f 1000000 "
  # OUTPUT FORMAT
  DEFAULT_FORMAT="-F ttl "  
  DEFAULT_FLUSH_COUNT=" -flushCount 250000"
  # TOTAL FILES LOAD IN THE SAME TIME
  DEFAULT_PEEK="-peek 6 "
  DEFAULT_XMS="-Xms10g"
  DEFAULT_XMX="-Xmx15g"
 
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
    
  OWL=${1:-"$PARENT_SI/$RELATIVE_PATH_OWL"}
  TTL=${2:-"$SI/$RELATIVE_PATH_TTL"}
  QUERY=${3:-" $DEFAULT_QUERY "}
  OUTPUT=${4:-"$SI/$DEFAULT_OUTPUT"}
  f=${5:-"$DEFAULT_FRAGMENT"}
  F=${6:-"$DEFAULT_FORMAT"}
  PEEK=${7:-"$DEFAULT_PEEK"}
  FLUSH_COUNT=${8:-" $DEFAULT_FLUSH_COUNT "}
  XMS=${9:-"$DEFAULT_XMS"}
  XMX=${10:-"$DEFAULT_XMX"}

  tput setaf 2
  echo 
  echo -e " ######################################################### "
  echo -e " ######## Info Generation ################################ "
  echo -e " --------------------------------------------------------- "
  echo -e "\e[90m$0        \e[32m                                     "
  echo
  echo -e " ##  OWL         : $OWL                                    "  
  echo -e " ##  TTL         : $TTL                                    "
  echo -e " ##  QUERY       : $QUERY                                  "
  echo -e " ##  OUTPUT      : $OUTPUT                                 "
  echo -e " ##  FORMAT      : $F                                      "
  echo -e " ##  FRAGMENT    : $f                                      "
  echo -e " ##  PEEK        : $PEEK                                   "
  echo -e " ##  FLUSH_COUNT : $FLUSH_COUNT                            "
  echo
  echo -e " ######################################################### "
  echo 
  sleep 1
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

  java  $XMS  $XMX  -cp  ../libs/CoreseInfer.jar corese.Main  \
  -owl        "$OWL"                                          \
  -ttl        "$TTL"                                          \
  -q          "$QUERY"                                        \
  -out        "$OUTPUT"                                       \
   $f                                                         \
   $F                                                         \
   $PEEK                                                      \
   $FLUSH_COUNT                                               \
  -log "../libs/logs/corese/logs.log"                         \
  -e
  
  echo 
  echo -e "\e[36m Triples Generated in : $OUTPUT \e[39m "
  echo
        
