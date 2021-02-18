. ./init.sh

run 'egrep --color=auto "vmx|svm|0xc0f" /proc/cpuinfo | head -2'

run virt-host-validate

run 'cat /sys/module/kvm_intel/parameters/nested'

run 'lsmod | egrep --color "kvm|nested"'
run 'cat /etc/default/grub | egrep --color "kvm|nested"'
run 'cat /boot/grub/grub.cfg | grep --color kvm'

run 'cat /etc/modprobe.d/kvm*.conf'

run 'lsmod | grep virtio'

run qemu-system-x86_64 --version
run libvirtd --version

run grep ^SHUTDOWN_TIMEOUT /etc/init.d/libvirt-guests
