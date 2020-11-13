SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; [ -f $SCRIPTPATH/init.sh ] && source $SCRIPTPATH/init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

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

check_bridge(){ 
    for f in $(ls /proc/sys/net/bridge/*); do printf "$f : "; cat $f; done 
    run 'ip link show type bridge'    
}

interface_list(){ ls /sys/class/net ; }

run_if_shell
