#dmidecode -t processor | grep Speed
#watch -n 1  cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq
watch --color -n 1 "inxi -C &&  ps -eo %cpu,pid,command --sort -%cpu | head -n5"
