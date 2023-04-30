n=x-ui ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run --name $n -d --restart unless-stopped \
    --net host \
    -v xui_db:/etc/x-ui/  \
    -v xui_cert:/root/cert/   \
    enwaiax/x-ui

echo curl http://localhost:54321