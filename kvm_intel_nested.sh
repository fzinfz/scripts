modprobe -r kvm_intel
modprobe kvm_intel nested=1
echo options kvm_intel nested=1 >> /etc/modprobe.d/modprobe.conf
echo qemu-system-x86_64 -enable-kvm -cpu host
