SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; 
source $SCRIPTPATH/init.sh

iptables_list(){ run 'iptables -L -n -v --line-numbers' ; }

check_bbr(){
    run 'tc qdisc show'
    run 'sysctl net.core.default_qdisc'
    run 'sysctl net.ipv4 | grep control'
}

check_network_config(){
    run 'ls /etc/network/* -l'
    [ -f /etc/network/interfaces ] && run 'cat /etc/network/interfaces | grep -v ^# | grep -v ^$'
}

check_ip_list_v4(){ run "ip addr | grep -P 'inet\b' -B2" ; }

check_netplan(){
    for d in run etc lib; do
        run "ls -l /$d/netplan 2>/dev/null"
        
        for f in $(ls /$d/netplan/* 2>/dev/null); do
            file $f | grep ASCII
            [ $? -eq 0 ] && run "cat $f" | grep -v ^# | grep -v ^$
        done
    done
    
    [ -d /etc/netplan ] && echo_tip "run 'netplan try' after editing config to apply"
}

check_bridge(){ 
    for f in $(ls /proc/sys/net/bridge/*); do printf "$f : "; cat $f; done 
    run 'ip link show type bridge'    
}

interface_list(){ ls /sys/class/net ; }

run_if_shell
