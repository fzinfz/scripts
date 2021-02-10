. ./init.sh

check_bbr(){
    run 'sysctl net.core.default_qdisc'
    run 'sysctl net.ipv4 | grep control'
}

check_netplan(){
    for d in run etc lib; do
        ls -l /$d/netplan 2>/dev/null
        
        for f in $(ls /$d/netplan/* 2>/dev/null); do
            file $f | grep ASCII
            [ $? -eq 0 ] && run "cat $f" | grep -v ^# | grep -v ^$
        done
    done
    
    [ -d /etc/netplan ] && echo_tip "run 'netplan try' after editing config to apply"
}

check_etc_network_interfaces(){
    run 'ls /etc/network/interfaces.d/ -l';
    
    [ -f /etc/network/interfaces ] && \
        run 'cat /etc/network/interfaces | grep -v ^# | grep -v ^$'
}

check_ip_list_v4(){ run "ip addr | grep -P 'inet\b' -B2" ; }

lshw_net(){ run 'lshw -short -C network | grep ^\/0' ; }
ls_net(){ run ls /sys/class/net ; }

run_if_shell

netstat_lntup_ipv4