#!/bin/bash

if [ -z ${1+x} ] ;then
	cat /root/.bash_history
else
	cat /root/.bash_history | tail -n$1
fi 

echo "if history items missing, run init_bashrc.sh first."
