LIBRESPEED_PORT=82

n=librespeed ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run -d \
  --name=$n \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -e CUSTOM_RESULTS=true `#optional` \
  -e DB_TYPE=sqlite `#optional` \
  -p $LIBRESPEED_PORT:80 \
  -v /path/to/appdata/config:/config \
  --restart unless-stopped \
  linuxserver/librespeed