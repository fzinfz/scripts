#!/usr/bin/env bash
# Docker Proxy Setup Script

set -euo pipefail

HTTP_PROXY="http://127.0.0.1:6081"
SOCKS_PROXY="socks5://127.0.0.1:6080"

DROP_IN_DIR="/etc/systemd/system/docker.service.d"
CONF_FILE="${DROP_IN_DIR}/http-proxy.conf"

echo "Configuring Docker proxy settings..."
echo "  HTTP_PROXY:  ${HTTP_PROXY}"
echo "  SOCKS_PROXY: ${SOCKS_PROXY}"

# Create drop-in directory if not exists
if [[ ! -d "${DROP_IN_DIR}" ]]; then
    echo "Creating ${DROP_IN_DIR} ..."
    sudo mkdir -p "${DROP_IN_DIR}"
fi

# Write proxy environment overrides
cat <<EOF | sudo tee "${CONF_FILE}" >/dev/null
[Service]
Environment="HTTP_PROXY=${HTTP_PROXY}"
Environment="HTTPS_PROXY=${HTTP_PROXY}"
Environment="SOCKS_PROXY=${SOCKS_PROXY}"
Environment="NO_PROXY=localhost,127.0.0.1,.local"
EOF

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Restarting Docker service..."
sudo systemctl restart docker

echo "Done. Verifying proxy settings..."
sudo systemctl show --property=Environment docker
