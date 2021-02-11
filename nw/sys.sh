. ./init.sh

check_bridge(){ 
    for f in $(ls /proc/sys/net/bridge/*); do printf "$f : "; cat $f; done 
    run 'ip link show type bridge'    
}

run_if_shell

run 'tc qdisc show'