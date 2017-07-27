#!/bin/bash

# make sure single quoted network path, eg: '\\server\folder'

path=$1

mount_point=$2

if [ -z $3 ]; then
	user=administrator
else	
	user=$3
fi

passwd=$4

#mount -t cifs $path $mount_point -o username=$user,password=$passwd

echo $path $mount_point cifs username=$user,password=$passwd 0 0 >>  /etc/fstab
mount -a


