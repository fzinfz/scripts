docker stop resilio && docker rm resilio

docker run -d --name resilio \
    --net=host \
    -v /data/sync:/mnt/sync/folders \
    -v resilio:/mnt/sync \
    --restart unless-stopped \
    resilio/sync


ss -lntup | grep rslsync | grep LISTEN