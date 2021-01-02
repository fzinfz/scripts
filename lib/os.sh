. ../linux/init.sh

# apt

apt_search--startwith() {
    apt search $1 | grep ^$1
}

apt_installed() {
    apt list --installed
}

apt_installed--grep-i() {
    apt list --installed | grep -i $1
}


check_cpu_core_mapping(){
    # https://www.ibm.com/support/knowledgecenter/en/SSQPD3_2.6.0/com.ibm.wllm.doc/mappingcpustocore.html
    # same physical/core ID  =》 simultaneous multi threads (SMTs) / HT
    cat /proc/cpuinfo  | grep -P 'processor|physical id|core id|^$'

    # pip install walnut    # pretty print
    # for c in sorted([ ( int(c['processor']), int(c['physical id']), int(c['core id']) ) for c in cpu.dict().values()]): print c
}

check_memory_huge(){
    # https://wiki.debian.org/Hugepages#Enabling_HugeTlbPage
    run hugeadm --pool-list
    run grep Huge /proc/meminfo 
    run 'grep -R "" /sys/kernel/mm/hugepages/ /proc/sys/vm/*huge*'
}

top_custom(){
    
    top -b -n1 -o %MEM | head -n12 ; echo ;
    top -b -n1 -o %CPU | perl -ne  'print if 7 .. 12' ; echo ;
    ps -eo %cpu,pid,command --sort -%cpu | head -n6 ; echo ;
    ps -eo %mem,pid,command --sort -%mem | head -n6 ; echo ;

}



lspci--egrep() {
    lspci -nn | egrep -i $1 | egrep -o '[0-9a-z]{4}:[0-9a-z]{4}' | xargs -n1 -I% sh -c "lspci -nnk -d %;printf '\n';"
}


check_video_amd(){
    dpkg -l amdgpu-pro
}

check_video_glxgears() {
    GALLIUM_HUD=help glxgears
}

# kernel

kernel_delete--versions() {
    apt purge $*
    dpkg --purge $*
}