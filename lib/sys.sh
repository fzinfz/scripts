. ../linux/init.sh

who_using_file(){ run fuser -v -m $1 ; }

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
