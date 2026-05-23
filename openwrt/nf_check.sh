#!/bin/sh
#===============================================================================
# nf_conntrack table full diagnostic script
# For OpenWrt / Linux routers
# Usage: sh nf_check.sh [--color off] [--watch] [--top N] [--dump]
#===============================================================================

set -e

NO_COLOR=0

# --- Color definitions ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

disable_color() {
    RED=''
    GREEN=''
    YELLOW=''
    CYAN=''
    NC=''
    BOLD=''
}

banner() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}   nf_conntrack Diagnostic Tool${NC}"
    echo -e "${CYAN}   $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""
}

#===============================================================================
# 1. Overview
#===============================================================================
overview() {
    echo -e "${BOLD}[1] Connection Tracking Overview${NC}"
    echo "------------------------------------------"

    local max_file="/proc/sys/net/netfilter/nf_conntrack_max"
    local count_file="/proc/sys/net/netfilter/nf_conntrack_count"

    if [ -f "$count_file" ]; then
        count=$(cat "$count_file" 2>/dev/null || echo "N/A")
    else
        # Fallback to conntrack command if count file is missing
        count=$(conntrack -C 2>/dev/null || echo "N/A")
    fi

    if [ -f "$max_file" ]; then
        max=$(cat "$max_file" 2>/dev/null || echo "N/A")
    else
        max="N/A"
    fi

    echo "  Current connections : ${YELLOW}${count}${NC}"
    echo "  Max connections     : ${max}"

    if [ "$count" != "N/A" ] && [ "$max" != "N/A" ] && [ "$max" -gt 0 ] 2>/dev/null; then
        pct=$(( count * 100 / max ))
        if [ "$pct" -ge 90 ]; then
            echo -e "  Usage               : ${RED}${pct}%  ⚠ DANGER!${NC}"
        elif [ "$pct" -ge 70 ]; then
            echo -e "  Usage               : ${YELLOW}${pct}%  ⚡ HIGH${NC}"
        else
            echo -e "  Usage               : ${GREEN}${pct}%${NC}"
        fi
    fi

    # hashsize
    hashsize=$(cat /sys/module/nf_conntrack/parameters/hashsize 2>/dev/null || echo "N/A")
    echo "  hashsize            : ${hashsize}"
    echo ""
}

#===============================================================================
# 2. Drop / Error Statistics
#===============================================================================
drop_stats() {
    echo -e "${BOLD}[2] Drop / Error Statistics${NC}"
    echo "------------------------------------------"

    local stat_file="/proc/net/stat/nf_conntrack"
    if [ -f "$stat_file" ]; then
        # Parse CPU columns (multi-core has multiple rows; use first row as sample)
        # Format: entries searched found new invalid ignore delete delete_list insert insert_failed drop early_drop error expect_new expect_create expect_delete search_restart
        header=$(head -1 "$stat_file")
        data=$(tail -n +2 "$stat_file" | head -1)

        if [ -n "$data" ]; then
            # Sum drop / early_drop / error / insert_failed across all CPU rows
            total_drop=0
            total_early_drop=0
            total_error=0
            total_insert_failed=0
            total_found=0

            hex2dec() { printf '%d' "0x$1" 2>/dev/null || echo 0; }
            while IFS= read -r line; do
                [ -z "$line" ] && continue
                set -- $line
                # printf "CPU: %s\n" "$1"
                # drop = 10th col, early_drop = 11th col, error = 12th col, insert_failed = 9th col
                [ -n "${10}" ] && total_drop=$((total_drop + $(hex2dec "${10}")))
                [ -n "${11}" ] && total_early_drop=$((total_early_drop + $(hex2dec "${11}")))
                [ -n "${12}" ] && total_error=$((total_error + $(hex2dec "${12}")))
                [ -n "${9}" ]  && total_insert_failed=$((total_insert_failed + $(hex2dec "${9}")))
                [ -n "${3}" ]  && total_found=$((total_found + $(hex2dec "${3}")))
            done <<EOF
$(tail -n +2 "$stat_file")
EOF

            echo "  Total drop         : ${RED}${total_drop}${NC}"
            echo "  Total early_drop   : ${RED}${total_early_drop}${NC}"
            echo "  Total error        : ${YELLOW}${total_error}${NC}"
            echo "  Total insert_failed: ${YELLOW}${total_insert_failed}${NC}"
            echo "  Total found        : ${total_found}"

            if [ "$total_drop" -gt 0 ] || [ "$total_early_drop" -gt 0 ]; then
                echo -e "  ${RED}⚠ Drops detected; conntrack table was full!${NC}"
            fi
        else
            echo "  Unable to read statistics"
        fi
    else
        echo "  /proc/net/stat/nf_conntrack not found"
    fi
    echo ""
}

#===============================================================================
# 3. Kernel Parameters
#===============================================================================
kernel_params() {
    echo -e "${BOLD}[3] nf_conntrack Kernel Parameters${NC}"
    echo "------------------------------------------"

    params="
net.netfilter.nf_conntrack_max
net.netfilter.nf_conntrack_buckets
net.netfilter.nf_conntrack_tcp_timeout_established
net.netfilter.nf_conntrack_tcp_timeout_time_wait
net.netfilter.nf_conntrack_tcp_timeout_close
net.netfilter.nf_conntrack_tcp_timeout_close_wait
net.netfilter.nf_conntrack_udp_timeout
net.netfilter.nf_conntrack_udp_timeout_stream
net.netfilter.nf_conntrack_generic_timeout
net.netfilter.nf_conntrack_icmp_timeout
net.netfilter.nf_conntrack_tcp_max_retrans
net.netfilter.nf_conntrack_log_invalid
net.netfilter.nf_conntrack_tcp_be_liberal
net.netfilter.nf_conntrack_checksum
"

    for p in $params; do
        val=$(sysctl -n "$p" 2>/dev/null || echo "N/A")
        printf "  %-55s = %s\n" "$p" "$val"
    done
    echo ""
}

#===============================================================================
# 4. TOP Talkers (by source IP)
#===============================================================================
top_talkers() {
    local limit="${1:-15}"
    echo -e "${BOLD}[4] TOP ${limit} Source IPs${NC}"
    echo "------------------------------------------"

    if command -v conntrack >/dev/null 2>&1; then
        conntrack -L -o extended 2>/dev/null | \
            awk '{for(i=1;i<=NF;i++) if($i~/^src=/) print $i}' | \
            sed 's/src=//' | \
            sort | uniq -c | sort -rn | head -"$limit" | \
            while read -r cnt ip; do
                if [ "$cnt" -gt 500 ]; then
                    color="$RED"
                elif [ "$cnt" -gt 200 ]; then
                    color="$YELLOW"
                else
                    color="$NC"
                fi
                printf "  ${color}%6d  %s${NC}\n" "$cnt" "$ip"
            done
    else
        # Fallback: parse from /proc/net/nf_conntrack
        awk '{for(i=1;i<=NF;i++) if($i~/^src=/) print $i}' /proc/net/nf_conntrack 2>/dev/null | \
            sed 's/src=//' | \
            sort | uniq -c | sort -rn | head -"$limit" | \
            while read -r cnt ip; do
                if [ "$cnt" -gt 500 ]; then
                    color="$RED"
                elif [ "$cnt" -gt 200 ]; then
                    color="$YELLOW"
                else
                    color="$NC"
                fi
                printf "  ${color}%6d  %s${NC}\n" "$cnt" "$ip"
            done
    fi
    echo ""
}

#===============================================================================
# 5. Protocol Breakdown
#===============================================================================
proto_breakdown() {
    echo -e "${BOLD}[5] Protocol Distribution${NC}"
    echo "------------------------------------------"

    if command -v conntrack >/dev/null 2>&1; then
        total=0
        # TCP
        tcp=$(conntrack -L -p tcp 2>/dev/null | grep -c 'src=' || true)
        total=$((total + tcp))
        udp=$(conntrack -L -p udp 2>/dev/null | grep -c 'src=' || true)
        total=$((total + udp))
        icmp=$(conntrack -L -p icmp 2>/dev/null | grep -c 'src=' || true)
        total=$((total + icmp))
        other=$(( $(conntrack -L 2>/dev/null | grep -c 'src=' || true) - total ))
        total=$((total + other))

        echo "  TCP   : ${tcp}"
        echo "  UDP   : ${udp}"
        echo "  ICMP  : ${icmp}"
        echo "  Other : ${other}"
        echo "  Total : ${total}"
    else
        if [ -f /proc/net/nf_conntrack ]; then
            tcp=$(grep -c '^.*tcp' /proc/net/nf_conntrack 2>/dev/null || echo 0)
            udp=$(grep -c '^.*udp' /proc/net/nf_conntrack 2>/dev/null || echo 0)
            icmp=$(grep -c '^.*icmp' /proc/net/nf_conntrack 2>/dev/null || echo 0)
            total=$(wc -l < /proc/net/nf_conntrack 2>/dev/null || echo 0)

            echo "  TCP   : ${tcp}"
            echo "  UDP   : ${udp}"
            echo "  ICMP  : ${icmp}"
            echo "  Total : ${total}"
        fi
    fi
    echo ""
}

#===============================================================================
# 6. TCP State Distribution
#===============================================================================
tcp_states() {
    echo -e "${BOLD}[6] TCP Connection States${NC}"
    echo "------------------------------------------"

    if command -v conntrack >/dev/null 2>&1; then
        for state in ESTABLISHED TIME_WAIT CLOSE CLOSE_WAIT SYN_SENT SYN_RECV FIN_WAIT LAST_ACK; do
            cnt=$(conntrack -L -p tcp 2>/dev/null | grep -c "$state" || true)
            [ "$cnt" -gt 0 ] 2>/dev/null && printf "  %-14s : %d\n" "$state" "$cnt"
        done
    else
        if [ -f /proc/net/nf_conntrack ]; then
            # 4th field in /proc/net/nf_conntrack is the state
            awk '/tcp/ {print $4}' /proc/net/nf_conntrack 2>/dev/null | sort | uniq -c | sort -rn | \
                while read -r cnt state; do
                    printf "  %-14s : %d\n" "$state" "$cnt"
                done
        fi
    fi
    echo ""
}

#===============================================================================
# 7. NAT Info
#===============================================================================
nat_info() {
    echo -e "${BOLD}[7] NAT / MASQUERADE Info${NC}"
    echo "------------------------------------------"

    echo "  iptables NAT rules:"
    iptables -t nat -L -n 2>/dev/null | grep -c '^\(Chain\|target\|[0-9]\)' || echo "  N/A"
    echo ""

    echo "  MASQUERADE rules:"
    iptables -t nat -L POSTROUTING -n 2>/dev/null | grep -i masquerade || echo "  (none)"
    echo ""
}

#===============================================================================
# 8. Memory Usage
#===============================================================================
mem_usage() {
    echo -e "${BOLD}[8] nf_conntrack Memory Usage${NC}"
    echo "------------------------------------------"

    if [ -f /proc/slabinfo ]; then
        grep 'nf_conntrack' /proc/slabinfo 2>/dev/null | while read -r line; do
            echo "  $line"
        done
    fi

    # Module refcount
    if [ -d /sys/module/nf_conntrack ]; then
        refcnt=$(cat /sys/module/nf_conntrack/refcnt 2>/dev/null || echo "N/A")
        echo "  nf_conntrack refcnt: ${refcnt}"
    fi
    echo ""
}

#===============================================================================
# 9. Recommendations
#===============================================================================
recommendations() {
    echo -e "${BOLD}[9] Recommendations${NC}"
    echo "------------------------------------------"

    max=$(cat /proc/sys/net/netfilter/nf_conntrack_max 2>/dev/null || echo 0)
    count=$(cat /proc/sys/net/netfilter/nf_conntrack_count 2>/dev/null || conntrack -C 2>/dev/null || echo 0)

    if [ "$count" != "N/A" ] && [ "$max" != "N/A" ] && [ "$max" -gt 0 ] 2>/dev/null; then
        pct=$(( count * 100 / max ))
    else
        pct=0
    fi

    echo ""
    if [ "$pct" -ge 90 ]; then
        echo -e "  ${RED}▶ Immediate actions:${NC}"
        echo "    1. Increase conntrack table size:"
        echo "       sysctl -w net.netfilter.nf_conntrack_max=$((max * 2))"
        echo "       echo $((max * 2)) > /proc/sys/net/netfilter/nf_conntrack_max"
        echo "    2. Reduce timeout values:"
        echo "       sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=3600"
        echo "       sysctl -w net.netfilter.nf_conntrack_udp_timeout_stream=60"
        echo "       sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=30"
    fi

    echo ""
    echo -e "  ${YELLOW}▶ Troubleshooting checklist:${NC}"
    echo "    1. Check if any device is creating massive short-lived connections (P2P/scan/attack)"
    echo "    2. Check if DNS requests are excessive (UDP connection spike)"
    echo "    3. Check for high-concurrency apps (torrent/BT/PT)"
    echo "    4. Check iptables/nftables for unnecessary tracking rules"
    echo "    5. Disable conntrack for traffic that does not need NAT:"
    echo "       iptables -t raw -I PREROUTING -s <src> -d <dst> -j NOTRACK"
    echo ""

    echo -e "  ${GREEN}▶ Persistent config (/etc/sysctl.conf):${NC}"
    echo "    net.netfilter.nf_conntrack_max=65536"
    echo "    net.netfilter.nf_conntrack_tcp_timeout_established=3600"
    echo "    net.netfilter.nf_conntrack_udp_timeout_stream=60"
    echo "    net.netfilter.nf_conntrack_tcp_timeout_time_wait=30"
    echo "    net.netfilter.nf_conntrack_generic_timeout=120"
    echo ""
}

#===============================================================================
# 10. Watch Mode
#===============================================================================
watch_mode() {
    echo -e "${CYAN}Entering watch mode (Ctrl+C to exit)...${NC}"
    echo ""

    max=$(cat /proc/sys/net/netfilter/nf_conntrack_max 2>/dev/null || echo 0)
    prev_drop=$(awk 'NR>1 {s+=$10} END{print s}' /proc/net/stat/nf_conntrack 2>/dev/null || echo 0)

    while true; do
        clear 2>/dev/null || true

        count=$(cat /proc/sys/net/netfilter/nf_conntrack_count 2>/dev/null || conntrack -C 2>/dev/null || echo 0)
        cur_drop=$(awk 'NR>1 {s+=$10} END{print s}' /proc/net/stat/nf_conntrack 2>/dev/null || echo 0)

        new_drops=$((cur_drop - prev_drop))
        prev_drop=$cur_drop

        if [ "$max" -gt 0 ] 2>/dev/null; then
            pct=$(( count * 100 / max ))
        else
            pct=0
        fi

        echo -e "${CYAN}=== nf_conntrack Real-time Monitor ===${NC}"
        echo "Time: $(date '+%H:%M:%S')"
        echo ""
        printf "Connections: %d / %d  (%d%%)\n" "$count" "$max" "$pct"

        # ASCII progress bar
        bar_len=40
        filled=$(( pct * bar_len / 100 ))
        bar=""
        i=0
        while [ "$i" -lt "$bar_len" ]; do
            if [ "$i" -lt "$filled" ]; then
                if [ "$pct" -ge 90 ]; then
                    bar="${bar}█"
                elif [ "$pct" -ge 70 ]; then
                    bar="${bar}▓"
                else
                    bar="${bar}▒"
                fi
            else
                bar="${bar}░"
            fi
            i=$((i + 1))
        done
        echo "[${bar}]"

        echo ""
        echo "New drops: ${new_drops}  (Total: ${cur_drop})"

        if [ "$new_drops" -gt 0 ]; then
            echo -e "${RED}⚠ WARNING: ${new_drops} packets dropped recently!${NC}"
        fi

        echo ""
        echo "Press Ctrl+C to exit"

        sleep 2
    done
}

#===============================================================================
# 11. Dump Connection Table
#===============================================================================
dump_table() {
    local output="${1:-/tmp/nf_conntrack_dump_$(date +%Y%m%d_%H%M%S).txt}"
    echo -e "${BOLD}Dumping connection table to: ${output}${NC}"

    if command -v conntrack >/dev/null 2>&1; then
        conntrack -L -o extended > "$output" 2>/dev/null
    else
        cat /proc/net/nf_conntrack > "$output" 2>/dev/null
    fi

    lines=$(wc -l < "$output" 2>/dev/null || echo 0)
    echo "Exported ${lines} records"
    echo ""
}

#===============================================================================
# Main entry
#===============================================================================
main() {
    # Parse global options first
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --color)
                if [ "${2:-}" = "off" ]; then
                    NO_COLOR=1
                    disable_color
                    shift 2
                else
                    shift
                fi
                ;;
            --no-color)
                NO_COLOR=1
                disable_color
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                break
                ;;
        esac
    done

    banner

    case "${1:-}" in
        --watch|-w)
            watch_mode
            ;;
        --dump|-d)
            dump_table "${2:-}"
            ;;
        --top|-t)
            top_talkers "${2:-15}"
            ;;
        --help|-h)
            echo "Usage: $0 [options] [command]"
            echo ""
            echo "Global options:"
            echo "  --color off, --no-color   Disable colored stdout"
            echo ""
            echo "Commands:"
            echo "  (none)        Full diagnostic report"
            echo "  --watch, -w   Real-time watch mode (refresh every 2s)"
            echo "  --top N       Show top N talkers (default 15)"
            echo "  --dump        Dump full conntrack table"
            echo "  --help, -h    Show this help"
            echo ""
            ;;
        *)
            overview
            drop_stats
            kernel_params
            top_talkers 15
            proto_breakdown
            tcp_states
            nat_info
            mem_usage
            recommendations
            ;;
    esac
}

main "$@"
