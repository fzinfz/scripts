#!/usr/bin/env bash
set -euo pipefail

. ../linux/init.sh
echo_tip "Loading proxy from /tmp/proxy.json and setting git proxy"

# Show current git proxy config first
echo "Current git proxy config:"
git config --global --get http.proxy 2>/dev/null || true
git config --global --get https.proxy 2>/dev/null || true
git config --global --get socks.proxy 2>/dev/null || true
echo "---"

if [[ ! -f /tmp/proxy.json ]]; then
    echo "Error: /tmp/proxy.json not found. Run proxy_detect.sh first." >&2
    exit 1
fi

# Parse JSON with jq or sed fallback
if command -v jq &>/dev/null; then
    http_proxy=$(jq -r '.http_proxy // empty' /tmp/proxy.json)
    socks_proxy=$(jq -r '.socks_proxy // empty' /tmp/proxy.json)
else
    http_proxy=$(grep '"http_proxy"' /tmp/proxy.json | sed -E 's/.*"http_proxy"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
    socks_proxy=$(grep '"socks_proxy"' /tmp/proxy.json | sed -E 's/.*"socks_proxy"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
fi

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
