virt_xml_export(){ run "virsh dumpxml $1 > $1.xml" ; }

virt_xml_import(){  
    select_file
    run "virsh define $selected_file"
    echo_tip "virsh edit $(echo $selected_file | cut -d. -f1)"
}

virt_list_vnet(){
    for n in $(virsh list --name); do
        run "virsh domiflist $n"
    done
}

virt_install(){

files=( $(ls *.qcow2 *.img | sort) )
for i in "${!files[@]}"; do
  printf '[%s] %s\n' "$i" "${files[i]}"
done

read -p "which to run: " i
[[ $i =~ [0-9]+ ]] || exit_err non-num
file_disk=${files[i]}

s="\
virt-install --name $(echo $file_disk | perl -pe "s/\.\w+$//") \
--ram 512 --vcpu 2 \
--disk path=$(pwd)/$file_disk "

for ovsbr in $(ovs-vsctl list-br); do
    s="$s --network bridge=$ovsbr,model=virtio,virtualport_type=openvswitch"
done

s="$s --boot hd --noautoconsole --noreboot"

echo_tip "$s"

read -p "run? (y/n) " a
[ "$a" = "y" ] && eval "$s"

run virsh list

}