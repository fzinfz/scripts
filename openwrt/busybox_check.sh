#!/bin/sh
# OpenWrt BusyBox Version and Environment Check Script

echo "========================================"
echo "      OpenWrt System Information"
echo "========================================"
echo ""

# Check BusyBox version
echo "--- BusyBox Version ---"
if command -v busybox >/dev/null 2>&1; then
    busybox | head -n 1
else
    echo "BusyBox not found in PATH"
fi
echo ""

# Check shell
echo "--- Current Shell ---"
echo "Shell: $SHELL"
echo "PID: $$"
echo ""

# Check OpenWrt release info
echo "--- OpenWrt Release ---"
if [ -f /etc/openwrt_release ]; then
    cat /etc/openwrt_release
elif [ -f /etc/os-release ]; then
    grep -E '^(NAME|VERSION|ID|PRETTY_NAME)=' /etc/os-release
else
    echo "No release info found"
fi
echo ""

# Check device info
echo "--- Device Information ---"
if [ -f /tmp/sysinfo/board_name ]; then
    echo "Board: $(cat /tmp/sysinfo/board_name)"
fi
if [ -f /tmp/sysinfo/model ]; then
    echo "Model: $(cat /tmp/sysinfo/model)"
fi
if [ -f /proc/cpuinfo ]; then
    echo "CPU: $(grep 'model name' /proc/cpuinfo 2>/dev/null | head -n 1 | cut -d':' -f2 | sed 's/^ *//')"
fi
echo ""

# Check kernel version
echo "--- Kernel Version ---"
uname -a
echo ""

# Check uptime
echo "--- Uptime ---"
uptime
echo ""

# Check memory
echo "--- Memory Usage ---"
free 2>/dev/null || cat /proc/meminfo | head -n 4
echo ""

# Check environment variables
echo "--- Environment Variables ---"
env | sort
echo ""

# Check PATH
echo "--- PATH Components ---"
echo "$PATH" | tr ':' '\n'
echo ""

# Check installed applets
echo "--- BusyBox Applets ---"
echo "Total applets: $(busybox --list 2>/dev/null | wc -l)"
echo ""

# Check busybox links
echo "--- Common BusyBox Commands ---"
for cmd in sh ls cat ps top netstat ifconfig ip ping traceroute wget; do
    path=$(command -v "$cmd" 2>/dev/null)
    if [ -n "$path" ]; then
        link=$(ls -l "$path" 2>/dev/null | awk '{print $NF}')
        if echo "$link" | grep -q busybox; then
            echo "$cmd -> busybox ($path)"
        else
            echo "$cmd -> $link ($path)"
        fi
    else
        echo "$cmd: not found"
    fi
done
echo ""

# Check network interfaces
echo "--- Network Interfaces ---"
ip link show 2>/dev/null || ifconfig -a 2>/dev/null
echo ""

# Check disk usage
echo "--- Disk Usage ---"
df -h 2>/dev/null | head -n 6
echo ""

echo "========================================"
echo "           Check Complete"
echo "========================================"
