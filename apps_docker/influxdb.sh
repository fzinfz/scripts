. ./_pre.sh

INFLUXDB_PORT=8086 # --net host

n=influxdb ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run --name $n -d --restart unless-stopped --net host \
    -v influxdb:/root/.influxdbv2 -w /root/.influxdbv2 \
    influxdb --reporting-disabled
    
echo_tip http://`hostname`:$INFLUXDB_PORT ==> Data->Tokens
