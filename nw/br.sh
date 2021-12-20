. ./init.sh

check_bridge(){ 
    for f in $(ls /proc/sys/net/bridge/*); do printf "$f : "; cat $f; done 
    run 'ip link show type bridge'    
}

run_if_shell

run "sysctl -a | grep net.bridge.bridge-nf-call-iptables # 0"
brctl show br0 &>/dev/null && run "sysctl -a | grep net.ipv4.conf.br0.bc_forwarding # 1"
