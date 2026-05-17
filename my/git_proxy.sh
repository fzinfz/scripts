#!/usr/bin/env bash
set -euo pipefail

. ../linux/init.sh
echo_tip "Loading proxy from /tmp/proxychains4.conf and setting git proxy"

# Show current git proxy config first
echo "Current git proxy config:"
git config --global --get http.proxy 2>/dev/null || true
git config --global --get https.proxy 2>/dev/null || true
git config --global --get socks.proxy 2>/dev/null || true
echo "---"

if [[ ! -f /tmp/proxychains4.conf ]]; then
    echo "Error: /tmp/proxychains4.conf not found. Run proxy_detect.sh first." >&2
    exit 1
fi

# Parse proxychains4.conf format
http_proxy=$(awk '/^[[:space:]]*http[[:space:]]+/{print "http://"$2":"$3}' /tmp/proxychains4.conf | head -n1)
socks_proxy=$(awk '/^[[:space:]]*socks5[[:space:]]+/{print "socks5://"$2":"$3}' /tmp/proxychains4.conf | head -n1)

echo "HTTP  proxy from file: ${http_proxy:-<not found>}"
echo "SOCKS proxy from file: ${socks_proxy:-<not found>}"

# Set git global proxy
if [[ -n "${http_proxy:-}" ]]; then
    git config --global http.proxy "$http_proxy"
    git config --global https.proxy "$http_proxy"
    echo "Git HTTP/HTTPS proxy set."
fi

if [[ -n "${socks_proxy:-}" ]]; then
    git config --global socks.proxy "$socks_proxy"
    echo "Git SOCKS proxy set."
fi
