. ./_pre.sh
. ../lib/github.sh

CADVISOR_PORT=8082
n=cadvisor ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

ip=$(ip addr | grep -oP "(?<=inet )100[.\d]+")

github_query google/cadvisor 
image=gcr.io/cadvisor/cadvisor:$github_latest_release_ver
echo_tip  $image

ping gcr.io -c 1 | grep "100% packet loss"
[ $? -eq 0 ] && image=fzinfz/tools:cadvisor

run docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=$ip:$CADVISOR_PORT:8080 \
  --detach=true \
  --name=$n \
  --privileged \
  --device=/dev/kmsg \
  $image

echo_tip https://github.com/google/cadvisor#quick-start-running-cadvisor-in-a-docker-container
run "docker ps | grep cadvisor"
