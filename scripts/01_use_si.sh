#!/bin/bash

INFO_SI_FILE="SELECTED_SI_INFO"
 
SI="" 

CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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
      (*=*)  KEY=${1%%=*}
             VALUE=${1#*=}
             case "$KEY" in
                ("si")  SI=$VALUE 
             esac
             ;;
      help)  echo
	     echo " Total Arguments : One                              "
             echo
	     echo "   si=  :  SI Directory Configuration. Ex : si=mySi "
	     echo
             EXIT;    
  esac
  shift
 done    
    
 SI=${SI:-""}


if [ ! -d "$PARENT_DIR/SI" ]; then
echo
echo -e " \e[91m Error : Folder  [$PARENT_DIR/SI] with all configuration must exists \e[32m "
EXIT
fi

if [ ! -d "$PARENT_DIR/SI/$SI" ]; then
echo
echo -e " \e[91m Error : Folder [$SI] with all configuration must exists in Directory : $PARENT_DIR/SI \e[32m "
EXIT
echo
fi

tput setaf 2
echo 
echo -e " #####################################              "
echo -e " ############  Info SI  ##############              "
echo -e " -------------------------------------              "
echo -e " \e[90m$0               \e[32m                      "
echo
echo -e " \e[91m SI NAME     -->  $SI \e[32m                 "
echo -e " \e[91m SI LOCATION -->  $PARENT_DIR/SI/$SI \e[32m  "

echo
echo -e " #####################################              "
echo 

sleep 0
tput setaf 7
echo

if [ "$SI" == "" ] ; then 

    if [ ! -d "$PARENT_DIR/SI/output" ]; then
    mkdir -p $PARENT_DIR/SI/output
    echo -e " \e[90m created folder : $PARENT_DIR/SI/output \e[32m "
    fi

    if [ ! -d "$PARENT_DIR/SI/output/01_obda" ]; then
    mkdir -p $PARENT_DIR/SI/$SI/output/01_obda
    echo -e " \e[90m created folder : $PARENT_DIR/SI/output/01_obda \e[32m "
    fi

    if [ ! -d "$PARENT_DIR/SI/output/02_ontop" ]; then
    mkdir -p $PARENT_DIR/SI/output/02_ontop
    echo -e " \e[90m created folder : $PARENT_DIR/SI/output/02_ontop \e[32m "
    fi

    if [ ! -d "$PARENT_DIR/SI/output/03_corese" ]; then
    mkdir -p $PARENT_DIR/SI/$SI/output/03_corese
    echo -e " \e[90m created folder : $PARENT_DIR/SI/output/03_corese \e[32m "
    fi

    if [ ! -d "$PARENT_DIR/SI/output/04_synthesis" ]; then
    mkdir -p $PARENT_DIR/SI/$SI/output/04_synthesis
    echo -e " \e[90m created folder : $PARENT_DIR/SI/output/04_synthesis \e[32m "
    fi
       
    echo $PARENT_DIR/SI > $CURRENT_PATH/conf/$INFO_SI_FILE

else 

    if [ ! -d "$PARENT_DIR/SI/$SI/output" ]; then
    mkdir -p $PARENT_DIR/SI/$SI/output
    echo -e " \e[90m created folder : $PARENT_DIR/SI/$SI/output \e[32m "
    fi

    if [ ! -d "$PARENT_DIR/SI/$SI/output/01_obda" ]; then
    mkdir -p $PARENT_DIR/SI/$SI/output/01_obda
    echo -e " \e[90m created folder : $PARENT_DIR/SI/$SI/output/01_obda \e[32m "
    fi

    if [ ! -d "$PARENT_DIR/SI/$SI/output/02_ontop" ]; then
    mkdir -p $PARENT_DIR/SI/$SI/output/02_ontop
    echo -e " \e[90m created folder : $PARENT_DIR/SI/$SI/output/02_ontop \e[32m "
    fi

    if [ ! -d "$PARENT_DIR/SI/$SI/output/03_corese" ]; then
    mkdir -p $PARENT_DIR/SI/$SI/output/03_corese
    echo -e " \e[90m created folder : $PARENT_DIR/SI/$SI/output/03_corese \e[32m "
    fi

    if [ ! -d "$PARENT_DIR/SI/$SI/output/04_synthesis" ]; then
    mkdir -p $PARENT_DIR/SI/$SI/output/04_synthesis
    echo -e " \e[90m created folder : $PARENT_DIR/SI/$SI/output/04_synthesis \e[32m "
    fi
    
    echo $PARENT_DIR/SI/$SI > $CURRENT_PATH/conf/$INFO_SI_FILE
fi

    if [ ! -d "$PARENT_DIR/work-tmp" ]; then
    mkdir -p $PARENT_DIR/work-tmp
    echo -e " \e[90m created folder : $PARENT_DIR/work-tmp \e[32m "
    fi
    
    if [ ! -d "$PARENT_DIR/work-tmp/obda_tmp" ]; then
    mkdir -p $PARENT_DIR/work-tmp/obda_tmp
    echo -e " \e[90m created folder : $PARENT_DIR/PARENT_DIR/work-tmp/obda_tmp \e[32m "
    fi
    
    if [ ! -d "$PARENT_DIR/work-tmp/input_tmp" ]; then
    mkdir -p $PARENT_DIR/work-tmp/input_tmp
    echo -e " \e[90m created folder : $PARENT_DIR/work-tmp/input_tmp \e[32m "
    fi


echo

