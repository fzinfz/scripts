
check_video() {
    dmesg | grep drm

    lsmod | grep video
    lsmod | grep drm

    # https://askubuntu.com/questions/28033/how-to-check-the-information-of-current-installed-video-drivers
    lspci | grep VGA
    find /dev -group video
    glxinfo | grep direct
    egrep -i " connected|card detect|primary dev|Setting driver" /var/log/Xorg.*.log
    egrep "EE" /var/log/Xorg.*.log

    # https://wiki.archlinux.org/index.php/kernel_mode_setting#Forcing_modes_and_EDID
    echo "Current status of connectors: "
    for p in /sys/class/drm/*/status; \
        do con=${p%/status}; echo -n "${con#*/card?-}: "; cat $p;
    done
}

check_video_amd(){
    dpkg -l amdgpu-pro
}

check_video_glxgears() {
    GALLIUM_HUD=help glxgears
}

check_video--card_index(){
    echo "card$1:"
    cat /sys/class/drm/card$1/device/{label,uevent,power_method,power_dpm_state}
    cat /sys/kernel/debug/dri/$1/radeon_{fence_info,gem_info,pm_info,sa_info,vram_mm}
}
