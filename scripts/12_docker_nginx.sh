#/bin/bash

 DEFAULT_IP=${2:-"192.168.56.110"}
 SUBNET=${3:-"mynet123"}
 SUBNET_RANGE=${4:-"192.168.56.250/24"}
 DEFAULT_PORT=${5:-"80"}
 LOCAL_IP=${6:-"127.0.0.1"}
 IMAGE_NAME=${7:-"nginx-ecoinformatics"}
 HOST=${8:-"ecoinformatics.org"}
 FOLDER_DOCKER_FILE=${9:-"docker"}
 

 CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
 
 cd $CURRENT_PATH/$FOLDER_DOCKER_FILE

 removeContainerBasedOnImage() {
   IMAGE=$1
   echo
   echo -e " Remove container based on image  $IMAGE "
   docker ps -a | awk '{ print $1,$2 }' | grep $IMAGE | awk '{print $1 }' | xargs -I {} docker rm -f {}
   echo -e " Containers removed !! "
   echo
 } 
    
 if [ "$1" = "start" ] ; then 
 
    SUBNET_CHECK=`docker network ls | grep $SUBNET`
    
    if [[ "${SUBNET_CHECK}" == *$SUBNET* ]]; then
           echo
           echo " subnet - $SUBNET - already exists "
    else
           echo " create subnet $SUBNET "
           docker network create --subnet=$PLAGE_SUBNET $SUBNET 
           # docker network rm $SUBNET
    fi
    
    if docker history -q $IMAGE_NAME >/dev/null 2>&1 ; then

        sudo service apache2 stop
        
        removeContainerBasedOnImage $IMAGE_NAME       
        
    else 
    
        docker build -t $IMAGE_NAME .
    
    fi 
    
    fuser -k $DEFAULT_PORT/tcp
    LINE="$LOCAL_IP $HOST"

    if grep -Fxq "#$LINE" /etc/hosts ; then
       sudo sed --in-place '/#$LINE/d' /etc/hosts
    fi    
    if ! grep -Fxq "$LINE" /etc/hosts ; then
       sudo -- sh -c "echo '$LINE' >> /etc/hosts"
    fi
    
    docker run -d --net $SUBNET --name $HOST --ip $DEFAULT_IP -p $DEFAULT_PORT:$DEFAULT_PORT $IMAGE_NAME
    
 fi
 
 if [ "$1" = "stop" ] ; then 

    removeContainerBasedOnImage $IMAGE_NAME
    
    sudo sed --in-place '/$LINE/d' /etc/hosts
   
 fi
 
