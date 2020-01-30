[ -f init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

kvm_check() {
    run 'egrep --color=auto "vmx|svm|0xc0f" /proc/cpuinfo | uniq'
    run 'lsmod | grep kvm'
    run 'lsmod | grep virtio'
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

# https://github.com/intel/gvt-linux/wiki/GVTg_Setup_Guide#23-library-dependence 
kvm_intel_GVTg_dependency(){
    apt-get install -y \
        git vim \
        libfdt-dev libpixman-1-dev libssl-dev socat libsdl1.2-dev libspice-server-dev \
        autoconf libtool \
        xtightvncviewer tightvncserver x11vnc \
        libsdl1.2-dev uuid-runtime uuid uml-utilities \
        bridge-utils python-dev liblzma-dev libc6-dev
}