n=registry ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run -d --net host --restart=always \
  --name registry \
  -v registry:/var/lib/registry \
  -v `pwd`/registry2/proxy_cn.yml:/etc/docker/registry/config.yml \
  registry:2

docker logs -f registry
