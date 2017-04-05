#!/bin/bash

  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  
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
  
  
   ## IF ZERO ARGUMENT
   
   if [ $# -eq 0 ] ; then
           
     SELECTED_SI="conf/SELECTED_SI_INFO"
        
     if [ ! -f $SELECTED_SI ]  ; then
         echo
         echo -e "\e[91m Missing $SELECTED_SI ! \e[39m "
         EXIT
     fi
    
     SI=$(head -1 $SELECTED_SI)        
        
     if [ "$SI" == "" ] ; then  
         DATA_DIR="$PARENT_DIR/SI/output/03_corese/"         
     else    
         DATA_DIR="$SI/output/03_corese/"
     fi
    
     CONTENT_TYPE="text/turtle"
    
   fi 
  
  ## IF ONE ARGUMENT 
  
   if [ $# -eq 1 ] ; then
      DATA_DIR=$1
      CONTENT_TYPE="text/turtle"
   fi
  
   if [ $# -eq 2 ] ; then
      DATA_DIR=$1
      CONTENT_TYPE=$2
   fi
  
   if [ $# -eq 4 -o $# -eq 5 ] ; then
      
     IP=$1
     PORT=$2
     NAMESPACE=$3
     DATA_DIR=$4
    
     if [ $# -eq 5 ] ; then
       CONTENT_TYPE=$5
     else
       CONTENT_TYPE="text/turtle"
     fi
      
   elif [ $# -eq 0 -o  $# -eq 1 -o $# -eq 2  -o $# -eq 3 ] ; then
   
      NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
    
      LINE=$(head -1 $NANO_END_POINT_FILE)        
          
      IFS=$' \t\n' read -ra INFO_NANO <<< "$LINE" 
      IP=${INFO_NANO[0]}
      NAMESPACE=${INFO_NANO[1]}
      PORT=${INFO_NANO[2]}       
   
   else 
       echo
       echo -e "\e[91m 0 or 3 arguments ( IP PORT NAMESAPCE ) ! \e[39m "
       echo
       EXIT
   fi
   
  PREFIX_ENDPOINT="http://$IP:$PORT"
  SUFFIX_ENDPOINT="blazegraph/namespace/$NAMESPACE/sparql"
  
  ENDPOINT=$PREFIX_ENDPOINT/$SUFFIX_ENDPOINT
 
  # Test connexion with specified namespace 
  check="cat < /dev/null > /dev/tcp/http://$IP/$PORT"
      
  echo ; echo -e " Try connection : $ENDPOINT "
        
  TRYING=50
  COUNT=0
        
  timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2> /dev/null
        
  OK=$?
        
  while [ $OK -ne 0 -a $COUNT -lt $TRYING  ] ; do
        
    timeout 1 bash -c "cat < /dev/null > /dev/tcp/$IP/$PORT" 2> /dev/null
           
    OK=$?
           
    if [ $COUNT == 0 ] ; then echo ; fi 
           
    if [ $OK == 1 ] ; then 
             
      echo " .. "
      sleep 0.4 
             
    elif [ $OK != 0 ] ; then 
          
      echo " attempt ( $COUNT ) : Try again.. "
      sleep 0.8
             
    fi
           
    let "COUNT++"
           
    if [ $COUNT == $TRYING ] ; then
          
      echo
      echo -e "\e[31m ENDPOINT $ENDPOINT Not reachable !! \e[39m"
      echo
      EXIT
             
    fi
           
  done
        
  RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
        
  COUNT=0
        
  while  [ -z $RES ] || [ $RES -ne 200 ] ;do
        
    sleep 1
    RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
    let "COUNT++" 
           
    if  [ -z $RES ] || [ $RES -ne 200 ] ; then 
        if [ `expr $COUNT % 3` -eq 0 ] ; then
           echo -e " attempt to join $ENDPOINT .. "
        fi
    fi
           
  done
       
  echo " Yeah Connected !! "
       
  
  if [ ! -d $DATA_DIR ] ; then
     echo -e "\e[91m $DATA_DIR is not valid Directory ! \e[39m "
     echo EXIT
  fi
            
  # Remove the sparql file automatically created by blazegraph
  if [ -f "$DATA_DIR/sparql" ] ; then
    rm -f "$DATA_DIR/sparql" 
  fi

  sleep 0.5  # Waits 0.5 second .

  cd $DATA_DIR
        
  tput setaf 2
  echo 
  echo -e " ################################################################ "
  echo -e " ######## Info Load Data ######################################## "
  echo -e " ---------------------------------------------------------------- "
  echo -e " \e[90m$0                                                  \e[32m "
  echo
  echo -e " # ENDPOINT     : $PREFIX_ENDPOINT                                "
  echo -e " # NAMESPACE    : $NAMESPACE                                      "
  echo -e " # PORT         : $PORT                                           "
  echo -e " # CONTENT_TYPE : $CONTENT_TYPE                                   "
  echo -e "\e[90m   Folder     $DATA_DIR                              \e[32m "
  echo
  echo -e " ################################################################ "
  echo 
  sleep 1  
  tput setaf 7
       
  for _file in `find * -type f -not -name "sparql" `; do
   
      echo -e " \e[39m Upload file :\e[92m $_file \e[39m                    " 
      echo " ----------------------------------------------------------------------- "
      echo
      curl -D- -H "Content-Type: $CONTENT_TYPE" --upload-file $_file -X POST $ENDPOINT -O
      echo
      echo " ----------------------------------------------------------------------- "
   
  done 
    
  # Content-Type: text/turtle
  # Content-Type: text/rdf+n3
  # Content-Type: Content-Type: application/rdf+xml
  # Content-Type: application/sparql-results+json
  
