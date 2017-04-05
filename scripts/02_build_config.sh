#!/bin/bash

# Docker version min : 1.10 
# $1 IP_HOST
# $2 NameSpace
# $3 ReadWritePort
# $4 ReadOnlyPort

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
  
releasePort() {
  PORT=$1          
  if ! lsof -i:$PORT &> /dev/null
  then
    isFree="true"
  else    
    r_comm=`fuser -k $PORT/tcp  &> /dev/null`
    sleep 1
  fi
}  
    

    while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) KEY=${1%%=*}
               VALUE=${1#*=}
               case "$KEY" in
                    ("ip")        IP_HOST=$VALUE                    
                    ;;
                    ("namespace") NAMESPACE=$VALUE
                    ;;                    
                    ("rw")        ReadWritePort=$VALUE
                    ;;
                    ("ro")        ReadOnlyPort=$VALUE
		    ;;                   
               esac
         ;;
         help)  echo
		echo " Total Arguments : Four                 "
                echo
		echo "   ip=         :  IP Host               "
		echo "   namespace=  :  Blazegraph_namespace  "
		echo "   rw=         :  Local Ports number    "
		echo "   ro=         :  Remote Ports number   "
		echo
                EXIT;
     esac
     shift
    done    
    
    IP_HOST=${IP_HOST:-localhost}
    NAMESPACE=${NAMESPACE:-data}
    ReadWritePort=${ReadWritePort:-7777}
    ReadOnlyPort=${ReadOnlyPort:-8888}


   CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
   cd $CURRENT_PATH
   
   NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
 
   BLZ_INFO_INSTALL="$CURRENT_PATH/conf/BLZ_INFO_INSTALL"
   BLAZEGRAPH_PATH=`cat $BLZ_INFO_INSTALL`

   DIR_BLZ=$(dirname "${BLAZEGRAPH_PATH}")
    
   DEFAULT_NAMESPACE="MY_NAMESPACE"
   
   DATALOADER="$CURRENT_PATH/conf/blazegraph/namespace/dataloader.xml"
   
   tput setaf 2
   echo 
   echo -e " ##################################### "
   echo -e " ######### Build Config ############## "
   echo -e " ------------------------------------- "
   echo -e " \e[90m$0        \e[32m                "
   echo
   echo -e " ##  IP_HOST       : $IP_HOST          "
   echo
   echo -e " ##  NAMESPACE     : $NAMESPACE        "
   echo -e " ##  ReadWritePort : $ReadWritePort    "
   echo -e " ##  ReadOnlyPort  : $ReadOnlyPort     "
   echo
   echo -e " ##################################### "
   echo 
   sleep 1
   tput setaf 7

   BLZ_JNL="$DIR_BLZ/data/blazegraph.jnl"
  
   if [ -e $BLZ_JNL ] ; then
      
      echo
      echo -e "\e[91m $DIR_BLZ/data/blazegraph.jnl will be deteted \e[39m "
      echo
      read -n1 -t 1 -r -p " Press Enter to continue, Any other Key to abort.. else delete in 1 s " key
      echo  
      if [ "$key" = '' ] ; then
          # Nothing pressed
          rm -f $BLZ_JNL &> /dev/null
          echo " blazegraph.jnl deteted "
          echo
      else
          # Anything pressed
          echo
          echo " Script aborted "
          EXIT
      fi
   fi
   
   echo "$IP_HOST $NAMESPACE $ReadWritePort $ReadOnlyPort" > $NANO_END_POINT_FILE
     
   releasePort $ReadWritePort  
   releasePort $ReadOnlyPort  

   java -server -XX:+UseG1GC -Dcom.bigdata.journal.AbstractJournal.file=$DIR_BLZ/data/blazegraph.jnl \
        -Djetty.port=$ReadWritePort -Dcom.bigdata.rdf.sail.namespace=$NAMESPACE -jar $BLAZEGRAPH_PATH &
   
   sleep 3
   
   sed -i "s/$DEFAULT_NAMESPACE/$NAMESPACE/g" conf/blazegraph/namespace/dataloader.xml
   
   curl -X POST --data-binary @$DATALOADER --header 'Content-Type:application/xml' \
           http://$IP_HOST:$ReadWritePort/blazegraph/dataloader
   
   sleep 2
   
   curl -X DELETE http://$IP_HOST:$ReadWritePort/blazegraph/namespace/kb &> /dev/null
 
   sleep 1
   
   sed -i "s/$NAMESPACE/$DEFAULT_NAMESPACE/g" conf/blazegraph/namespace/dataloader.xml
   echo ; echo
   echo -e "\e[92m Namespace created \e[39m "
   sleep 0.5 ; echo
   echo -e "\e[93m Stopping Blazegraph \e[39m "
   
   KILL_PROCESS=$(fuser -k $ReadWritePort/tcp &>/dev/null )
   
   sleep 0.5
   echo -e "\e[93m Blazegraph Stopped \e[39m "
   echo
   echo -e "\e[92m Use 11_nano_start_stop.sh script to start-stop Blazegraph \e[39m "
   echo

