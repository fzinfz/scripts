#!/bin/bash

path=$1 #example: \\\\ip\\folder
mount_point=$2

if [ -z $3 ]; then
	user=administrator
else	
	user=$3
fi

passwd=$4

mount -t cifs $path $mount_point -o username=$user,password=$passwd
