. ./init.sh

check_sys(){
    run ldd /bin/ps
    run file /bin/ps

    run uname -an
    run "dpkg -l | tail -n +6 | grep -E 'linux-image-[0-9]+' # list kernels"
}

check_os(){
    run lsb_release -a
}

check_time(){
    run1 'ls -l /etc/localtime'
    run1 'cat /etc/timezone'
    run  timedatectl
}

check_cpu(){
    run 'dmidecode -t processor | grep -E "(Speed|Version):" | sort | uniq'
    run "lscpu | egrep 'Byte Order'"    
    run1 "getconf LONG_BIT"    
    
    echo_tip "ls /sys/devices/system/cpu/cpu*/cpufreq/"

    
    if command -v inxi >/dev/null 2>/dev/null;then 
        echo_tip "inxi -Fxz"
    fi 

}

check_memory(){
    run free -m
    run numactl -H
    echo_tip lshw -C memory
}

check_pci(){
    run 'lspci -nn | sort'
}

check_grub(){  awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg ; }

check_ps_top(){
         run 'top -b -o %CPU | head -n12'
         run 'top -b -o %MEM | head -n12 | tail -n6'
}

run_if_shell