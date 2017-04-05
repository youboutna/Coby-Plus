#!/bin/bash

  # java - curl - [psql-mysql] - maven
  
  tput setaf 2
  echo 
  echo -e " ################################# "
  echo -e " ######### Check Commands ######## "
  echo -e " --------------------------------- "
  echo -e " \e[90m$0        \e[32m            "
  echo
  sleep 1
  tput setaf 7
  
  script_name="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
  parent_script=`ps -ocommand= -p $PPID | awk -F/ '{print $NF}' | awk '{print $1}'`
  
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
        
  checkCommand() {
    com=$1
    if which $com >/dev/null ; then        
        return 1      
    else     
        return 0             
    fi
  }
    
  checkExit() {
    comm=$1
    EXIST=$2
    if [ "$EXIST" == 1 ] ; then 
       echo " OK .... $comm "
       sleep  0.4
    else
       echo
       echo -e "\e[91m $comm  : Command not found. Aborting \e[39m" ; 
       echo
       EXIT
    fi   
  }
  
  
  for com in "$@" ; do
    
     comm=$com
     
     if [[ "$comm" != *-* ]]; then
         checkCommand $comm
         checkExit $comm $?
     
     else
     
        splitedCommands=$(echo $comm | tr "-" "\n")
        declare -i EXISTS=0
        
        for splitedCommand in $splitedCommands ; do
        
            checkCommand $splitedCommand 
            EXISTS=$(( $EXISTS + $? ))
            
            if [ $EXISTS -eq 1 ] ; then
                 checkExit $splitedCommand 1
                 break
            fi
            
        done
        
        if [ $EXISTS == 0 ] ; then 
             echo -e "\e[91m No command found : $comm \e[39m"
        fi
     fi
     
  done

  echo
  
  
