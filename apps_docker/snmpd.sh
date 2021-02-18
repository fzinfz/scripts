# not tested

n=snmpd ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run --name $n -d --restart unless-stopped \
    --net host \
    -v /proc:/host_proc \
    --privileged \
    --read-only \
    really/snmpd
  
run "docker logs -f $n"