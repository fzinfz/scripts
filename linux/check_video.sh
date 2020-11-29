SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; 
source $SCRIPTPATH/init.sh

check_video_card() {
    run "cat_one_line_files /sys/class/drm/card$1/device/{label,uevent,power_method,power_dpm_state}"
    run "cat_one_line_files /sys/kernel/debug/dri/$1/radeon_{fence_info,gem_info,pm_info,sa_info,vram_mm}"
}

check_video(){
    run 'dmesg | grep drm'

    run 'lsmod | grep video'
    run 'lsmod | grep drm'

    run 'lspci | grep VGA'
    
    run 'find /dev -group video'
    for i in $(find /dev -group video | grep -oP "(?<=card)\w"); do run check_video_card $i; done
    
    run 'for f in $(ls /var/log/Xorg.*.log 2>/dev/null); do ls -l $f; grep Output $f; done'
    run 'grep "EE" /var/log/Xorg.*.log 2>/dev/null | fgrep -v ??'

    # https://wiki.archlinux.org/index.php/kernel_mode_setting#Forcing_modes_and_EDID
    run 'cat_one_line_files /sys/class/drm/*/status'

}

run_if_shell