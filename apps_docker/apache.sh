. ../web/init.sh

[ -z "$DIR_CERT" ] && read -p "Dir of .crt/.key: " DIR_CERT && export DIR_CERT=$DIR_CERT
PATH_CRT=${DIR_CERT}/${MY_DOMAIN}.cer
PATH_KEY=${DIR_CERT}/${MY_DOMAIN}.key

echo_tip "Map docker port: (press ENTER for default)"
read -p "80  <- " PORT_HTTP  && PORT_HTTP=${PORT_HTTP:-80}
read -p "443 <- " PORT_HTTPS && PORT_HTTPS=${PORT_HTTPS:-443}

ls -l $PATH_CRT $PATH_KEY
[ $? -ne 0 ] && echo_error "modify $0 and re-try" && exit

n=apache ; run "docker stop $n 2>/dev/null; docker rm $n 2>/dev/null"

s="docker run --name $n -d --restart unless-stopped"
if [ $PORT_HTTP -eq 80 ] && [ $PORT_HTTPS -eq 443 ]; then
    s="$s --net host"
else
    s="$s -p $PORT_HTTP:80 -p $PORT_HTTPS:443"
fi

run "$s \
    -v apache:/usr/local/apache2/htdocs \
    -v $PWD/apache.conf.d/httpd.conf:/usr/local/apache2/conf/httpd.conf \
    -v $PWD/apache.conf.d/custom:/usr/local/apache2/conf/custom \
    -v $PATH_CRT:/usr/local/apache2/conf/server.crt \
    -v $PATH_KEY:/usr/local/apache2/conf/server.key \
    httpd \
"

sleep 2
run "docker logs $n"
run "netstat -lntup | grep -E \"$PORT_HTTP|$PORT_HTTPS\""
