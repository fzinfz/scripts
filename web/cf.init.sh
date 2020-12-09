. ../linux/init.sh

[ -f /data/conf/init.sh ] && run source /data/conf/init.sh

[ -z "$CF_Key" ] && \
    echo https://dash.cloudflare.com/profile/api-tokens && \
    read -p "CF_Key=" CF_Key && export CF_Key=$CF_Key
    
[ -z "$CF_Email" ] && read -p "CF_Email=" CF_Email && export CF_Email=CF_Email
[ -z "$MY_DOMAIN" ] && read -p "MY_DOMAIN=" MY_DOMAIN && export MY_DOMAIN=MY_DOMAIN
DIR_CERT=~/.acme.sh/${MY_DOMAIN}

echo_debug CF_Key=$CF_Key
echo_debug CF_Email=$CF_Email
echo_debug MY_DOMAIN=$MY_DOMAIN
echo_debug DIR_CERT=$DIR_CERT