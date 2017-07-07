#!/bin/bash

modprobe_blacklist="megaraid_sas" #ahci,radeon,nouveau,nvidiafb,snd_hda_intel


s=$(lscpu | grep 'Model name')
if [[ "$s" =~ "Intel" ]]; then
	arch=intel
else
	arch=amd
fi

sed -r -i "s/[#]?GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet splash ${arch}_iommu=on modprobe.blacklist=$modprobe_blacklist\"/" /etc/default/grub

cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT

echo Press Enter to update grub
read

update-grub
