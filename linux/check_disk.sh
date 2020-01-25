[ -f init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/init.sh)"

check_disk(){

    run 'lshw -class storage | grep "product:" -C1'

    run 'lshw -class disk -short'

    run 'lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,RM,MAJ:MIN,TYPE,MODEL,UUID | grep -vE "loop|rom"'

    run 'df -TPh | grep -vE "tmpfs|squashfs|overlay" '

    run 'cat /proc/mounts | grep -P "/(mapper|\wd\w\d?\b)" '
    
}

check_lvm(){
    run 'pvs -o+pv_used,vg_uuid,UUID'
    echo_tip 'pvdisplay -v -m'
    run 'vgs -o+vg_uuid'
    run lvs
}

run_if_shell