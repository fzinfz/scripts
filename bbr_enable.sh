# Manually Load and check BBR module(Optional)
modprobe tcp_bbr
lsmod | grep bbr
sysctl net.ipv4.tcp_available_congestion_control

echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p
echo reboot manaually
