. ./init.sh

run "ls /sys/class/net -l | grep pci"

run "service systemd-networkd status | head -3"
run networkctl status
run networkctl list

run ls -l /etc/systemd/network

run ls -l /etc/network/interfaces.d/
run cat /etc/network/interfaces