. ./_pre.sh

docker run -d -p 8000:8000 -p 9000:9000 -p 9443:9443 \
--name=portainer --restart=always \
-v /var/run/docker.sock:/var/run/docker.sock \
-v portainer:/data \
portainer/portainer-ce

echo_tip ":9000 to setup"
