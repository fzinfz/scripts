. ./init.sh

enable_bbr_temp(){
    modprobe tcp_bbr
    lsmod | grep bbr
    sysctl net.ipv4.tcp_available_congestion_control
}

enable_bbr_perm(){
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
    echo reboot manaually
}

run_if_shell
check_bbr