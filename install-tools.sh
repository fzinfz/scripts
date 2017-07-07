#!/bin/bash

if command -v apt >/dev/null 2>/dev/null; then
	c=apt
elif command -v yum >/dev/null 2>/dev/null; then
	c=yum
else
	echo "only apt & yum supported"
	exit
fi

if [ "$c" = "apt" ];then
	apt update
	apt install -y apt-utils
elif [ "$c" = "yum" ];then
	yum update -y
	yum install -y epel-release
fi

$c  install -y \
    software-properties-common \
    inxi htop pciutils \
    iperf3 sysbench \
    unzip \
    net-tools bridge-utils bmon iputils-ping nload iftop \
    dnsutils tcpdump mtr nmap nethogs traceroute \
    trickle wondershaper \
    cifs-utils nfs-common \
    locate ncdu vim aria2 curl wget git
