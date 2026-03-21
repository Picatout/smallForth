#!/bin/bash

if [ "$1" == "l151" ] ; then 
    make -fstm8l151k6.mk $2 $3
else
    if [ "$1" == "s103" ] ; then  
    make -fstm8s103f3.mk $2 $3
    fi 
fi 



