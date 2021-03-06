. ./init.sh

_virsh_xml_element_multilines(){
    for vm in $(virsh list --all | tail +3 | awk '{print $2}'); do
        echo_title "$1 - $vm"
        virsh dumpxml $vm | perl -ne "print if /<$1/ ... /<\/$1>/"
    done
}

_virsh_xml_element_multilines interface

ps_qemu(){
    ps -ef | grep qemu | grep -oP '(guest|mac|file)=\S*' | \
        grep -v master-key.aes | perl -pe 's/guest/\nguest/g'
}

modprobe_ignore_msrs(){
    if cmd systool; then
        run 'systool -vm kvm | grep ignore_msrs'
        [ $? -ne 0 ] && echo_tip 'echo "options kvm ignore_msrs=1" >> /etc/modprobe.d/kvm.conf'
    else
        echo_tip "apt install sysfsutils"
    fi
}

run_if_shell

run "virsh list --all"
