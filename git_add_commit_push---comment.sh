#!/bin/bash

if [ -z $1 ];then
	c='update'
else
	c=$1
fi

git add -A 
git commit -am "$c"
git push 
