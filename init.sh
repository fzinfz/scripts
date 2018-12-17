#!/bin/bash

# https://www.gnu.org/software/bash/manual/bashref.html

shopt -s expand_aliases

# Basic

alias ls="ls --color=auto"

curl_download--url(){
    curl -sSLO $1
    # -S, --show-error    Show error. With -s, make curl show errors when they occur
    # -s, --silent        Silent mode (don't output anything)
    # -o, --output FILE   Write to FILE instead of stdout
    # -O, --remote-name   Write output to a file named as the remote file
    # -L, --location      Follow redirects (H)
}

curl_then_source--url() {
    source /dev/stdin <<< "$(curl -sSL $1)"
}
alias source_url=curl_then_source--url

cat_highlight--keyword--file(){
    # https://unix.stackexchange.com/questions/106565
    grep --color=auto -E "$1|$" $2
    #   -E, --extended-regexp     PATTERN is an extended regular expression (ERE)
}

search_in_files--regex--path() {
    grep --color=auto -rn -P "$1" $2
    # -r, --recursive           like --directories=recurse
    # -n, --line-number         print line number with output lines
    # -P, --perl-regexp         PATTERN is a Perl regular expression
}

find--path--name() {
    find $1 -iname $2
    # find . ! -readable / -writable / -executabl
    # find . ! -perm -g=w
}

chmod+x() {
    find -regextype posix-extended -regex ".*[.](py|sh)" -exec chmod +x {} \;
}

tar_help(){
    cat << EOL
tar -cf archive.tar foo bar  # Create archive.tar from files foo and bar.
tar -tvf archive.tar         # List all files in archive.tar verbosely.
tar -xf archive.tar          # Extract all files from archive.tar.
    -t, --list                 list the contents of an archive
    -c, --create               create a new archive
    -x, --extract, --get       extract files from an archive
    -f, --file=ARCHIVE         use archive file or device ARCHIVE
    -j, --bzip2                filter the archive through bzip2
    -z, --gzip, --gunzip, --ungzip   filter the archive through gzip
    -v, --verbose              verbosely list files processed
EOL
}


tar_help(){
    cat << EOL
zip [options] zipfile files_list
    -r   recurse into directories
    -x   exclude the following names
    -v   verbose operation/print version info

    -m   move into zipfile (delete OS files) !!
    -d   delete entries in zipfile !!!
    -u   update: only changed or new files
EOL
}

rsync--local--remote---port() {
    rsync -aP -e "ssh -p $3" $1 root@$2
}

# network

nmap--ip--port() {
    nmap -sV -p$2 $1
}

ip_addr--interface() {
    ifconfig $1 | grep -P -o '(?<=inet )[0-9.]+'
}

ip_addr() {
    ip route get 1 | awk '{print $NF;exit}'
}

netstat_lntup() {
    netstat -lntup
}

netstat_an--egrep() {
    netstat -an | egrep $1 | \
    awk '{ print $4 ":" $5 ":" $6}' | \
    awk -F':' '{ print $1 ":" $2 " ---> " $3 " - " $5 }' | \
    sort -u
}

# tmux

tmux_show_screen_keys(){
    cat /usr/share/doc/tmux/examples/screen-keys.conf | grep '\bbind \w'
}

# env

grub_list_entries() {
    awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg
}

timezone_shanghai() {
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" > /etc/timezone
    export TZ='Asia/Shanghai'
}

if_exist--cmd() {
    if command -v $1 >/dev/null 2>/dev/null; then
        echo yes
    else
        echo no
    fi
}

nl="printf \n"

add_current_path_to_PATH() {
    CURRENT_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
    if [[ ! $PATH = *"$CURRENT_DIR"* ]];then
        export PATH=$PATH:$CURRENT_DIR
    fi
}

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

history--tail_count() {
    if [ -z ${1+x} ] ;then
        cat /root/.bash_history
    else
        cat /root/.bash_history | tail -n$1
    fi

    echo "if history items missing, run init_bashrc.sh first."
}

export_proxy---port---ip(){
    if [ -z ${2+x} ]; then
      ip="127.0.0.1"
     else
      ip=$2
    fi

    if [ -z ${1+x} ]; then
      port=1080
     else
      port=$1
    fi

    http_proxy=http://$ip:$port

    export http_proxy=$http_proxy
    export https_proxy=$http_proxy
    export no_proxy="localhost,127.0.0.1,192.168.*.*,10.*.*.*,172.16.*.*,172.17.*.*"
    export ftp_proxy=$http_proxy
    export rsync_proxy=$http_proxy
}

# fs

check_fs(){
    lsblk -o+FSTYPE,UUID
    pvs -o+vg_uuid,UUID
    lvs -o+UUID
}

check_fs--volume(){
    file --dereference -s $1
    blkid $1
    cat /proc/mounts | grep $1
}

mount_iso--flename--mountpoint() {
    mount -o loop,ro $1 $2
}

mount_nfs--server_ip--path--local_path() {
    mount.nfs $1:$2 $3
    #mount -tnfs4 -ominorversion=1 server_nfs_4.1:/dir
}

mount_cifs_N_fstab--path--mountpoint---user--passwd(){

    # make sure single quoted network path, eg: '\\server\folder'

    path=$1

    mount_point=$2

    if [ -z $3 ]; then
        user=administrator
    else	
        user=$3
    fi

    passwd=$4

    #mount -t cifs $path $mount_point -o username=$user,password=$passwd

    echo $path $mount_point cifs username=$user,password=$passwd 0 0 >>  /etc/fstab
}

# apt

apt_search--startwith() {
    apt search $1 | grep ^$1
}

apt_installed() {
    apt list --installed
}

apt_installed--grep-i() {
    apt list --installed | grep -i $1
}

# git

alias git_commit_reuse_previous_message="git commit -c ORIG_HEAD"
alias git_commit_amend="git commit --amend -C ORIG_HEAD"
alias git_discard_changes="git checkout -- ."
alias git_uncommit="git reset --soft HEAD~1"
alias git_gitignore_download-py="wget https://raw.githubusercontent.com/fzinfz/tsadmin/master/.gitignore"

alias my_functions='sed -nE "s/\(\) *\{//p" init.sh | sort' # `-n`+`p`: only modified lines
alias my_functions_unset='unset -f $(my_functions)'

git_add_commit_push---comment() {
    if [ -z $1 ];then
        c='update'
    else
        c=$1
    fi

    git add -A
    git commit -am "$c"
    git push
}

git_config_init_N_show(){
    git config --global push.default simple
    git config --list --show-origin
}

git_config_gmail--prefix(){
    git config user.name "$1"
    git config user.email "$1@gmail.com"
}

git_config_proxy_http--ip--port(){
    git config --global http.proxy http://$1:$2
}

# performance

dd_bandwidth--M() {
    dd if=/dev/zero of=/tmp/testfile bs=$1M count=1 oflag=direct
}

dd_iops_512--count() {
    dd if=/dev/zero of=/tmp/testfile bs=512 count=$1 oflag=direct
}

bench_dd-iops() {
    dd if=/dev/zero of=/tmp/test_iops bs=512 count=10000 oflag=direct
}

bench_dd-bandwidth() {
    dd if=/dev/zero of=/tmp/test_bw bs=200M count=1 oflag=direct
}


# iptables

iptables_delete_INPUT--line() {
    iptables -D INPUT $1
    iptables-save
    iptables -L
}


iptables_delete_NAT-POSTROUTING--line() {
    iptables -t nat -D POSTROUTING $1
}

iptables_list() {
    iptables -L -n -v --line-numbers
}

iptables_log_INPUT_DROP() {
    iptables -N LOGGING
    iptables -A INPUT -j LOGGING
    iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
    iptables -A LOGGING -j DROP
}


iptables_list_NAT() {
    iptables -t nat -v -L -n --line-number
}


bbr_check() {
    tc qdisc show
    sysctl net.core.default_qdisc
    sysctl net.ipv4 | grep control
}
alias check_bbr=bbr_check

# ssh

ssh_key_add() {
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s` 
  ssh-add 
else
  echo "key exists: $SSH_AUTH_SOCK"
fi
}

ssh_key_add_silent() {
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s` > /dev/null
  ssh-add > /dev/null
fi
}

sshd-change--port() {
    sed -r -i "s/^[#]? *Port .*/Port $1/" /etc/ssh/sshd_config
    service sshd restart
}

# kernel

kernel_list() {
    dpkg -l | tail -n +6 | grep -E 'linux-image-[0-9]+'
}

kernel_delete--versions() {
    apt purge $*
    dpkg --purge $*
}


top_custom(){
    dmidecode -t processor | grep Speed ; echo;
    top -b -n1 -o %MEM | head -n12 ; echo ;
    top -b -n1 -o %CPU | perl -ne  'print if 7 .. 12' ; echo ;
    ps -eo %cpu,pid,command --sort -%cpu | head -n6 ; echo ;
    ps -eo %mem,pid,command --sort -%mem | head -n6 ; echo ;

         #inxi -C ; echo ;
}

top_custom_watch(){
#watch -n 1  cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq

}

# hardware

check_sys() {
    echo LONG_BIG: $(getconf LONG_BIT)
    $nl

    lscpu | egrep 'Byte Order'
    $nl

    file /bin/ps
    ldd /bin/ps
    $nl

    inxi -Fxz
}

check_cpu_vendor(){
    s=$(lscpu | grep 'Model name')
    if [[ "$s" =~ "Intel" ]]; then
        arch=intel
    else
        arch=amd
    fi
    echo $arch
}


check_cpu_core_mapping(){
    # https://www.ibm.com/support/knowledgecenter/en/SSQPD3_2.6.0/com.ibm.wllm.doc/mappingcpustocore.html
    # same physical/core ID  =》 simultaneous multi threads (SMTs) / HT
    cat /proc/cpuinfo  | grep -P 'processor|physical id|core id|^$'

    # pip install walnut    # pretty print
    # for c in sorted([ ( int(c['processor']), int(c['physical id']), int(c['core id']) ) for c in cpu.dict().values()]): print c
}

bench_sysbench_cpu() {
    sysbench --test=cpu run
}

check_memory(){
    # https://wiki.debian.org/Hugepages#Enabling_HugeTlbPage
    hugeadm --pool-list
    grep Huge /proc/meminfo 
    grep -R "" /sys/kernel/mm/hugepages/ /proc/sys/vm/*huge*

    free -m
    numactl -H

    lshw -C memory
}

lspci--egrep() {
    lspci -nn | egrep -i $1 | egrep -o '[0-9a-z]{4}:[0-9a-z]{4}' | xargs -n1 -I% sh -c "lspci -nnk -d %;printf '\n';"
}


check_disk(){
    lshw -class disk -class storage
    lshw -short -C disk
}


# kvm

kvm_install() {
    apt install -y virt-manager qemu-kvm qemu-utils
}


kvm_check() {
    egrep --color=auto 'vmx|svm|0xc0f' /proc/cpuinfo
    lsmod | grep kvm
    lsmod | grep virtio
}

kvm_intel_reload() {
    rmmod kvm_intel
    rmmod kvm
    modprobe kvm
    modprobe kvm_intel
}

kvm_intel_nested() {
    modprobe -r kvm_intel
    modprobe kvm_intel nested=1
    echo options kvm_intel nested=1 >> /etc/modprobe.d/modprobe.conf
    echo qemu-system-x86_64 -enable-kvm -cpu host
}


check_video() {
    dmesg | grep drm

    lsmod | grep video
    lsmod | grep drm

    # https://askubuntu.com/questions/28033/how-to-check-the-information-of-current-installed-video-drivers
    lspci | grep VGA
    find /dev -group video
    glxinfo | grep direct
    egrep -i " connected|card detect|primary dev|Setting driver" /var/log/Xorg.*.log
    egrep "EE" /var/log/Xorg.*.log

    # https://wiki.archlinux.org/index.php/kernel_mode_setting#Forcing_modes_and_EDID
    echo "Current status of connectors: "
    for p in /sys/class/drm/*/status; \
        do con=${p%/status}; echo -n "${con#*/card?-}: "; cat $p;
    done
}

check_video_amd(){
    dpkg -l amdgpu-pro
}

check_video_glxgears() {
    GALLIUM_HUD=help glxgears
}

check_video--card_index(){
    echo "card$1:"
    cat /sys/class/drm/card$1/device/{label,uevent,power_method,power_dpm_state}
    cat /sys/kernel/debug/dri/$1/radeon_{fence_info,gem_info,pm_info,sa_info,vram_mm}
}


# python

py_pip_install--packages--proxy--port() {
    pip install $1 --proxy http://$2:$3
}

conda_env_create() {
    conda create -y --name $1
    source activate $1
}

pypi_upload_test() {
    echo doc: https://packaging.python.org/tutorials/distributing-packages/
    twine upload --repository testpypi dist/*
}


py_install---requirements.txt() {

# http://stackoverflow.com/questions/35802939/install-only-available-packages-using-conda-install-yes-file-requirements-t
# one fails, all fail:
# conda install --yes --file requirements.txt

# fix

    if [ -z ${1+x} ]; then
      file=requirements.txt
     else
      file=$1
    fi

    while read requirement; do conda install --yes $requirement; done < $file
    while read requirement; do pip install $requirement; done < $file

}

# 3rd party hw

hw_dell--ip--action() {
    echo actions: powerdown powerup powerstatus graceshutdown hardreset powercycle
    echo Doc: http://www.dell.com/support/manuals/us/en/04/integrated-dell-remote-access-cntrllr-8-with-lifecycle-controller-v2.00.00.00/racadm_idrac_pub-v1/serveraction?guid=guid-69ea52c5-153d-4369-b7c4-6694a3b9e0d4&lang=en-us
    ssh root@$1 "racadm serveraction  $2"
}

powerup_dell--ip() {
    hw_dell--ip--action $1 powerup
}

# X

install-browser-debian8() {
    apt install -y firefox-esr firefox-esr-l10n-zh-cn firefox-esr-l10n-zh-tw \
    chromium chromium-l10n
}

# docker

install-docker() {
    curl -fsSL get.docker.com | bash
}

