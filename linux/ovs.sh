. ./init.sh

run "ps -efHww | grep ovs"
run ovs-vsctl show
