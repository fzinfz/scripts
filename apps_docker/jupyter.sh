. ./_pre.sh

df | grep /data_nfs
[ $? -eq 0 ] && folder_to_map=/data_nfs || folder_to_map=/data

JUPYTER_PORT=8888

n=jupyter

docker ps | grep $n
if [ $? -eq 0 ]; then
    run "docker logs $n 2>&1 | grep token | tail -n 5"
    read -p "Re-create container? (y/n) " a
    [ "$a" != 'y' ] && exit
fi

docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

cmd="docker run --name $n \
    -v $folder_to_map:$folder_to_map -w $folder_to_map \
    -d --restart unless-stopped \
    --security-opt seccomp:unconfined \
"

# -e GEN_CERT=yes

if_my_VPS && if_tailscale && cmd="$cmd -p $(if_tailscale | tail -n1):$JUPYTER_PORT:$JUPYTER_PORT"

for dev in $(ls /dev/ttyUSB*); do
	cmd="$cmd --device=$dev:$dev"
done

cmd="$cmd fzinfz/jupyter \
    jupyter notebook --ip=* --allow-root --port=$JUPYTER_PORT
"

run "$cmd"

./_post.sh $n
