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

run_if_shell