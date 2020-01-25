check_ip_list_v4(){ ip addr | grep -P 'inet\b' -B2 ; }

iptables_list(){ iptables -L -n -v --line-numbers ; }

check_bbr(){
    tc qdisc show
    sysctl net.core.default_qdisc
    sysctl net.ipv4 | grep control
}