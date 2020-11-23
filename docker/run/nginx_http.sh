[ -z "$1" ] && read -p "Folder to expose: " d || d=$1
[ -z "$2" ] && read -p "Port: " p || p=$2

n=ngnix_$p ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run --name $n -d --restart unless-stopped \
    -v $d:/usr/share/nginx/html:ro -p $p:80 \
    nginx  