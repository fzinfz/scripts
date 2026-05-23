#!/bin/sh
# hostapd_check.sh - Analyze OpenWrt hostapd environment and logs
# Focus: diagnose "kernel key addition failed" and related wireless/AP issues

set -e

PROG="hostapd_check"
VERSION="1.0"
OUTDIR="/tmp/hostapd-check-$(date +%Y%m%d-%H%M%S)"
LOGFILE="$OUTDIR/report.log"

usage() {
    echo "Usage: $PROG [options]"
    echo ""
    echo "Options:"
    echo "  -o <dir>    Output directory (default: auto-generated under /tmp)"
    echo "  -k          Keep previous output directories"
    echo "  -h          Show this help"
    echo ""
    echo "Analyzes hostapd environment, config, and logs on OpenWrt."
    echo "Searches for 'kernel key addition failed' and related errors."
}

KEEP_OLD=0
while getopts "o:kh" opt; do
    case $opt in
        o) OUTDIR="$OPTARG" ;;
        k) KEEP_OLD=1 ;;
        h) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
done

mkdir -p "$OUTDIR"
exec > >(tee -a "$LOGFILE") 2>&1

header() {
    echo ""
    echo "========================================"
    echo "  $1"
    echo "========================================"
    echo ""
}

cmd_output() {
    local title="$1"
    local cmd="$2"
    local outfile="$3"
    echo "--- $title ---"
    if eval "$cmd" > "$OUTDIR/$outfile" 2>&1; then
        cat "$OUTDIR/$outfile"
    else
        echo "[Command failed or returned non-zero]"
        cat "$OUTDIR/$outfile" 2>/dev/null || true
    fi
    echo ""
}

echo "hostapd_check v$VERSION"
echo "Output directory: $OUTDIR"
echo "Started at: $(date)"

# ============================================================
header "SYSTEM INFO"
# ============================================================
cmd_output "OpenWrt Release" "cat /etc/openwrt_release" "openwrt_release.txt"
cmd_output "Kernel Version" "uname -a" "kernel.txt"
cmd_output "Uptime" "uptime" "uptime.txt"
cmd_output "Free Memory" "free" "memory.txt"
cmd_output "Load Average" "cat /proc/loadavg" "loadavg.txt"

# ============================================================
header "WIRELESS HARDWARE & DRIVERS"
# ============================================================
cmd_output "Wireless Devices (iw dev)" "iw dev" "iw_dev.txt"
cmd_output "PHY Info Summary" "iw phy" "iw_phy.txt"
cmd_output "Wireless Kernel Modules" "lsmod | grep -E 'mac80211|ath| iwl|brcm|mt76|rt2|rtl'" "wireless_modules.txt"
cmd_output "PCI Network Devices" "lspci -k 2>/dev/null | grep -A 3 -i net || echo 'lspci not available'" "pci_net.txt"
cmd_output "USB Network Devices" "lsusb 2>/dev/null | grep -i net || echo 'lsusb not available'" "usb_net.txt"
cmd_output "RF-Kill Status" "rfkill list 2>/dev/null || echo 'rfkill not available'" "rfkill.txt"

# ============================================================
header "NETWORK & INTERFACE STATE"
# ============================================================
cmd_output "Interface Addresses" "ip addr" "ip_addr.txt"
cmd_output "Routing Table" "ip route" "ip_route.txt"
cmd_output "Bridge Info" "brctl show 2>/dev/null || echo 'brctl not available'" "bridge.txt"
cmd_output "Wireless Status (ubus)" "ubus call network.wireless status 2>/dev/null || echo 'ubus wireless status unavailable'" "ubus_wireless.txt"

# ============================================================
header "HOSTAPD PROCESSES"
# ============================================================
cmd_output "Hostapd Processes" "ps w | grep -E '[h]ostapd|[w]pad'" "hostapd_ps.txt"
cmd_output "Hostapd Command Lines" "cat /proc/*/cmdline 2>/dev/null | tr '\0' ' ' | grep -E 'hostapd|wpad' || true" "hostapd_cmdline.txt"

# ============================================================
header "HOSTAPD CONFIGURATION"
# ============================================================
if [ -d /var/run/hostapd ]; then
    cmd_output "Hostapd Socket Dir" "ls -la /var/run/hostapd/" "hostapd_run_dir.txt"
fi

if [ -d /etc/hostapd ]; then
    cmd_output "Hostapd Config Dir" "ls -la /etc/hostapd/" "hostapd_etc_dir.txt"
fi

# UCI wireless config
cmd_output "UCI Wireless Config" "uci show wireless" "uci_wireless.txt"

# Individual hostapd configs
for conf in /var/run/hostapd-*.conf /tmp/run/hostapd-*.conf; do
    [ -e "$conf" ] || continue
    base=$(basename "$conf")
    cp "$conf" "$OUTDIR/$base"
    echo "Copied: $conf -> $OUTDIR/$base"
done

# ============================================================
header "LOG ANALYSIS: KEY ERRORS"
# ============================================================
SEARCH_TERMS="kernel key addition failed|hostapd.*failed|nl80211.*failed|could not add key|set_key|ieee80211.*error|authentication timed out|deauthenticated|disassociated"

cmd_output "Recent Logread (last 200 lines)" "logread | tail -n 200" "logread_recent.txt"
cmd_output "Kernel Messages (last 200 lines)" "dmesg | tail -n 200" "dmesg_recent.txt"

echo "--- Filtering for hostapd / key / auth errors ---"
(
    echo "== From logread =="
    logread 2>/dev/null | grep -iE "$SEARCH_TERMS" || echo "(no matches in logread)"
    echo ""
    echo "== From dmesg =="
    dmesg 2>/dev/null | grep -iE "$SEARCH_TERMS" || echo "(no matches in dmesg)"
) | tee "$OUTDIR/filtered_errors.txt"

echo ""
echo "--- Detailed 'kernel key addition failed' context ---"
for source in logread dmesg; do
    echo "== $source =="
    if $source 2>/dev/null | grep -in "kernel key addition failed" > "$OUTDIR/key_error_${source}.txt" 2>&1; then
        cat "$OUTDIR/key_error_${source}.txt"
        # Also grab surrounding context
        $source 2>/dev/null | grep -in -B2 -A2 "kernel key addition failed" > "$OUTDIR/key_error_${source}_context.txt" || true
    else
        echo "(not found in $source)"
    fi
    echo ""
done

# ============================================================
header "HOSTAPD LOG FILES (if any)"
# ============================================================
for f in /var/log/hostapd.log /var/log/wpad.log /tmp/log/hostapd.log /tmp/log/wpad.log; do
    if [ -f "$f" ]; then
        base=$(basename "$f")
        cp "$f" "$OUTDIR/$base"
        echo "Copied log: $f"
    fi
done

# ============================================================
header "HOSTAPD STATION / CLIENT STATE"
# ============================================================
for dir in /var/run/hostapd /tmp/run/hostapd; do
    [ -d "$dir" ] || continue
    for sock in "$dir"/*; do
        [ -S "$sock" ] || continue
        iface=$(basename "$sock")
        echo "--- Interface: $iface ---"
        hostapd_cli -i "$iface" all_sta 2>/dev/null > "$OUTDIR/sta_${iface}.txt" || true
        if [ -s "$OUTDIR/sta_${iface}.txt" ]; then
            cat "$OUTDIR/sta_${iface}.txt"
        else
            echo "(no stations or hostapd_cli failed)"
        fi
        echo ""
    done
done

# ============================================================
header "DIAGNOSTIC SUMMARY & RECOMMENDATIONS"
# ============================================================
{
    echo "Diagnostic Summary"
    echo "=================="
    echo ""
    echo "1. 'kernel key addition failed' meaning:"
    echo "   - hostapd asked the kernel (via nl80211/cfg80211) to install a"
    echo "     encryption key (PTK/GTK/IGTK) and the driver/mac80211 rejected it."
    echo ""
    echo "2. Common causes on OpenWrt:"
    echo "   a) Mismatch between wireless encryption settings and driver support."
    echo "      - WPA3/SAE on old drivers or firmware."
    echo "      - 802.11w (MFP) required but not supported by hardware."
    echo "      - GCMP-256 or other advanced cipher not supported."
    echo "   b) Missing or outdated wireless firmware (e.g., ath10k-firmware, mt76-firmware)."
    echo "   c) Incorrect key index or interface state (interface not up in AP mode)."
    echo "   d) Memory pressure or corrupted wireless config."
    echo "   e) Incompatibilities between hostapd version and kernel mac80211."
    echo ""
    echo "3. Suggested fixes:"
    echo "   - Check 'logread' and 'dmesg' for firmware crashes prior to the error."
    echo "   - Try simplifying wireless encryption: WPA2-PSK (CCMP) only, no 802.11w."
    echo "   - Verify firmware packages are installed: opkg list-installed | grep firmware"
    echo "   - Update OpenWrt to latest stable release for your device."
    echo "   - If using mesh or 802.11r, disable temporarily to isolate."
    echo "   - Check 'iw phy' output for supported interfaces and ciphers."
    echo ""
    echo "4. Files collected in: $OUTDIR"
    echo "   Attach this directory as a tarball when reporting issues."
    echo "      tar czf hostapd-check-$(date +%Y%m%d-%H%M%S).tar.gz -C $(dirname "$OUTDIR") $(basename "$OUTDIR")"
} | tee "$OUTDIR/summary.txt"

# Package everything
TARBALL="$OUTDIR.tar.gz"
tar czf "$TARBALL" -C "$(dirname "$OUTDIR")" "$(basename "$OUTDIR")"
echo ""
echo "Report tarball: $TARBALL"
echo "Done at: $(date)"
