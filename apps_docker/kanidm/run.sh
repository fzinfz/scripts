n=kanidmd ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run -d --restart unless-stopped \
--name $n \
-p 9443:9443 \
-v $PWD/server.toml:/data/server.toml \
-v kanidmd:/data \
kanidm/server:latest