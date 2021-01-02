. ../linux/init.sh

qcow2_install(){ 
    apt install libguestfs-tools
}

qcow2_check--file(){ virt-list-partitions -lht $1 ; }

qcow2_mount--file--mountpoint(){
    mkdir -pv $2
    guestmount -a $1 -i --ro $2
    cd $2
}

qcow2_cp_real_size--src--target(){ 
    run qemu-img convert -O qcow2 $1 $2
}

qcow2_create--name--size(){ 
    run "qemu-img create -f qcow2 $1.qcow2 $2 # thin "
}

qcow2_convert(){ 
    qemu-img -h | grep "Supported formats:"
    read -p "Source file: " fs
    f=`echo $fs | cut -d. -f1`
    run "qemu-img convert -O qcow2 $fs $f.qcow2"
}
