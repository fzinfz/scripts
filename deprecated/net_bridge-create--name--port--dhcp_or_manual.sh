#!/bin/bash

ip link add name $1 type bridge
ip link set $1 up
ip link set $2 up
ip link set $2 master $1

if [ -z $3 ];then
	dhclient $1 -v
	type=dhcp
else
	type=manual
fi

bridge link
brctl show

cat >> /etc/network/interfaces << EOL

iface $1 inet $type
    bridge_ports $2
EOL

echo "Modify \"/etc/network/interfaces\" and run \"service networking reload; ifup $1 \""
