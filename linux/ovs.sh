. ./init.sh
. ../lib/ovs.sh

for t in $(ovs-vsctl --help | grep "by UUID" -B1 | grep : | sed s/://); do
    echo_tip ovs-vsctl list $t
done    

run ovs-appctl ovs/route/show

run ls -l /etc/openvswitch/conf.db

run "ps -efHww | grep ovs"
run ovs-vsctl show

for ovsbr in $(ovs_br); do
    run ovs-ofctl dump-flows $ovsbr
    echo_tip ovs-vsctl --if-exists del-port $ovsbr PORT
done