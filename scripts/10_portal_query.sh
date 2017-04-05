#!/bin/bash

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
    
 
  if [ "$1" == "-h" ] ; then  
     echo
     echo "  Script takes 1 or 5 arguments      "
     echo
     echo "    if 1 Argument :                  "
     echo "       \$_1 :  QUERY_PATH            "
     echo
     echo "    if 5 Arguments :                 "
     echo "       \$_1 :  IP                    "
     echo "       \$_2 :  PORT                  "
     echo "       \$_3 :  NAMESPACE             "
     echo "       \$_4 :  QUERY_PATH            "
     echo "       \$_5 :  OUT_RESULT            "
     EXIT
  fi
    
    
  CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd $CURRENT_PATH
  
  if [ $# -eq 2 ] ; then
      
    QUERY_PATH="$1"
    OUT="$2" 
    
    if [ ! -f $QUERY_PATH ]  ; then
    echo
    echo -e "\e[91m Missing  $QUERY_PATH  ! \e[39m "
    EXIT
    fi
    
    NANO_END_POINT_FILE="$CURRENT_PATH/conf/nanoEndpoint"
    LINE=$(head -1 $NANO_END_POINT_FILE)
    
    IFS=$' \t\n' read -ra INFO_NANO <<< "$LINE" 
    IP=${INFO_NANO[0]}
    NAMESPACE=${INFO_NANO[1]}
    PORT=${INFO_NANO[2]}       

  elif [ $# -eq 5 ] ; then
    IP=$1
    PORT=$2
    NAMESPACE=$3
    QUERY_PATH=$4
    OUT=$5
       
  else 
    echo
    echo -e "\e[91m 2 or 5 arguments ( QUERY_PATH - OUT_RESULT / IP - PORT - NAMESAPCE - QUERY_PATH - OUT_RESULT ) ! \e[39m "
    echo
    EXIT
  fi
	
  PREFIX_ENDPOINT="http://$IP:$PORT"
  SUFFIX_ENDPOINT="blazegraph/namespace/$NAMESPACE/sparql"
  
  ENDPOINT=$PREFIX_ENDPOINT/$SUFFIX_ENDPOINT
  
  # Test connexion to namespace 
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
      exit 3
             
    fi
           
  done
        
  RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
        
  COUNT=0
        
  while  [ -z $RES ] || [ $RES -ne 200 ] ;do
        
    sleep 1
    
    RES=`curl -s -I $ENDPOINT | grep HTTP/1.1 | awk {'print $2'}`
    
    let "COUNT++" 
    
    if  [ -z $RES ] || [ $RES -ne 200 ]  ; then 
    
        if [ `expr $COUNT % 3` -eq 0 ] ; then
              echo -e " attempt to contact $ENDPOINT .. "
        fi
    fi
           
  done
       
  echo " Yeah Connected !! "
  
  tput setaf 2
  echo 
  echo -e " ######################################################## "
  echo -e " ######## Info Synthesis ################################ "
  echo -e " -------------------------------------------------------- "
  echo -e " \e[90m$0       \e[32m                                    "
  echo
  echo -e " # ENDPOINT   : $PREFIX_ENDPOINT                          "
  echo -e " # NAMESAPCE  : $NAMESPACE                                "
  echo -e " # QUERY_PATH : $QUERY_PATH                               "
  echo -e " # OUT        : $OUT                                      "
  echo
  echo -e " ######################################################## "
  echo 
  sleep 1
  tput setaf 7
     

  if [ ! -f $QUERY_PATH ]  ; then
      echo
      echo -e "\e[91m Missing $QUERY_PATH ! \e[39m "
      EXIT
  fi
        
  QUERY=`cat $QUERY_PATH`
  
  curl -X POST $ENDPOINT/namespace/$NAMESPACE/sparql --data-urlencode 'query= '"$QUERY"' ' -H ' Accept: text/rdf+n3' > $OUT
  
  echo ; echo 

  portail_query='
    PREFIX : <http://www.anaee-france.fr/ontology/anaee-france_ontology#> 
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
    PREFIX oboe-core: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-core.owl#> 
    PREFIX oboe-standard: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-standards.owl#>
    PREFIX oboe-temporal: <http://ecoinformatics.org/oboe/oboe.1.0/oboe-temporal.owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
  
  	SELECT ?infraName
  	       ?site 
  	       ?anaeeSiteName
  	       ?localSiteName 
  	       ?siteType 
  	       ?siteTypeName 
  	       ?category 
  	       ?categoryName
  	       ?variable 
  	       ?anaeeVariableName
  	       ?localVariableName 
  	       ?unit 
  	       ?anaeeUnitName
  	       ?year 
  	       ?nbData 
  	          
  	WHERE  {  
      		    
		?idVariableSynthesis   a                     :Variable            .
			    
		?idVariableSynthesis  :ofVariable            ?variable            .
		#?variable            :hasCategory           ?category            .
                ?idVariableSynthesis  :hasCategory           ?category            .
		?variable             :hasAnaeeVariableName  ?anaeeVariableName   .
		?variable             :hasLocalVariableName  ?localVariableName   .
		?variable             :hasUnit               ?unit                .
			 
		?unit                 :hasAnaeeUnitName      ?anaeeUnitName       .
			     
		?category             :hasCategoryName       ?categoryName        .
		?idVariableSynthesis  :hasSite               ?site                .
		?site	              :hasLocalSiteName      ?localSiteName       . 
		?site		      :hasAnaeeSiteName      ?anaeeSiteName       .           
		?site		      :hasSiteType           ?siteType            .
		?site		      :hasSiteTypeName       ?siteTypeName        .
		?site		      :hasInfra              ?infra               .
		?infra                :hasInfraName          ?infraName           .
		?idVariableSynthesis  :hasNbData             ?nbData              .
		?idVariableSynthesis  :hasYear               ?year                .
  }
  		    
  ORDER BY ?site ?year  '
  		    
