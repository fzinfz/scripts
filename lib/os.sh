os(){    
    run lsb_release -a 
    run uname -an
}

# apt

apt_search--startwith() {
    apt search $1 | grep ^$1
}

apt_installed---grep-i(){ apt list --installed | grep -i "$1"; }

# kernel

kernel_delete--versions() {
    run "apt purge $*"
    run "dpkg --purge $*"
}