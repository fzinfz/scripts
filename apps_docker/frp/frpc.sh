. ../_pre.sh

conf_name=$HOSTNAME
conf_file=/data/conf/frp/$conf_name.toml
[ ! -f $conf_file ] && run "touch $conf_file" && exit

ls -l $conf_file

n=frp-$conf_name ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

run "\
docker run --name $n \
    -d --restart unless-stopped \
    -v $conf_file:/etc/frp/frpc.toml \
    snowdreamtech/frpc
"

cd .. && ./_post.sh $n