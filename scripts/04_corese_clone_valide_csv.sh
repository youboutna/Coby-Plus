#!/bin/bash
  
  RELATIVE_PATH_OWL="ontology/ontology.owl"
  DEFAULT_XMS="-Xms2g"
  DEFAULT_XMX="-Xmx2g"
 
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

  
   while [[ "$#" > "0" ]] ; do
     case $1 in
         (*=*) eval $1 2> /dev/null ;
               KEY=${1%%=*}
               VALUE=${1#*=}		
               case "$KEY" in
                    ("owl")              OWL=$VALUE                    
                    ;;
                    ("csv")              CSV=$VALUE
                    ;;                     
                    ("out")              OUT=$VALUE
                    ;;
                    ("prefix_file")      PREFIX=$VALUE
		    ;;
		    ("csv_sep")          CSV_SEP=$VALUE
		    ;;
		    ("intra_separators") SEPARATOR=$VALUE
		    ;; 
		    ("columns")          COLUMNS=$VALUE
	            ;;
    		    ("xms")              XMS=$VALUE
		    ;;
		    ("xmx")              XMX=$VALUE
               esac
         ;;
         help)  echo
		echo " Total Arguments : Eight                                                                                      "
                echo
		echo "   owl=              : Ontology path file                                                                     "
		echo "   csv=              : CSV to validate                                                                        "
		echo "   out=              : output valide fale                                                                     "
		echo "   prefix_file=      : File containing Prefixes                                                               "
		echo '   intra_separators= : Intra column separator - Ex : intra_separators="-separator > -separator < -separator ,"'
		echo '   columns=          : Columns to validate - Ex : columns="-column 0 -column 10"                              '
		echo "   xms=              : Ex  xms=-Xms512m                                                                       "
		echo "   xmx=              : Ex  xms=-Xmx2g                                                                         "
	
		echo
                EXIT;
	 ;;
     esac
     shift
    done   

  OWL=${OWL:-"$PARENT_SI/$RELATIVE_PATH_OWL"}
  CSV=${CSV:-"$SI/csv/semantic_si.csv"}
  OUT=${OUT:-"$SI/csv/si.csv"}
  PREFIX=${PREFIX:-"$PARENT_SI/ontology/prefix.txt"}
  CSV_SEP=${CSV_SEP:-";"}  
  SEPARATOR=${SEPARATOR:-" -separator , -separator < -separator >"}
  COLUMNS=${COLUMNS:-" -column 0 -column 1 -column 2 -column 4 -column 6 -column 8  -column 10 "}
  XMS=${XMS:-"$DEFAULT_XMS"}
  XMX=${XMX:-"$DEFAULT_XMX"}

  tput setaf 2
  echo 
  echo -e " ######################################################### "
  echo -e " ######## Info CSV Validator ############################# "
  echo -e " --------------------------------------------------------- "
  echo -e "\e[90m$0        \e[32m                                     "
  echo
  echo -e " ##  OWL                 : $OWL                            "  
  echo -e " ##  PREFIX File         : $PREFIX                         "
  echo -e " ##  CSV to validate     : $CSV                            "
  echo -e " ##  COLUMNS to validate : $COLUMNS                        "
  echo -e " ##  CSV_SEP             : $CSV_SEP                        "    
  echo -e " ##  INTRA_SEPARATORS    : $SEPARATOR                      "  
  echo -e " ##  OUTPUT Valide CSV   : $OUT                            "
  echo
  echo -e " ##  XMS                 : $XMS                            "
  echo -e " ##  XMX                 : $XMX                            "
  echo

  echo -e " ######################################################### "
  echo 
  sleep 1
  tput setaf 7
  
  if [ ! -f $OWL ] ; then
     echo -e "\e[91m Missing OWL File [[ $OWL ]] ! \e[39m "
     EXIT
  fi

    
  if [ ! -f $PREFIX ] ; then
     echo -e "\e[91m Missing PREFIX File [[ $PREFIX ]] ! \e[39m "
     EXIT
  fi
  
  
  echo -e "\e[90m Strating Generation... \e[39m "
  echo

  
  java  $XMS  $XMX  -cp ../libs/CoreseInfer.jar corese.csv.Prefixer \
        -ontology   "$OWL"                                          \
        -csv        "$CSV"                                          \
        -outCsv     "$OUT"                                          \
        -prefix     "$PREFIX"                                       \
        -csv_sep    "$CSV_SEP"                                      \
        $SEPARATOR                                                  \
        $COLUMNS 
  
  echo 
  echo -e "\e[36m Valide CSV Generated at : $OUT \e[39m "
  echo
        
