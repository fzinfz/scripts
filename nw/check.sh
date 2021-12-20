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

check_nmcli(){
    if cmd nmcli; then
        run nmcli connection
        IFS=$'\n' connections=( $(nmcli -g name connection show | fgrep -v "br-" ) )
        for i in ${connections[@]}; do
            run "nmcli conn show '$i' | egrep 'ipv4.method|autoconnect:'"
            nmcli conn show "$i" | fgrep 'connection.autoconnect:' | grep yes &>/dev/null
            [ $? -eq 0 ] && \
                echo_tip "nmcli connection modify '$i' connection.autoconnect no" || \
                echo_tip "nmcli connection modify '$i' connection.autoconnect yes"            
        done
    fi
}

run_if_shell

run netstat_lntup_ipv4

echo_tip 'tc qdisc show'