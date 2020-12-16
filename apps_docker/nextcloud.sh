. ../linux/init.sh

n=nextcloud ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

mkdir -p /data/docker_var_lib/volumes/nextcloud/_data

run "docker run --name $n -d --restart unless-stopped \
    -p 8081:80 \
    -v nextcloud:/var/www/html \
    nextcloud \
"

echo_tip "QR: /settings/user/security -> Devices & sessions"

docker logs -f $n
