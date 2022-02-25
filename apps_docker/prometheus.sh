. ./_pre.sh

n=prometheus  ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run -d --name $n --net host --restart always \
    -v $PWD/conf.d_prometheus:/etc/prometheus \
    prom/prometheus

run grep targets $PWD/conf.d_prometheus/*.yml
