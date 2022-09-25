. ./_pre.sh
. ../lib/github.sh

CADVISOR_PORT=8082
n=cadvisor ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

ip=$(ip addr | grep -oP "(?<=inet )100[.\d]+")

github_query google/cadvisor 
image=gcr.io/cadvisor/cadvisor:$github_latest_release_ver
echo_tip  $image

image_dockerhub=fzinfz/tools:cadvisor

ping gcr.io -c 1 | grep "100% packet loss"
[ $? -eq 0 ] && { image=$image_dockerhub; docker pull $image; } || {
  docker tag $image $image_dockerhub
  docker push $image_dockerhub
}

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
./_post.sh $n
