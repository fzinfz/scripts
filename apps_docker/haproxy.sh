n=haproxy; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run -d --restart unless-stopped --net host --name $n \
	-v $PWD/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg  \
	haproxy
