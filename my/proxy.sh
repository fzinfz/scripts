#!/usr/bin/env bash
set -euo pipefail

# hysteria2 proxy to git

# Show current git proxy config first
echo "Current git proxy config:"
git config --global --get http.proxy 2>/dev/null || true
git config --global --get https.proxy 2>/dev/null || true
git config --global --get socks.proxy 2>/dev/null || true
echo "---"

# Select a running Docker container
mapfile -t containers < <(docker ps --format '{{.Names}}')

if [[ ${#containers[@]} -eq 0 ]]; then
    echo "No running containers found." >&2
    exit 1
fi

if [[ ${#containers[@]} -eq 1 ]]; then
    docker_container="${containers[0]}"
else
    echo "Running containers:"
    for i in "${!containers[@]}"; do
        echo "  $((i+1)). ${containers[$i]}"
    done
    printf "Select hysteria2 container number: "
    IFS= read -r num
    if [[ -z "${num:-}" ]] || ! [[ "$num" =~ ^[0-9]+$ ]]; then
        echo "Invalid selection." >&2
        exit 1
    fi
    docker_container="${containers[$((num-1))]}"
    echo "Selected container: $docker_container"
fi

# Extract HTTP and SOCKS proxy from container logs
log_output=$(docker logs "$docker_container" 2>&1 | head -n 10)

http_addr=$(echo "$log_output" | grep 'HTTP proxy server listening' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' | sed 's/0\.0\.0\.0/127.0.0.1/' | head -n 1)
http_proxy=$([[ -n "${http_addr:-}" ]] && echo "http://$http_addr" || echo "")

socks_addr=$(echo "$log_output" | grep 'SOCKS5 server listening' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' | sed 's/0\.0\.0\.0/127.0.0.1/' | head -n 1)
socks_proxy=$([[ -n "${socks_addr:-}" ]] && echo "socks5://$socks_addr" || echo "")

echo "Container: $docker_container"
echo "HTTP  proxy: ${http_proxy:-<not found>}"
echo "SOCKS proxy: ${socks_proxy:-<not found>}"

# Set git global proxy
if [[ -n "$http_proxy" ]]; then
    git config --global http.proxy "$http_proxy"
    git config --global https.proxy "$http_proxy"
    echo "Git HTTP/HTTPS proxy set."
fi

if [[ -n "$socks_proxy" ]]; then
    git config --global socks.proxy "$socks_proxy"
    echo "Git SOCKS proxy set."
fi
