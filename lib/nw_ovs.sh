
ovs_add_br(){ 
    [ -z "$1" ] && echo_tip ovs_add_br BR_NAME,..
        
    for br in $@; do
        run ovs-vsctl add-br $br
        run ovs-vsctl set-fail-mode $br standalone
        ovs-vsctl set bridge $br stp_enable=true
    done
}


ovs_interfaces(){
    for i in `nw_ls_interfaces | grep ^e`; do
        ip addr show dev $i 2>/dev/null | grep ovs-system
        if [ $? -eq 0 ]; then
            ip addr show dev $i 2>/dev/null | grep LOWER_UP &>/dev/null
            [ $? -ne 0 ] && echo_tip "plug in cable & run: ip link set dev $i up"
            echo
        fi        
    done
}
