#!/bin/bash

if [ -z $1 ];then
	netstat -lntup
else
	netstat -an | egrep $1 | awk '{ print $5 ":" $6}' | awk -F':' '{ print $1 ":" $3 }' | sort -u
fi
