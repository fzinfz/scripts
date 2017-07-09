dmesg | grep drm

lsmod | grep video
lsmod | grep drm

# https://askubuntu.com/questions/28033/how-to-check-the-information-of-current-installed-video-drivers
lspci | grep VGA
find /dev -group video
glxinfo | grep direct
egrep -i " connected|card detect|primary dev|Setting driver" /var/log/Xorg.*.log
egrep "EE" /var/log/Xorg.*.log
