. ./_pre.sh

ip=$(ip addr | grep -oP "(?<=inet )100[.\d]+")

n=prometheus_node_exporter  ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run -d --name $n --restart always \
  -p $ip:9100:9100 \
  --pid="host" \
  -v "/:/host:ro,rslave" \
  quay.io/prometheus/node-exporter:latest \
  --path.rootfs=/host

run "curl -sS http://$ip:9100/metrics | grep "node_" | grep -v ^# | head"
echo_tip https://github.com/prometheus/node_exporter#docker
