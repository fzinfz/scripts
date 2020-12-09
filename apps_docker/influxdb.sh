n=influxdb ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run --name $n -d --restart unless-stopped --net host \
    -v influxdb:/root/.influxdbv2 -w /root/.influxdbv2 \
    quay.io/influxdb/influxdb:v2.0.2 --reporting-disabled
    
echo http://`hostname`:8086
