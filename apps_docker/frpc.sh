. ./_pre.sh

conf_file=/data/conf/frp/c.ini
[ ! -f $conf_file ] && echo edit file path && exit

ls -l $conf_file

n=frp-client ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

run "\
docker run --name $n \
    -d --restart unless-stopped \
    --entrypoint=/frpc \
    -v $conf_file:/frpc.ini \
    hyperapp/frp
"

./_post.sh $n