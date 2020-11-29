source ./init.sh

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


zip_help(){
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

    # echo "if history items missing, run init_bashrc.sh first."
}

# fs

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

    echo_tip "make sure single quoted network path, eg: '\\server\folder'"

    path=$1
    mount_point=$2
    [ -z $3 ] && user=administrator || user=$3
    passwd=$4

    run "mount -t cifs $path $mount_point -o username=$user,password=$passwd"

    echo_tip echo $path $mount_point cifs username=$user,password=$passwd 0 0 >>  /etc/fstab
    
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

kernel_delete--versions() {
    apt purge $*
    dpkg --purge $*
}

check_cpu_core_mapping(){
    # https://www.ibm.com/support/knowledgecenter/en/SSQPD3_2.6.0/com.ibm.wllm.doc/mappingcpustocore.html
    # same physical/core ID  =》 simultaneous multi threads (SMTs) / HT
    cat /proc/cpuinfo  | grep -P 'processor|physical id|core id|^$'

    # pip install walnut    # pretty print
    # for c in sorted([ ( int(c['processor']), int(c['physical id']), int(c['core id']) ) for c in cpu.dict().values()]): print c
}

check_memory_huge(){
    # https://wiki.debian.org/Hugepages#Enabling_HugeTlbPage
    run hugeadm --pool-list
    run grep Huge /proc/meminfo 
    run 'grep -R "" /sys/kernel/mm/hugepages/ /proc/sys/vm/*huge*'
}

top_custom(){
    
    top -b -n1 -o %MEM | head -n12 ; echo ;
    top -b -n1 -o %CPU | perl -ne  'print if 7 .. 12' ; echo ;
    ps -eo %cpu,pid,command --sort -%cpu | head -n6 ; echo ;
    ps -eo %mem,pid,command --sort -%mem | head -n6 ; echo ;

}

bench_sysbench_cpu() {
    sysbench --test=cpu run
}

lspci--egrep() {
    lspci -nn | egrep -i $1 | egrep -o '[0-9a-z]{4}:[0-9a-z]{4}' | xargs -n1 -I% sh -c "lspci -nnk -d %;printf '\n';"
}


check_video_amd(){
    dpkg -l amdgpu-pro
}

check_video_glxgears() {
    GALLIUM_HUD=help glxgears
}

# python

py_pip_install--packages--proxy--port() {
    pip install $1 --proxy http://$2:$3
}

conda_env_create--env() {
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
