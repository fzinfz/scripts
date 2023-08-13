. ./init.sh

check_power_policy(){
    echo_tip 'check supported:'
    grep -H '' /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

    echo_tip 'check enabled:'
    grep  -H '' /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

    echo_tip "tmp - sys"
    echo 'echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'

    echo_tip "tmp - pkg"
    echo apt install -y linux-cpupower
    echo cpupower frequency-info
    echo cpupower frequency-set --governor powersave

    echo_tip "persistent - pkg"
    echo "apt install -y cpufrequtils"
    echo 'echo GOVERNOR=\"powersave\" > /etc/default/cpufrequtils'
}

run_if_shell