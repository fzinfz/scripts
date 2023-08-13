. ./init.sh

check_lvm(){
    run 'pvs -o+pv_used,vg_uuid,UUID'
    
    run 'vgs -o+vg_uuid'
    run 'lvs -o+UUID'
}

check_pv(){
    run 'pvdisplay -v -m'

    echo_tip /dev/dm-*
    pvdisplay -m | grep "Logical volume" | cut -f2 | xargs file -s 2>/dev/null
}

run_if_shell