[ -f init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# System

set_timezone_shanghai() {
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" > /etc/timezone
    export TZ='Asia/Shanghai'
}

add_current_path_to_PATH() {
    CURRENT_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
    if [[ ! $PATH = *"$CURRENT_DIR"* ]];then
        export PATH=$PATH:$CURRENT_DIR
    fi
}

# Network

enable_bbr_temp(){
    modprobe tcp_bbr
    lsmod | grep bbr
    sysctl net.ipv4.tcp_available_congestion_control
}

enable_bbr_perm(){
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
    echo reboot manaually
}

# File System

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

