kvm_intel_reload() {
    rmmod kvm_intel
    modprobe kvm_intel
    
    rmmod kvm
    modprobe kvm
}

kvm_intel_nested() {
    modprobe -r kvm_intel
    modprobe kvm_intel nested=1
    
    [ ! -f /etc/modprobe.d/kvm.conf ] && \
        echo options kvm_intel nested=Y > /etc/modprobe.d/kvm.conf
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
