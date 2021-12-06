. ../linux/init.sh

run "netstat -lntp | grep -v "127.0.0.1" | grep -v docker-proxy"

run docker ps

[ -d ~/.acme.sh ] && run "ls ~/.acme.sh/*.*/ -ld"