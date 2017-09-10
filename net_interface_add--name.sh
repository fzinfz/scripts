cat >> /etc/network/interfaces << EOL
auto $1
iface $1 inet dhcp
EOL

service networking restart
service networking status
