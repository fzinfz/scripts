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

install_vscode(){
	curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
	sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
	sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
	sudo apt-get update
	sudo apt-get install -y code # or code-insiders
	apt --fix-broken install -y
}