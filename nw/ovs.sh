. ../lib/nw_*.sh
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

run "ps -efHww | grep ovs"
run service openvswitch-switch status

if [ $(ovs-vsctl list-br | wc -l) -eq 0 ]; then
    ask 'Create default bridges?'
    [[ $a =~ [Yy] ]] && ovs_add_br br0 br1
fi    

run ovs-vsctl show

for br in $(ovs-vsctl list-br); do
    run ovs-ofctl dump-flows $br

    [ $(ovs-vsctl list-ports $br | wc -l) -eq 0 ] && \
        echo_tip ovs-vsctl add-port $br PORT
        
    [ $(ovs-vsctl list-ports $br | wc -l) -gt 0 ] && \
        echo_tip ovs-vsctl --if-exists del-port $br PORT
        
done

lshw_net
ls_net
check_ip_list_v4

run 'ls -lrth /var/log/openvswitch/*'