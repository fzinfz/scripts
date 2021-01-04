. ./_pre.sh

NEXTCLOUD_PORT=8081

n=nextcloud ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

run "docker run --name $n \
    -d --restart unless-stopped \
    -p $NEXTCLOUD_PORT:80 \
    -v nextcloud:/var/www/html \
    nextcloud \
"

echo_tip "QR: /settings/user/security -> Devices & sessions"

./_post.sh $n