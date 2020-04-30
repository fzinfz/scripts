SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; [ -f $SCRIPTPATH/init.sh ] && source $SCRIPTPATH/init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

iptables_list(){ iptables -L -n -v --line-numbers ; }

check_ip_list_v4(){ ip addr | grep -P 'inet\b' -B2 ; }

check_bbr(){
    run 'tc qdisc show'
    run 'sysctl net.core.default_qdisc'
    run 'sysctl net.ipv4 | grep control'
}

run_if_shell