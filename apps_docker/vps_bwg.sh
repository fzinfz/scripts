. ./_pre.sh

# A Prometheus Exporter for Bandwagon KiwiVM written with Rust
# https://github.com/icyleaf/bandwagon-exporter

docker run --name bandwagon-exporter \
  -p ${ip_vpn}:9103:9103 \
  -v /data/conf/vps/bwg.yml:/etc/bandwagon/config.yml \
  ghcr.io/icyleaf/bandwagon-exporter:snapshot \
  --config-path=/etc/bandwagon/config.yml
