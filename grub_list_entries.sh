awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg
