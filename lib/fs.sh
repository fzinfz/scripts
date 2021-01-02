. ../linux/init.sh

check_dev(){
    lsblk && echo
    read -p 'check: /dev/' d
    p=/dev/$d
    file --dereference -s $p
    blkid $p
    cat /proc/mounts | grep $p
}

disk_init_ext4(){
    disk=$1
    mount_folder=$2

    parted -s /dev/$disk mklabel gpt
    parted -s /dev/$disk unit mib mkpart primary 0% 100%

    mkfs.ext4 /dev/${disk}1

    mkdir /mnt/$mount_folder
    echo >> /etc/fstab
    echo /dev/${disk}1               /mnt/$2       ext4    defaults,noatime 0 0 >> /etc/fstab
    mount /mnt/$mount_folder
}
