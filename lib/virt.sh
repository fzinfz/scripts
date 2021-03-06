virt_install(){

files=( $(ls *.qcow2 *.img | sort) )
for i in "${!files[@]}"; do
  printf '[%s] %s\n' "$i" "${files[i]}"
done

read -p "which to run: " i
[[ $i =~ [0-9]+ ]] || exit_err non-num
file_img=${files[i]}

s="\
virt-install --name $(echo $file_img | perl -pe "s/\.\w+$//") \
--ram 512 --vcpu 2 \
--disk path=$(pwd)/$file_img,device=disk,bus=ide "

for ovsbr in $(ovs-vsctl list-br); do
    s="$s --network bridge=$ovsbr,model=virtio,virtualport_type=openvswitch"
done

s="$s --boot hd --noautoconsole --noreboot"

echo_tip "$s"

read -p "run? (y/n) " a
[ "$a" = "y" ] && eval "$s"

run virsh list

}