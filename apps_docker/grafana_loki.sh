
docker stop loki 2>/dev/null; docker rm loki 2>/dev/null

docker run --name loki \
    -d --restart unless-stopped --net host \
    grafana/loki  