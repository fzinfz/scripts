. ../linux/init.sh

[ -f /data/conf/init.sh ] && . /data/conf/init.sh
read_if_empty MYSQL_ROOT_PASSWORD

n=mysql-5 ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

run "\
docker run --name $n -d --restart unless-stopped --net host \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    mysql:5  
"

run docker logs -f $n