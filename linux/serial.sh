. ./init.sh

run grep ttyS /etc/default/grub

echo_title "grep ttyS /boot/grub/grub.cfg"
grep ttyS /boot/grub/grub.cfg | awk '{$1=$1};1' | uniq
