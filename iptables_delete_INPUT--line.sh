iptables -D INPUT $1
iptables-save
iptables -L
