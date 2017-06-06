#!/bin/bash
   
    RW_MODE=${2:-"ro"}
    XMS=${3:-"-Xms4g"}
    XMX=${4:-"-Xmx4g"}
    #XMX=${4:-""}

    # -XX:MaxDirectMemorySize=210g 
    
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
       
    CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $CURRENT_PATH
    
    CURRENT_DIRECTORY="scripts"
    ROOT_PATH="${CURRENT_PATH/'/'$CURRENT_DIRECTORY/''}"

    BLZ_INFO_INSTALL="$CURRENT_PATH/conf/BLZ_INFO_INSTALL"
    NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
    READ_ONLY_XML_CONF="$CURRENT_PATH/conf/blazegraph/owerrideXMl/webWithConfReadOnly.xml"
    
    if [ "$1" = "start" ] ; then 
        
        if [ "$RW_MODE" != "ro" ] && [ "$RW_MODE" != "rw" ] ; then 
        
             echo
             if [ "$RW_MODE" = "" ] ; then
               echo -e "\e[91m Missing RW_MODE Argument ( 'rw' - 'ro' ) \e[39m "
             else
               echo -e "\e[91m RW_MODE Argument can only have 'rw' or 'ro' value \e[39m "
             fi 
             EXIT          
        fi 
        
        if [ ! -f $BLZ_INFO_INSTALL ]  ; then
           echo
           echo -e "\e[91m Missing $BLZ_INFO_INSTALL ! \e[39m "
           EXIT
        fi
        if [ ! -f $NANO_END_POINT_FILE ]  ; then
           echo
           echo -e "\e[91m Missing $NANO_END_POINT_FILE ! \e[39m "
           EXIT
        fi
        if [ ! -f $READ_ONLY_XML_CONF ]  ; then
           echo
           echo -e "\e[91m Missing $READ_ONLY_XML_CONF ! \e[39m "
           EXIT
        fi
        
        LINE=$(head -1 $NANO_END_POINT_FILE)        
            
        IFS=$' \t\n' read -ra INFO_NANO <<< "$LINE" 
        NANO_END_POINT_HOST=${INFO_NANO[0]}
        NAME_SPACE=${INFO_NANO[1]}
        L_PORT=${INFO_NANO[2]}
        R_PORT=${INFO_NANO[3]}
          
        BLAZEGRAPH_PATH=`cat $BLZ_INFO_INSTALL`
        
        DIR_BLZ=$(dirname "${BLAZEGRAPH_PATH}")
         
        tput setaf 2
        echo 
        echo " ########################################  "
        echo " ######## Starting EndPoint #############  "
        echo " ----------------------------------------  "
        echo -e " \e[90m$0                        \e[39m "
        tput setaf 7
        echo
        echo -e " \e[37m** NanoEndpoint File      \e[39m "
        echo -e "   \e[90m $NANO_END_POINT_FILE   \e[39m "
        echo
        
        # Run On Local Port 
        
        if [ "$RW_MODE" = "rw" ] ; then 
        
          releasePort $L_PORT
          releasePort $R_PORT
          sleep 2
          
          tput setaf 2
          echo -e " ##  NAMESPACE   : $NAME_SPACE        "
          echo -e " ##  Local PORT  : $L_PORT            "
          echo -e " ##  MODE        : $RW_MODE           "
          echo
          echo -e " #################################### "
          echo 
          tput setaf 7
          sleep 2         
         
          java -server -XX:+UseG1GC $XMS $XMX  -XX:+UseStringDeduplication     -XX:MaxDirectMemorySize=4g         \
               -Xloggc:$DIR_BLZ/logs/gc.txt                                             \
               -verbose:gc -XX:+PrintGCDetails                                          \
               -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps                            \
               -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10                      \
               -XX:GCLogFileSize=5M                                                     \
               -server -Dorg.eclipse.jetty.server.Request.maxFormContentSize=2000000000 \
               -Dcom.bigdata.journal.AbstractJournal.file=$DIR_BLZ/data/blazegraph.jnl  \
               -Djetty.port=$L_PORT -jar $BLAZEGRAPH_PATH &
               
          sleep 2
          
        # Run On Remote Port 
        
        elif [ "$RW_MODE" = "ro" ] ; then
        
          releasePort $L_PORT
          releasePort $R_PORT
          
          sleep 2
          
          tput setaf 2
          echo -e " ##  NAMESPACE   : $NAME_SPACE        "     
          echo -e " ##  Remote PORT : $R_PORT            "
          echo -e " ##  MODE        : $RW_MODE           "
          echo
          echo -e " #################################### "
          echo 
          tput setaf 7
          sleep 2
        
          java -server -XX:+UseG1GC $XMS $XMX -XX:+UseStringDeduplication    -XX:MaxDirectMemorySize=4g         \
               -Xloggc:$DIR_BLZ/logs/gc.txt                                             \
               -verbose:gc -XX:+PrintGCDetails                                          \
               -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps                            \
               -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10                      \
               -XX:GCLogFileSize=5M                                                     \
               -server -Dorg.eclipse.jetty.server.Request.maxFormContentSize=2000000000 \
               -Dcom.bigdata.journal.AbstractJournal.file=$DIR_BLZ/data/blazegraph.jnl  \
               -Djetty.overrideWebXml=$READ_ONLY_XML_CONF -Djetty.port=$R_PORT -jar $BLAZEGRAPH_PATH &
               
          sleep 2        
        fi
       
        # curl -X DELETE http://$NANO_END_POINT_HOST:$L_PORT/blazegraph/namespace/kb &> /dev/null
          
        echo  -e " \e[97m "
       
        
    elif [ "$1" = "stop" ] ; then 

      if [ -f $NANO_END_POINT_FILE ] ; then
      
         tput setaf 2
         echo 
         echo "######################################## "
         echo "######## Stopping EndPoint ############# "
         echo "---------------------------------------- "
         echo -e " \e[90m$0                     \e[32m  "
         echo
           
         echo -e " \e[37m** NanoEndpoint File    \e[39m "
         echo -e " \e[90m $NANO_END_POINT_FILE   \e[39m "
           
         tput setaf 7
         
         LINE=$(head -1 $NANO_END_POINT_FILE)        
               
         IFS=$' \t\n' read -ra INFO_NANO <<< "$LINE"     
         L_PORT=${INFO_NANO[2]}
         R_PORT=${INFO_NANO[3]}
        
         echo
         echo " Stop EndPoint on port -> $L_PORT "
         fuser -k $L_PORT/tcp  &> /dev/null
         
         echo " Stop EndPoint on port -> $R_PORT "
         fuser -k $R_PORT/tcp  &> /dev/null
         echo
         echo " EndPoint Stopped !! "
         echo
      fi
        
    else
        echo
        echo " Invalid arguments :  Please pass One or Two arguments "
        echo " arg_1             :  start - stop                     "
        echo " RW_MODE           :  ro - rw                          "
        echo
   
    fi
    
