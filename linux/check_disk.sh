SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; [ -f $SCRIPTPATH/init.sh ] && source $SCRIPTPATH/init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

check_disk(){

    run 'lshw -class storage | grep "product:" -C1'

    run 'lshw -class disk -short'

#   run 'parted -l'

    echo 
    for d in $(parted -l | grep -oP '(?<=Disk )/dev/\w+'); do
        echo_tip "----- $d -----"
	run "parted $d 'print free'"
	run "parted $d 'unit s print free' | tail +6"
        echo_tip "===== $d ====="
        echo
    done

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
