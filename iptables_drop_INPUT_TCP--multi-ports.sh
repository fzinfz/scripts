#!/bin/bash

if [ -z $1 ];then
	ports="3306,6379,27017:27018,81:89"
else
	ports=$1
fi

iptables -A INPUT -p tcp -m multiport --dport $ports -j DROP
iptables-save
iptables -L
