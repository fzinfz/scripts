nmap--ip--port() {
    nmap -sV -p$2 $1
}

ip_addr--interface() {
    ip addr show dev $1 &>/dev/null
    if [ $? -eq 0 ]; then
        ip addr show dev $1 | grep -P -o '(?<=inet )[0-9.]+'
    fi
}

nw_ls_interface_ip(){ echo -e "$1 : $(ip_addr--interface $1)"; }
nw_ls_interfaces(){ netstat -i | grep -P '^[a-z]' | awk '{print $1}'; }
nw_ls_ip_list(){ for i in $(nw_ls_interfaces); do nw_ls_interface_ip $i; done; }

netstat_lntup_ipv4(){
    netstat -lntup | tail -n +3 | \
        perl -lane 'print "$F[3]\t$F[0]\t$F[-1]"' | awk -F '[:]*' '{ print $2 "   \t" $1 }' | \
        sort -h | grep --color "$1"
}
alias ns=netstat_lntup_ipv4

netstat_an--egrep() {
    netstat -an | egrep $1 | \
    awk '{ print $4 ":" $5 ":" $6}' | \
    awk -F':' '{ print $1 ":" $2 " ---> " $3 " - " $5 }' | \
    sort -u
}

# iptables

iptables_delete_INPUT--line() {
    iptables -D INPUT $1
    iptables-save
    iptables -L
}


iptables_delete_NAT-POSTROUTING--line() {
    iptables -t nat -D POSTROUTING $1
}

iptables_list() {
    iptables -L -n -v --line-numbers
}

iptables_log_INPUT_DROP() {
    iptables -N LOGGING
    iptables -A INPUT -j LOGGING
    iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
    iptables -A LOGGING -j DROP
}


iptables_list_NAT() {
    iptables -t nat -v -L -n --line-number
}
