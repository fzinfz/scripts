#!/bin/bash

if command -v apt >/dev/null 2>/dev/null; then
	$c=apt
elif command -v yum >/dev/null 2>/dev/null; then
	$c=yum
else
	echo "only apt & yum supported"
	exit
fi

$c update 

if [ "$c" = "apt" ];then
	apt install -y apt-utils
elif [ "$c" = "yum" ];then
	yum install -y epel-release
fi

$c  install -y \
    software-properties-common \
    net-tools bridge-utils dnsutils tcpdump  mtr nmap nethogs traceroute bmon iputils-ping nload iftop \
    trickle wondershaper \
    cifs-utils nfs-common \
    locate ncdu vim aria2 curl wget htop git pciutils unzip \
    iperf3 sysbench

