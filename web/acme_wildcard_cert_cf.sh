. ./init.sh

[ ! -d ~/.acme.sh ] && wget -O - https://get.acme.sh | sh

ls -l ~/.acme.sh/dnsapi/dns_cf.sh

[ ! -d $DIR_CERT ] && run "~/.acme.sh/acme.sh --issue -d ${MY_DOMAIN} -d *.${MY_DOMAIN} --dns dns_cf"

run ls -l $DIR_CERT

run "crontab  -l | grep acme"