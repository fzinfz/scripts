. ../linux/init.sh

ovs_add_br(){ 
    for br in $@; do
        run ovs-vsctl add-br $br
        run ovs-vsctl set-fail-mode $br standalone
        ovs-vsctl set bridge $br stp_enable=true
    done
}
