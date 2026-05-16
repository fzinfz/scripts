#!/usr/bin/env bash
set -euo pipefail

echo -e "\e[31m === this file for demo only, use playbooks/ instead === \e[0m"

INVENTORY="/data/conf/ansible/inv/routers.ini"

if ! command -v ansible &> /dev/null; then
    echo "Error: ansible is not installed." >&2
    exit 1
fi

if [[ ! -f "$INVENTORY" ]]; then
    echo "Error: inventory file not found: $INVENTORY" >&2
    exit 1
fi

# Verify the [routers] group actually contains hosts
host_list=$(ansible routers -i "$INVENTORY" --list-hosts 2>/dev/null | tail -n +2 | sed '/^[[:space:]]*$/d' || true)
if [[ -z "$host_list" ]]; then
    echo "Warning: no hosts matched in [routers] group." >&2
    echo "Please add your router IPs to: $INVENTORY" >&2
    exit 0
fi

echo "Checking OpenWrt version of routers in ${INVENTORY} ..."
ansible routers -i "$INVENTORY" -m raw -a 'ubus call system board 2>/dev/null || cat /etc/openwrt_release 2>/dev/null || cat /etc/os-release'
