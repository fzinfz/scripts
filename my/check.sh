. ../linux/init.sh

run "netstat -lntup | grep :80"
run "netstat -lntup | grep 443"

run "ls ~/.acme.sh/*.*/ -ld"