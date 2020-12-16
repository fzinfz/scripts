source ../linux/init.sh

folder_to_map=/data

n=jupyter

docker ps | grep $n
if [ $? -eq 0 ]; then
    run "docker logs $n 2>&1 | grep token"
    read -p "Re-create container? (y/n) " a
    [ "$a" != 'y' ] && exit
fi

docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

cmd="docker run --name $n \
    --net host \
    -v $folder_to_map:$folder_to_map -w $folder_to_map \
    -d --restart unless-stopped \
    --security-opt seccomp:unconfined \
"

ip addr | grep 192.168 1>/dev/null 
[ $? -ne 0 ] && echo "! LAN env not detected" && cmd="$cmd -e GEN_CERT=yes "

for dev in $(ls /dev/ttyUSB*); do
	cmd="$cmd --device=$dev:$dev"
done

cmd="$cmd fzinfz/jupyter \
    jupyter notebook --ip=* --allow-root --port=8888
"

run "$cmd"

run "docker logs $n -f"
