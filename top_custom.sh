#dmidecode -t processor | grep Speed
#watch -n 1  cat /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_cur_freq
watch --color -n 1 \
<<<<<<< HEAD
	"inxi -C && printf '\n' && \
	 top -b -o %CPU | head -n12 && printf '\n' && \
	 top -b -o %MEM | head -n12 | tail -n6 && printf '\n' && \
	 ps -eo %cpu,pid,command --sort -%cpu | head -n5 && printf '\n' && \
	 ps -eo %mem,pid,command --sort -%mem | head -n5"
