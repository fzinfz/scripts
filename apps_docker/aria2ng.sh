n=aira2ng ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run -d --restart unless-stopped \
--name $n \
-v /data/download:/aria2/data \
-v aria2_conf:/aria2/conf \
-p 8080:8080 hurlenko/aria2-ariang
