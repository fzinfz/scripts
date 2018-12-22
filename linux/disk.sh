#!/bin/bash

echo_info(){ echo -e "\033[92m$1\033[m"; }

echo_info "lshw"
lshw -class disk -short

echo_info "lsblk -S"
lsblk -S | sort
echo_info "lsblk | grep"
lsblk  | grep -vE 'loop|rom'

# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/logical_volume_manager_administration/disk_remove_ex

echo_info "pvs"
pvs -o+pv_used

echo_info "lvs"
lvs

grep_disk(){ grep -P "/(mapper|\wd\w\d?\b)"; }

echo_info "df"
df -Ph | head -n 1
df -Ph | grep_disk

echo_info "/proc/mounts"
cat /proc/mounts | grep_disk
