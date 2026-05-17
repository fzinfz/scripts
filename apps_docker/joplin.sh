# https://github.com/linuxserver/docker-joplin
# X11 web / large memory used

docker run -d \
  --name=joplin \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Shanghai \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /data/joplin:/config \
  --shm-size="1gb" \
  --restart unless-stopped \
  linuxserver/joplin:latest