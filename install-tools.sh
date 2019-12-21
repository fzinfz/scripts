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
    unzip locate ncdu aria2 curl wget git gettext jq tmux mc \
    software-properties-common \
    inxi nmon htop pciutils lsof numactl \
    net-tools bridge-utils bmon iputils-ping nload iftop cifs-utils nfs-common \
    dnsutils tcpdump mtr nmap nethogs traceroute 

    # iperf3 sysbench sysstat \
#    trickle wondershaper 

# fio vim
