. ../web/init.sh

n=apache

apache_setup(){

[ -z "$DIR_CERT" ] && read -p "Dir of .crt/.key: " DIR_CERT && export DIR_CERT=$DIR_CERT
PATH_CRT=${DIR_CERT}/${MY_DOMAIN}.cer
PATH_KEY=${DIR_CERT}/${MY_DOMAIN}.key
ls -l $PATH_CRT $PATH_KEY
[ $? -ne 0 ] && echo_error "modify $0 and re-try" && exit

run "docker stop $n 2>/dev/null; docker rm $n 2>/dev/null"

run "docker run --name $n -d --restart unless-stopped --net host \
    -v apache:/usr/local/apache2/htdocs \
    -v $PWD/apache.conf.d/httpd.conf:/usr/local/apache2/conf/httpd.conf \
    -v $PWD/apache.conf.d/custom:/usr/local/apache2/conf/custom \
    -v $PATH_CRT:/usr/local/apache2/conf/server.crt \
    -v $PATH_KEY:/usr/local/apache2/conf/server.key \
    httpd \
"

}

#################################

docker ps | grep $n
if [ $? -eq 0 ]; then
    read -p "restart apache? (y/n) " a
    [ "$a" = 'y' ] && docker exec -it apache apachectl -k restart
    
    read -p "Re-create container? (y/n) " a
    [ "$a" = 'y' ] && apache_setup
fi

sleep 2
run "netstat -lntup | grep httpd"
run "ls /var/lib/docker/volumes/apache/*"
run "docker logs -f $n"
