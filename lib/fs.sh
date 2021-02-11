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

mount_iso--flename--mountpoint() {
    mount -o loop,ro $1 $2
}

mount_nfs--server_ip--path--local_path() {
    mount.nfs $1:$2 $3
    #mount -tnfs4 -ominorversion=1 server_nfs_4.1:/dir
}

mount_cifs_N_fstab--path--mountpoint---user--passwd(){

    echo_tip "make sure single quoted network path, eg: '\\server\folder'"

    path=$1
    mount_point=$2
    [ -z $3 ] && user=administrator || user=$3
    passwd=$4

    run "mount -t cifs $path $mount_point -o username=$user,password=$passwd"

    echo_tip echo $path $mount_point cifs username=$user,password=$passwd 0 0 >>  /etc/fstab
    
}