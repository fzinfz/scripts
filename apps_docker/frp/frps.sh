. ../_pre.sh

conf_file=/data/conf/frp/s.toml
[ ! -f $conf_file ] && echo edit file path && exit

ls -l $conf_file

n=frp-server ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

run "\
docker run --name $n \
    -d --restart unless-stopped \
    --net host \
    -v $conf_file:/etc/frp/frps.toml \
    snowdreamtech/frps
"

../_post.sh $n