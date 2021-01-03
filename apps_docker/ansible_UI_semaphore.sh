. ./_pre.sh

n1=mysql-5-semaphore
n2=semaphore 

MYSQL_PORT=3306 # default in /etc/semaphore/config.json
PMA_HTTP=8082

# ========================================= #

setup_db(){

n=$n1 ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

read_if_empty MYSQL_ROOT_PASSWORD

run "\
docker run --name $n -d --restart unless-stopped \
    -p $MYSQL_PORT:3306 \
    -v $n:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -e MYSQL_DATABASE=semaphore \
    -e MYSQL_USER=semaphore \
    -e MYSQL_PASSWORD=semaphore \
    mysql:5  
"

}

read -p "Re-create db? (y/n) " a
[ "$a" = 'y' ] && setup_db

echo_tip mysql -h 127.0.0.1 -P $MYSQL_PORT -u semaphore -p semaphore

# ========================================= #

setup_pma(){

n=${n1}-pma; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

run "\
docker run --name $n -d --restart unless-stopped \
    -p $PMA_HTTP:80 \
    --link $n1:db \
    -e PMA_USER=semaphore \
    -e PMA_PASSWORD=semaphore \
    phpmyadmin/phpmyadmin
"

echo_tip ":$PMA_PORT no password"

}

read -p "Re-create pma? (y/n) " a
[ "$a" = 'y' ] && setup_pma

# ========================================= #

setup_web(){

docker ps | grep mysql-5-semaphore | grep Restarting
[ $? -eq 0 ] &&  echo_error "fix db first!" && exit

echo_tip "https://github.com/ansible-semaphore/semaphore/blob/develop/deployment/docker/ci/Dockerfile"

n=$n2; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run --name $n -d --restart unless-stopped --net host \
    ansiblesemaphore/semaphore 

run docker exec -it $n cat /etc/semaphore/config.json
run docker exec -it $n cat /tmp/semaphore/config.stdin

}

read -p "Re-create web? (y/n) " a
[ "$a" = 'y' ] && setup_web

run docker exec -it $n2 ls -lrt /tmp/semaphore/

echo_tip ":3000 Admin/semaphorepassword"
echo_tip "docker exec -it $n2 /bin/sh"
echo_tip "Config: Key Store -> empty env -> inventory -> templates"

# ========================================= #

./_post.sh "$n1|$n2"

if [ "$a" = 'y' ]; then
    run docker logs $n1
    run docker logs $n2 -f
fi
