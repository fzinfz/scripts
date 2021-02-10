. ../linux/init.sh

nmap--ip--port() {
    nmap -sV -p$2 $1
}

ip_addr--interface() {
    ifconfig $1 | grep -P -o '(?<=inet )[0-9.]+'
}

netstat_lntup_ipv4(){
    netstat -lntup | tail -n +3 | grep LISTEN | \
        perl -lane 'print "$F[3]\t$F[0]\t$F[-1]"' | grep -v ^: | sort | grep --color "$1"
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