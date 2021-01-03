[ -f /data/conf/init.sh ]  && . /data/conf/init.sh

. ../linux/init.sh

f=/tmp/BANDWAGON.json

read_if_empty BANDWAGON_VEID
read_if_empty BANDWAGON_KEY

url="https://api.64clouds.com/v1/getServiceInfo?veid=${BANDWAGON_VEID}&api_key=${BANDWAGON_KEY}"
curl -sS $url > $f
[ $? -ne 0 ] && echo curl error && exit

jq_print(){ 
    p=$1
    echo "`cat $f | jq ".$p" | numfmt --to=iec-i --suffix=B --padding=10` : $p" 
}

jq_print data_counter
jq_print plan_monthly_data

printf 'data_next_reset: '
eval "date -d @`cat $f | jq '.data_next_reset'`"
echo "        update @ `date`"
