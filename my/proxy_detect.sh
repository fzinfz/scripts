#!/usr/bin/env bash
#set -euo pipefail

. ../linux/init.sh
echo_tip "Detecte hysteria2 proxy from Docker container -> /tmp/proxychains4.conf"

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
    printf "Select container number: "
    IFS= read -r num
    if [[ -z "${num:-}" ]] || ! [[ "$num" =~ ^[0-9]+$ ]]; then
        echo "Invalid selection." >&2
        exit 1
    fi
    docker_container="${containers[$((num-1))]}"
    echo "Selected container: $docker_container"
fi

# Get local IP from default gateway
default_gw=$(ip route | grep 'default via' | awk '{print $3}' | sed 's/\.[0-9]*$//')
local_ip=$(ip addr | grep "$default_gw" | awk '{print $2}' | cut -d'/' -f1)

# Extract HTTP and SOCKS proxy from container logs
docker_log(){ docker logs "$docker_container" 2>&1 | head -n 5 ; }

http_addr=$(docker_log | grep 'HTTP proxy server listening' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' | sed "s/0\.0\.0\.0/$local_ip/" | head -n 1) || true
http_proxy=$([[ -n "${http_addr:-}" ]] && echo "http://$http_addr" || echo "")

socks_addr=$(docker_log | grep 'SOCKS5 server listening' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' | sed "s/0\.0\.0\.0/$local_ip/" | head -n 1) || true
socks_proxy=$([[ -n "${socks_addr:-}" ]] && echo "socks5://$socks_addr" || echo "")

echo "Container: $docker_container"
echo "HTTP  proxy: ${http_proxy:-<not found>}"
echo "SOCKS proxy: ${socks_proxy:-<not found>}"

# Parse IP and port for proxychains format
http_ip=$(echo "${http_addr:-}" | cut -d':' -f1)
http_port=$(echo "${http_addr:-}" | cut -d':' -f2)
socks_ip=$(echo "${socks_addr:-}" | cut -d':' -f1)
socks_port=$(echo "${socks_addr:-}" | cut -d':' -f2)

# Save to proxychains4 format
cat > /tmp/proxychains4.conf <<EOF
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
EOF

if [[ -n "${socks_ip:-}" && -n "${socks_port:-}" ]]; then
    echo "socks5  $socks_ip  $socks_port" >> /tmp/proxychains4.conf
fi

if [[ -n "${http_ip:-}" && -n "${http_port:-}" ]]; then
    echo "http    $http_ip  $http_port" >> /tmp/proxychains4.conf
fi

echo "Saved to /tmp/proxychains4.conf"
