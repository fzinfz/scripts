#!/bin/sh
# OpenWRT Log Analyzer
# De-duplicate errors/warnings and list issues that need fixing
# Usage: log_analyzer.sh [lines] [--syslog=/path/to/syslog]
#   lines: number of recent log lines to analyze (default: 5000)
#   --syslog: read from file instead of logread

set -e

LINES="${1:-5000}"
SYSLOG_FILE=""

# parse args
for arg in "$@"; do
    case "$arg" in
        --syslog=*) SYSLOG_FILE="${arg#*=}" ;;
    esac
done

# detect OpenWRT environment
IS_OPENWRT=0
if [ -f /etc/openwrt_release ] || [ -f /etc/os-release ] && grep -qi openwrt /etc/os-release 2>/dev/null; then
    IS_OPENWRT=1
fi

# fetch logs
if [ -n "$SYSLOG_FILE" ] && [ -f "$SYSLOG_FILE" ]; then
    LOG_DATA="$(tail -n "$LINES" "$SYSLOG_FILE" 2>/dev/null || cat "$SYSLOG_FILE")"
elif command -v logread >/dev/null 2>&1; then
    LOG_DATA="$(logread -l "$LINES" 2>/dev/null || logread 2>/dev/null || true)"
elif [ -f /var/log/messages ]; then
    LOG_DATA="$(tail -n "$LINES" /var/log/messages 2>/dev/null || true)"
else
    echo "Error: No log source found. Use --syslog=/path/to/file or run on OpenWRT." >&2
    exit 1
fi

if [ -z "$LOG_DATA" ]; then
    echo "No log data retrieved."
    exit 0
fi

TMPDIR="${TMPDIR:-/tmp}"
TMPBASE="$TMPDIR/log_analyzer_$$"

cleanup() {
    rm -f "$TMPBASE".* 2>/dev/null
}
trap cleanup EXIT

# normalize and classify severity
# severity map: emerg=0 alert=1 crit=2 err=3 warn=4 notice=5 info=6 debug=7
normalize_log() {
    echo "$LOG_DATA" | awk '
    BEGIN {
        sev["emerg"]  = 0; sev["alert"] = 1; sev["crit"] = 2; sev["err"] = 3;
        sev["error"]  = 3; sev["warn"] = 4; sev["warning"] = 4; sev["notice"] = 5;
        sev["info"]   = 6; sev["debug"] = 7;
    }
    {
        raw = $0;
        level = "info";
        # try to find level after hostname/process
        if (match(raw, /\[([0-9]+)\]:/)) {
            proc_part = substr(raw, RSTART, RLENGTH);
            rest = substr(raw, RSTART + RLENGTH);
        } else {
            rest = raw;
        }
        # strip common syslog prefix: Mon Jan 1 00:00:00 2024
        gsub(/^[A-Z][a-z]{2} [A-Z][a-z]{2} [ 0-9]{1,2} [0-9]{2}:[0-9]{2}:[0-9]{2} [0-9]{4} /, "", rest);
        gsub(/^[A-Z][a-z]{2} [ 0-9]{1,2} [0-9]{2}:[0-9]{2}:[0-9]{2} /, "", rest);
        # find severity keyword
        for (lv in sev) {
            if (match(tolower(rest), "(^|[^a-z])" lv "([^a-z]|$)")) {
                level = lv;
                break;
            }
        }
        # default severity from common patterns
        if (level == "info") {
            if (tolower(raw) ~ /(error|failed|failure|cannot|unable|denied)/) level = "err";
            else if (tolower(raw) ~ /(warning|warn)/) level = "warn";
            else if (tolower(raw) ~ /(critical|fatal)/) level = "crit";
        }
        # extract process name
        proc = "unknown";
        if (match(raw, / [^ ]*\[([0-9]+)\]:/)) {
            proc = substr(raw, RSTART + 1, RLENGTH - 2);
            gsub(/\[[0-9]+\]:$/, "", proc);
        } else if (match(raw, / [^ ]*: /)) {
            proc = substr(raw, RSTART + 1, RLENGTH - 3);
        }
        # normalize message for dedup: remove timestamps, host, pid
        msg = raw;
        gsub(/^[A-Z][a-z]{2} [A-Z][a-z]{2} [ 0-9]{1,2} [0-9]{2}:[0-9]{2}:[0-9]{2} [0-9]{4} /, "", msg);
        gsub(/^[A-Z][a-z]{2} [ 0-9]{1,2} [0-9]{2}:[0-9]{2}:[0-9]{2} /, "", msg);
        gsub(/ [^ ]* [^ ]*\[([0-9]+)\]: /, " ", msg);
        gsub(/ [^ ]*: /, " ", msg);
        gsub(/^[ \t]+/, "", msg);
        gsub(/[ \t]+$/, "", msg);
        # collapse varying parts (IPs, MACs, numbers, interface names)
        gsub(/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(:[0-9]+)?/, "<IP>", msg);
        gsub(/([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}/, "<MAC>", msg);
        gsub(/[a-zA-Z0-9._-]+\.(lan|wan|eth[0-9]+|br-[a-zA-Z0-9]+|wlan[0-9]+|phy[0-9]+)/, "<IF>", msg);
        gsub(/\<[0-9]+\>/, "<N>", msg);
        gsub(/[0-9]+\.[0-9]+/, "<F>", msg);
        gsub(/[0-9]+/, "<N>", msg);
        gsub(/[ \t]+/, " ", msg);
        gsub(/^[ \t]+/, "", msg);
        gsub(/[ \t]+$/, "", msg);
        print level "\t" proc "\t" msg "\t" raw;
    }'
}

normalize_log > "$TMPBASE.norm"

# filter interesting levels (err/warn/crit/alert/emerg) and deduplicate
awk -F'\t' '
    $1 == "err" || $1 == "warn" || $1 == "crit" || $1 == "alert" || $1 == "emerg" || $1 == "error" || $1 == "warning" {
        key = $1 "\t" $2 "\t" $3;
        if (!(key in count)) {
            first[key] = $4;
            count[key] = 0;
        }
        count[key]++;
        # keep latest raw sample
        latest[key] = $4;
    }
    END {
        for (k in count) {
            print count[k] "\t" k "\t" latest[k];
        }
    }
' "$TMPBASE.norm" | sort -t$'\t' -k1,1nr -k2,2 -k3,3 > "$TMPBASE.dedup"

# output report
SEPARATOR="================================================================================"

print_severity_header() {
    echo "$SEPARATOR"
    printf "  %-8s | %-20s | %-6s | %s\n" "SEVERITY" "PROCESS" "COUNT" "NORMALIZED MESSAGE"
    echo "$SEPARATOR"
}

TOTAL_ISSUES=0

# print severity group
group_by_severity() {
    target="$1"
    label="$2"
    found=0
    while IFS=$'\t' read -r cnt sev proc msg raw; do
        if [ "$sev" = "$target" ]; then
            if [ "$found" -eq 0 ]; then
                echo ""
                echo "[$label]"
                print_severity_header
                found=1
            fi
            printf "  %-8s | %-20s | %6s | %s\n" "$sev" "$proc" "$cnt" "$msg"
            TOTAL_ISSUES=$((TOTAL_ISSUES + cnt))
        fi
    done < "$TMPBASE.dedup"
}

echo "OpenWRT Log Analyzer Report"
echo "Generated: $(date)"
echo "Source: ${SYSLOG_FILE:-$(if command -v logread >/dev/null 2>&1; then echo 'logread'; else echo '/var/log/messages'; fi)}"
echo "Lines analyzed: $LINES"

group_by_severity "emerg"  "EMERGENCY"
group_by_severity "alert"  "ALERTS"
group_by_severity "crit"   "CRITICAL"
group_by_severity "err"    "ERRORS"
group_by_severity "error"  "ERRORS"
group_by_severity "warn"   "WARNINGS"
group_by_severity "warning" "WARNINGS"

echo ""
echo "$SEPARATOR"
printf "Total error/warning occurrences: %d\n" "$TOTAL_ISSUES"
echo "$SEPARATOR"

# actionable summary: unique issues per process
if [ -s "$TMPBASE.dedup" ]; then
    echo ""
    echo "Actionable Issues Summary (grouped by process):"
    echo "-----------------------------------------------"
    awk -F'\t' '
        { proc[$3]++; sev[$3] = ($2 < sev[$3] || sev[$3] == "") ? $2 : sev[$3] }
        END {
            for (p in proc) {
                printf "  %-8s | %-20s | %3d unique pattern(s)\n", sev[p], p, proc[p];
            }
        }
    ' "$TMPBASE.dedup" | sort -t'|' -k1,1 -k3,3nr
fi

echo ""
echo "Done."
