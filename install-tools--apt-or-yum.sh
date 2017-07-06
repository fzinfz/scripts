#!/bin/bash

$1 update 

if [ "$1" = "apt" ];then
	apt install -y apt-utils
fi

if [ "$1" = "yum" ];then
	yum install -y epel-release
fi

$1  install -y \
    software-properties-common python-software-properties \
    net-tools bridge-utils dnsutils tcpdump  mtr nmap nethogs traceroute bmon iputils-ping nload iftop \
    locate ncdu vim aria2 curl wget htop git pciutils unzip \
    iperf3 sysbench

