. ../linux/init.sh

check_dev(){
    lsblk && echo
    read -p 'check: /dev/' d
    p=/dev/$d
    file --dereference -s $p
    blkid $p
    cat /proc/mounts | grep $p
}