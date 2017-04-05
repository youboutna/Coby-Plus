#!/bin/bash

CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $CURRENT_PATH 
ROOT_PATH="${CURRENT_PATH/}"
PARENT_DIR="$(dirname "$ROOT_PATH")"

SELECTED_SI="conf/SELECTED_SI_INFO"

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
  
SI=$(head -1 $SELECTED_SI)        
     
if [ "$SI" == "" ] ; then  
   SI="$PARENT_DIR/SI" 
fi
  

if [ ! -d "$SI" ]; then
  echo
  echo -e " \e[91m Error : Folder  [ $SI ] with all configuration must exists \e[32m "
  EXIT
fi

tput setaf 2
echo 
echo -e " #####################################   "
echo -e " ############  Init SI  ##############   "
echo -e " -------------------------------------   "
echo -e " \e[90m$0               \e[32m           "
echo
echo -e " \e[91m SI LOCATION -->  $SI \e[32m      "
echo
echo -e " #####################################   "
echo 

sleep 2

tput setaf 7


 if [ "$1" == "-a" ]; then

    if [ ! -d "$SI/output/01_obda" ]; then
      mkdir -p $SI/output/01_obda
      echo -e " \e[90m created folder : $SI/output/01_obda \e[32m "
    else
      rm -rf $SI/output/01_obda/*.* ; rm -rf $SI/output/01_obda/*
      echo -e " \e[90m All files removed from : $SI/output/01_obda \e[32m "   
    fi
        
    if [ ! -d "$SI/output/02_ontop" ]; then
      mkdir -p $SI/output/02_ontop
      echo -e " \e[90m created folder : $SI/output/02_ontop \e[32m "
    else
      rm -rf $SI/output/02_ontop/*.* ; rm -rf $SI/output/02_ontop/*
      echo -e " \e[90m All files removed from : $SI/output/02_ontop \e[32m "   
    fi

    if [ ! -d "$SI/output/03_corese" ]; then
      mkdir -p $SI/output/03_corese
      echo -e " \e[90m created folder : $SI/output/03_corese \e[32m "
    else
      rm -rf $SI/output/03_corese/*.* 
      rm -rf $SI/output/03_corese/sparql
    if [ "$2" == "-f" ]; then
      rm -rf $SI/output/03_corese/*
    fi
      echo -e " \e[90m All files removed from : $SI/output/03_corese \e[32m "   
    fi
    
    if [ ! -d "../work-tmp/obda_tmp/" ]; then
      mkdir -p ../work-tmp/obda_tmp/
      echo -e " \e[90m created folder : ../work-tmp/obda_tmp/ \e[32m "
    else
      rm -rf ../work-tmp/obda_tmp/*.* ; rm -rf ../work-tmp/obda_tmp/*
      echo -e " \e[90m All files removed from : ../work-tmp/obda_tmp/ \e[32m "   
    fi
    
    if [ ! -d "../work-tmp/input_tmp/" ]; then
      mkdir -p ../work-tmp/input_tmp/
      echo -e " \e[90m created folder : ../work-tmp/input_tmp/ \e[32m "
    else
      rm -rf ../work-tmp/input_tmp/*.* ; rm -rf ../work-tmp/input_tmp/*
      echo -e " \e[90m All files removed from : ../work-tmp/input_tmp/ \e[32m "   
    fi
 
 fi 
 
  
 if [ "$1" == "-output" ]; then   
   
    if [ ! -d "$SI/output/02_ontop" ]; then
      mkdir -p $SI/output/02_ontop
      echo -e " \e[90m created folder : $SI/output/02_ontop \e[32m "
    else
      rm -rf $SI/output/02_ontop/*.* ; rm -rf $SI/output/02_ontop/*
      echo -e " \e[90m All files removed from : $SI/output/02_ontop \e[32m "   
    fi

    if [ ! -d "$SI/output/03_corese" ]; then
      mkdir -p $SI/output/03_corese
      echo -e " \e[90m created folder : $SI/output/03_corese \e[32m "
    else
      rm -rf $SI/output/03_corese/*.* 
      rm -rf $SI/output/03_corese/sparql     
      echo -e " \e[90m All files removed from : $SI/output/03_corese \e[32m "   
    fi
    
    if [ "$2" == "-tmp" ]; then
      
       if [ ! -d "../work-tmp/obda_tmp/" ]; then
          mkdir -p ../work-tmp/obda_tmp/
          echo -e " \e[90m created folder : ../work-tmp/obda_tmp/ \e[32m "
       else
          rm -rf ../work-tmp/obda_tmp/*.* ; rm -rf ../work-tmp/obda_tmp/*
          echo -e " \e[90m All files removed from : ../work-tmp/obda_tmp/ \e[32m "   
       fi
        
       if [ ! -d "../work-tmp/input_tmp/" ]; then
          mkdir -p ../work-tmp/input_tmp/
          echo -e " \e[90m created folder : ../work-tmp/input_tmp/ \e[32m "
       else
         rm -rf ../work-tmp/input_tmp/*.* ; rm -rf ../work-tmp/input_tmp/*
          echo -e " \e[90m All files removed from : ../work-tmp/input_tmp/ \e[32m "   
       fi     
    fi
    
 fi
 
  
echo

