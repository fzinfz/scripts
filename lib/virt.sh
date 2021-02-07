. ../linux/init.sh
. ./ovs.sh

virt_install(){

[ -z "$1" ] && read -p 'image file: ' file_img || file_img=$1

s="\
virt-install --name $(echo $file_img | perl -pe "s/\.\w+$//") \
--ram 512 --vcpu 2 \
--disk path=$(pwd)/$file_img,device=disk,bus=ide "

for ovsbr in $(ovs_br); do
    s="$s --network bridge=$ovsbr,model=virtio,virtualport_type=openvswitch"
done

s="$s --boot hd --noautoconsole"

echo_tip "$s"

read -p "run? (y/n) " a
[ "$a" = "y" ] && eval "$s"

run virsh list

}