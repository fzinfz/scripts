[ -f ../init.sh ] && source ../init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/init.sh)"

check_sys(){
    run uname -an
}

check_cpu(){
    run 'dmidecode -t processor | grep -E "(Speed|Version):"'
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

echo_script_header

run_title check_sys
run_title check_cpu
run_title check_memory
run_title check_pci
run_title check_grub
run_title check_ps_top