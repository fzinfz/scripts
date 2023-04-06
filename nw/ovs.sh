. ../lib/nw_*.sh
. ../lib/virt.sh
. ../nw/check.sh

if ! cmd ovs-vsctl; then
    cmd apt || exit_err "only support install OVS with: apt"

    read -p "Install ovs? (y/n) " a
    [[ $a =~ [Yy] ]] && apt update && apt install -y openvswitch-switch
    [ $? -ne 0 ] && exit_err "failed installing OVS"
fi

for t in $(ovs-vsctl --help | grep "by UUID" -B1 | grep : | sed s/://); do
    echo_tip ovs-vsctl list $t
done    

run ovs-appctl ovs/route/show

run 'ls -lrth /var/log/openvswitch/* | tail'

run "ps -efHww | grep ovs --color"
run "service openvswitch-switch status | head -3"

if [ $(ovs-vsctl list-br | wc -l) -eq 0 ]; then
    ask 'Create default bridges? (skip if using netplan)'
    [[ $a =~ [Yy] ]] && ovs_add_br ovs-br0 ovs-br1
fi    

for br in $(ovs-vsctl list-br); do
    run ovs-ofctl dump-flows $br

    [ $(ovs-vsctl list-ports $br | wc -l) -eq 0 ] && \
        echo_tip ovs-vsctl add-port $br PORT
        
    [ $(ovs-vsctl list-ports $br | wc -l) -gt 0 ] && \
        echo_tip ovs-vsctl --if-exists del-port $br PORT
        
done

run ovs-vsctl show
run ovs_interfaces
virt_list_vnet
run nw_ls_ip_list

