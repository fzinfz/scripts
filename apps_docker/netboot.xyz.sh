# https://netboot.xyz/docs/docker/

. ./_pre.sh

n=netbootxyz
docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

NETBOOT_XYZ_WEBAPP_PORT=3001
NETBOOT_XYZ_TFTP_PORT=69
NETBOOT_XYZ_HTTP_PORT=8082

docker run -d \
  --name=$n \
  -p $NETBOOT_XYZ_WEBAPP_PORT:3000                       `# sets webapp port` \
  -p $NETBOOT_XYZ_TFTP_PORT:69/udp                       `# sets tftp port` \
  -p $NETBOOT_XYZ_HTTP_PORT:80                         `# optional` \
  -v netbootxyz_config:/config   `# optional` \
  -v netbootxyz_assets:/assets   `# optional` \
  --restart unless-stopped \
  netbootxyz/netbootxyz
