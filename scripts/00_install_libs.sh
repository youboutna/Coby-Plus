#!/bin/bash

# DATABSE : postgresql - mysql 


 while [[ "$#" > "0" ]] ; do
  case $1 in
      (*=*) KEY=${1%%=*}
            VALUE=${1#*=}
            case "$KEY" in
                ("db") DATA_BASE=$VALUE
            esac
  esac
  shift
 done    
    
 DATA_BASE=${DATA_BASE:-postgresql}


tput setaf 2
echo 
echo -e " #####################################          "
echo -e " ######### Info Install ##############          "
echo -e " -------------------------------------          "
echo -e " \e[90m$0               \e[32m                  "
echo
echo -e " \e[91m Data Base -->  "${DATA_BASE^^}" \e[32m  "
echo
echo -e " #####################################          "
echo 
sleep 0
tput setaf 7

CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRENT_DIRECTORY="scripts"
ROOT_PATH="${CURRENT_PATH/'/'$CURRENT_DIRECTORY/''}"

TMP="tmp_install"
DOCS="Docs"
EXAMPLES="Exemple"
DIRECTORY_LIBS="libs"

DIRECTORY_DATA_ONTOP="ontop"
DIRECTORY_DATA_CORESE="corese"
DIRECTORY_DATA_YEDGEN="yedGen"
DIRECTORY_DATA_CONFIG="conf"

# Do not touch the YEDGEN_COMPILE_NAME
YEDGEN_COMPILE_NAME="yedGen_2.0-1.0-SNAPSHOT-jar-with-dependencies.jar"
YEDGEN_TARGET_NAME="yedGen.jar"

# Do not touch the ONTOP_COMPILE_NAME
ONTOP_COMPILE_NAME="ontop-materializer-1.18.0-jar-with-dependencies.jar "
ONTOP_TARGET_NAME="Ontop-Materializer.jar"

# Do not touch the CORESE_COMPILE_NAME
CORESE_COMPILE_NAME="CoreseInferMaven-1.0.0-jar-with-dependencies.jar "
CORESE_TARGET_NAME="CoreseInfer.jar"

# Do not touch the CORESE_COMPILE_NAME
BLAZEGRAPH_LOCATION="Blazegraph"
BLAZEGRAPH_TARGET_NAME="blazegraph_2_1_4.jar"
BLAZEGRAPG_INFO_INSTALL="BLZ_INFO_INSTALL"

# Each program has its own documentation located in 
# $DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_ [ YEDGEN | ONTOP | CORESE ]
DOCUMENTATION_FILE_NAME="README.md"

if [ ! -d "$ROOT_PATH/$DIRECTORY_LIBS" ]; then
mkdir -p $ROOT_PATH/$DIRECTORY_LIBS
echo -e " \e[90m created folder : $ROOT_PATH/$DIRECTORY_LIBS \e[32m "
fi
if [ ! -d "$ROOT_PATH/$CURRENT_DIRECTORY/$DIRECTORY_DATA_CONFIG" ]; then
mkdir -p $ROOT_PATH/$CURRENT_DIRECTORY/$DIRECTORY_DATA_CONFIG
echo -e " \e[90m created folder : $ROOT_PATH/$CURRENT_DIRECTORY/$DIRECTORY_DATA_CONFIG \e[32m  "
fi
if [ ! -d "$ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_ONTOP" ]; then
mkdir -p $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_ONTOP
echo -e " \e[90m created folder : $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_ONTOP \e[32m  "
fi
if [ ! -d "$ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_ONTOP/$EXAMPLES" ]; then
mkdir -p $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_ONTOP/$EXAMPLES
echo -e " \e[90m created folder : $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_ONTOP/$EXAMPLES \e[32m  "
fi
if [ ! -d "$ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_CORESE" ]; then
mkdir -p $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_CORESE
echo -e " \e[90m created folder : $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_CORESE \e[32m  "
fi
if [ ! -d "$ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_CORESE/$EXAMPLES" ]; then
mkdir -p $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_CORESE/$EXAMPLES
echo -e " \e[90m created folder : $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_CORESE/$EXAMPLES \e[32m  "
fi
if [ ! -d "$ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_YEDGEN" ]; then
mkdir -p $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_YEDGEN
echo -e " \e[90m created folder : $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_YEDGEN \e[32m  "
fi
if [ ! -d "$ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_YEDGEN/$EXAMPLES" ]; then
mkdir -p $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_YEDGEN/$EXAMPLES
echo -e " \e[90m created folder : $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_YEDGEN/$EXAMPLES \e[32m  "
fi
if [ ! -d "$ROOT_PATH/$DIRECTORY_LIBS/$BLAZEGRAPH_LOCATION" ]; then
mkdir -p $ROOT_PATH/$DIRECTORY_LIBS/$BLAZEGRAPH_LOCATION
echo -e " \e[90m created folder : $ROOT_PATH/$DIRECTORY_LIBS/$BLAZEGRAPH_LOCATION \e[32m  "
fi

rm -rf $ROOT_PATH/$DIRECTORY_LIBS/$TMP

#######################
#### Install yedGen ###
#######################

tput setaf 2
echo 
echo " ###########################                                               "
echo " ##### Install yedGen ######                                               "
echo 
echo -e "\e[90m Location : $ROOT_PATH/$DIRECTORY_LIBS/$YEDGEN_TARGET_NAME \e[32m "
echo
echo " ###########################                                               "
echo 
sleep 2
tput setaf 7

git clone https://github.com/rac021/yedGen.git $ROOT_PATH/$DIRECTORY_LIBS/$TMP

cd $ROOT_PATH/$DIRECTORY_LIBS/$TMP

mvn clean install assembly:single 

echo 

mv -fv $ROOT_PATH/$DIRECTORY_LIBS/$TMP/target/$YEDGEN_COMPILE_NAME \
       $ROOT_PATH/$DIRECTORY_LIBS/$YEDGEN_TARGET_NAME

mv -fv $ROOT_PATH/$DIRECTORY_LIBS/$TMP/$DOCUMENTATION_FILE_NAME \
       $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_YEDGEN

rm -rf $ROOT_PATH/$DIRECTORY_LIBS/$TMP/* $ROOT_PATH/$DIRECTORY_LIBS/$TMP/.git


##################################
### Install Ontop-Materializer ###
##################################

tput setaf 2
echo "                                    "
echo " ##################################                                       "
echo " ### Install Ontop-Materializer ###                                       "
echo
echo -e " \e[91m Database -->  "${DATA_BASE^^}" \e[32m                          "
echo
echo -e "\e[90m Location : $ROOT_PATH/$DIRECTORY_LIBS/$ONTOP_TARGET_NAME \e[32m "
echo
echo " ##################################                                       "
echo "                                                                          "

echo
 
sleep 2
tput setaf 7

git clone https://github.com/rac021/ontop-matarializer.git $ROOT_PATH/$DIRECTORY_LIBS/$TMP

cd $ROOT_PATH/$DIRECTORY_LIBS/$TMP

 if [ "$DATA_BASE" != "" ] ; then 
     mvn -P $DATA_BASE clean install assembly:single
 else 
     # Postresql as default database
     mvn clean install assembly:single
 fi

echo

mv -fv $ROOT_PATH/$DIRECTORY_LIBS/$TMP/target/$ONTOP_COMPILE_NAME \
       $ROOT_PATH/$DIRECTORY_LIBS/$ONTOP_TARGET_NAME
      
mv -fv $ROOT_PATH/$DIRECTORY_LIBS/$TMP/$ONTOP_EXP_LOCATION \
       $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_ONTOP/$EXAMPLES
  
mv -fv $ROOT_PATH/$DIRECTORY_LIBS/$TMP/$DOCUMENTATION_FILE_NAME \
       $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_ONTOP
   
rm -rf  $ROOT_PATH/$DIRECTORY_LIBS/$TMP/* $ROOT_PATH/$DIRECTORY_LIBS/$TMP/.git

##################################
###### Install CoreseInfer #######
##################################

tput setaf 2
echo 
echo " ###########################                                                "
echo " ### Install CoreseInfer ###                                                "
echo
echo -e "\e[90m Location : $ROOT_PATH/$DIRECTORY_LIBS/$CORESE_TARGET_NAME \e[32m  "
echo
echo " ###########################                                                "
echo 
sleep 2
tput setaf 7

git clone https://github.com/rac021/CoreseInfer.git $ROOT_PATH/$DIRECTORY_LIBS/$TMP

cd $ROOT_PATH/$DIRECTORY_LIBS/$TMP

mvn clean install assembly:single

echo

mv -fv $ROOT_PATH/$DIRECTORY_LIBS/$TMP/target/$CORESE_COMPILE_NAME \
       $ROOT_PATH/$DIRECTORY_LIBS/$CORESE_TARGET_NAME

mv -fv $ROOT_PATH/$DIRECTORY_LIBS/$TMP/$DOCUMENTATION_FILE_NAME \
       $ROOT_PATH/$DIRECTORY_LIBS/$DOCS/$DIRECTORY_DATA_CORESE

rm -rf $ROOT_PATH/$DIRECTORY_LIBS/$TMP/* $ROOT_PATH/$DIRECTORY_LIBS/$TMP/.git


##################################
###### Install Blazegprah  #######
##################################

tput setaf 2
echo 
echo " ###########################                                                                        "
echo " ### Install Blazegraph  ###                                                                        "
echo
echo -e "\e[91m Version --> 2.1.4 \e[32m                                                                  "
echo
echo -e "\e[90m Location : $ROOT_PATH/$DIRECTORY_LIBS/$BLAZEGRAPH_LOCATION/$BLAZEGRAPH_TARGET_NAME \e[32m "
echo
echo " ###########################                                                                        "
echo 
sleep 2
tput setaf 7

wget https://raw.githubusercontent.com/rac021/blazegraph_libs/master/blazegraph_2_1_4.jar -O $ROOT_PATH/$DIRECTORY_LIBS/$BLAZEGRAPH_LOCATION/$BLAZEGRAPH_TARGET_NAME

echo "../$DIRECTORY_LIBS/$BLAZEGRAPH_LOCATION/$BLAZEGRAPH_TARGET_NAME" >  $ROOT_PATH/$CURRENT_DIRECTORY/$DIRECTORY_DATA_CONFIG/$BLAZEGRAPG_INFO_INSTALL

#########################
#### Clean TMP folder ###
#########################

rm -rf $ROOT_PATH/$DIRECTORY_LIBS/$TMP/


tput setaf 2
echo 
echo " ###  Coby successfully installed ########## "
echo 
sleep 2
tput setaf 7

