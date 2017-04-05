#!/bin/bash
 
    ./main.sh  ip=localhost               \
               namespace=foret            \
               ro=8888                    \
               rw=7777                    \
               si=FORET                   \
               db=postgresql              \
      	       ext_obda=obda              \
               ext_graph=graphml          \
               class_file_name=class.txt  
