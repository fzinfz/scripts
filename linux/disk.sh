. ./init.sh

check_disk(){

    run 'lshw -class storage | grep "product:" -A3 -B1'

    run 'lshw -class disk -short'

#   run 'parted -l'

    echo 
    for d in $(parted -l -s 2>/dev/null | grep -oP '(?<=Disk )/dev/\w+' | grep -v mapper | grep -v /dev/sr
); do
        echo_tip "~~~~~ $d ~~~~~"
	run "parted $d 'print free'"
	run "parted $d 'unit s print free' | tail +6"
        echo_tip "_____ $d ____________________"
        echo
    done

    run 'lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,RM,MAJ:MIN,TYPE,MODEL,UUID | grep -vE "loop|rom"'

    run 'df -TPh | grep -vE "tmpfs|squashfs|overlay" '

    run 'cat /proc/mounts | grep -P "/(mapper|\wd\w\d?\b)" '
    
}

check_ssd(){

    for d in $( lsblk -d -o rota,name | grep -P '^ *0' | awk '{print $2}' | grep -v loop ); do
	run "ls -l /sys/block/$d | cut -d'>' -f2"
	for p in $( parted /dev/$d print | grep -P '^ *\d' |  awk '{print $1}' ); do
            run1 "parted /dev/$d "align-check opt $p""
	done
    done

}

run_if_shell
