. ./_pre.sh

MYSQL_PORT=13306
PMA_HTTP_PORT=18080

n1=mariadb
n2=mariadb-pma

setup_db(){

n=$n1; run "docker stop $n 2>/dev/null ; docker rm $n 2>/dev/null"

read_if_empty MYSQL_ROOT_PASSWORD

run "\
docker run --name $n -d --restart unless-stopped \
    -v $n:/var/lib/mysql \
    -p $MYSQL_PORT:3306 \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    mariadb
"

}

docker ps | grep $n1
if [ $? -eq 0 ]; then
    read -p "Re-create db? (y/n) " a
    [ "$a" = 'y' ] && setup_db
else
    setup_db
fi

setup_web(){

n=$n2; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

run "\
docker run --name $n -d --restart unless-stopped \
    -p $PMA_HTTP_PORT:80 \
    --link $n1:db \
    -e PMA_PORT=$MYSQL_PORT \
    -e PMA_USER=root \
    -e PMA_PASSWORD=$MYSQL_ROOT_PASSWORD \
    phpmyadmin/phpmyadmin
"

echo_tip ":$PMA_HTTP_PORT no password"

}

docker ps | grep $n2
if [ $? -eq 0 ]; then
    read -p "Re-create web? (y/n) " a
    [ "$a" = 'y' ] && setup_web
else
    setup_web
fi

./_post.sh "$n1|$n2"

if [ "$a" = 'y' ]; then
    run docker logs $n1
    run docker logs $n2 -f
fi
