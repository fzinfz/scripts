n=aira2ng ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run -d --restart unless-stopped \
--name $n \
-v /data/download:/aria2/data \
-v aria2_conf:/aria2/conf \
-e ARIA2RPCPORT=8081 \
-p 8081:8080 hurlenko/aria2-ariang

echo change port on web UI: /#!/settings/ariang
