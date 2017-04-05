#!/bin/bash
 
  USER="anaee_user"
  PASSWORD="anaee_user"
  DATABASE="anaee_db"
  TABLE="physicochimiebysitevariableyear"
  
  
  tput setaf 2
   echo 
   echo -e " ##################################### "
   echo -e " ######### Create DataBase ########### "
   echo -e " ------------------------------------- "
   echo -e " \e[90m$0        \e[32m                "
   echo 
   echo -e " ##  USER      : $USER                 "
   echo -e " ##  PASSWORD  : $PASSWORD             "
   echo -e " ##  DATABASE  : $DATABASE             "
   echo -e " ##  TABLE     : $TABLE                "
   echo
   echo -e " ##################################### "
   echo 
   sleep 2
   tput setaf 7

    
  sudo -u postgres psql  2> /dev/null << EOF
  
  DROP  DATABASE $DATABASE ;
  DROP  USER     $USER     ;
 
  CREATE DATABASE $DATABASE TEMPLATE template0 ; 
  CREATE USER $USER WITH PASSWORD '$PASSWORD'  ;
  
  \connect $DATABASE ;  

  CREATE TABLE $TABLE (
	site_code      	varchar(255) ,
	site_name      	varchar(255) ,
	datatype_code 	varchar(255) , 
	datatype_name 	varchar(255) ,
	variable_code 	varchar(255) ,
	variable_name 	varchar(255) , 
	unite_id        varchar(255) ,
	unite_code      varchar(255) ,
	unite_name      varchar(255) ,
	year 	        varchar(255) ,
	nb_data         integer      ,
	
	CONSTRAINT pk_site_datatype_variable PRIMARY KEY (site_code, datatype_code, variable_code )
  
  ) ;

  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_01', 's_name_01', 'dtype_code_01', 'dtype_name_01', 'var_code_01', 'var_name_01', 'uni_id_01', 'uni_code_01','uni_name_01', '06-09-2001', 21) ;
  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_02', 's_name_02', 'dtype_code_02', 'dtype_name_02', 'var_code_02', 'var_name_02', 'uni_id_02', 'uni_code_02','uni_name_02', '06-09-2002', 81) ;
  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_03', 's_name_03', 'dtype_code_03', 'dtype_name_03', 'var_code_03', 'var_name_03', 'uni_id_03', 'uni_code_03','uni_name_03', '06-09-2003', 75) ;
  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_04', 's_name_04', 'dtype_code_04', 'dtype_name_04', 'var_code_04', 'var_name_04', 'uni_id_04', 'uni_code_04','uni_name_04', '06-09-2004', 20) ;
  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_05', 's_name_05', 'dtype_code_05', 'dtype_name_05', 'var_code_05', 'var_name_05', 'uni_id_05', 'uni_code_05','uni_name_05', '06-09-2005', 56) ;
  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_06', 's_name_06', 'dtype_code_06', 'dtype_name_06', 'var_code_06', 'var_name_06', 'uni_id_06', 'uni_code_06','uni_name_06', '06-09-2006', 64) ;
  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_07', 's_name_07', 'dtype_code_07', 'dtype_name_07', 'var_code_07', 'var_name_07', 'uni_id_07', 'uni_code_07','uni_name_07', '06-09-2007', 94) ;
  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_08', 's_name_08', 'dtype_code_08', 'dtype_name_08', 'var_code_08', 'var_name_08', 'uni_id_08', 'uni_code_08','uni_name_08', '06-09-2008', 20) ;
  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_09', 's_name_09', 'dtype_code_09', 'dtype_name_09', 'var_code_09', 'var_name_09', 'uni_id_09', 'uni_code_09','uni_name_09', '06-09-2009', 21) ;
  INSERT INTO physicochimiebysitevariableyear VALUES ('s_code_10', 's_name_10', 'dtype_code_10', 'dtype_name_10', 'var_code_10', 'var_name_10', 'uni_id_10', 'uni_code_10','uni_name_10', '06-09-2010', 69) ;

  GRANT SELECT ON $TABLE to $USER ;	

EOF

