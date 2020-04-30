SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; [ -f $SCRIPTPATH/init.sh ] && source $SCRIPTPATH/init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

check_sys(){
    run uname -an
}

check_cpu(){
    run 'dmidecode -t processor | grep -E "(Speed|Version):" | sort | uniq'
    run "lscpu | egrep 'Byte Order'"    
}

check_memory(){
    run free -m
    run numactl -H
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