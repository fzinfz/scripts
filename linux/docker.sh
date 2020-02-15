SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
[ -f $SCRIPTPATH/init.sh ] && source $SCRIPTPATH/init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

# Install

docker_install_from_curl(){  curl -fsSL get.docker.com | bash ; }
docker_install_from_apt(){   apt install -y docker.io ; }

docker_install_CE_on_RHEL(){
    # EE supported on RHEL officially
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum makecache fast
    sudo yum -y install docker-ce
    sudo systemctl start docker
}

# Status

docker_stats() {
     # https://github.com/moby/moby/issues/20973
    docker stats $(docker ps --format={{.Names}}) --no-stream | sort -h -k4
}

# Log

docker_log_json_path--container(){
    docker inspect --format='{{.LogPath}}' $1    
}

docker_log_clear--container() {
    echo "" > $(docker inspect --format='{{.LogPath}}'  $1)
}

docker_logs--container---pgrep() {
    docker logs $1  2>&1 | grep -P "$2"
}

# Container
docker_ps(){
    printf "ps -ef \n    "
    docker exec -it $1 ps -ef | grep -v 'ps -ef'
}

docker_inspect(){
    for k in .Name .HostConfig.Binds .Config.Cmd .Config.Entrypoint; do
        printf "$k\n    "
        docker inspect --format="{{$k}}" $1
    done
}

docker_inspect_all(){
    for c in $(docker ps -q); do
        docker_inspect $c
        echo_yellow $(linesep -)
    done
}


docker_update_restart_unless_stopped--container(){
    docker container update $1 --restart unless-stopped
}

docker_stop_all() {
    docker kill $(docker ps -q)
}

docker_rm_all() {
    sh stop_all.sh
    docker rm $(docker ps -a -q)
}

docker_stop_N_rm(){
    docker stop $1 
    docker rm $1
}

docker_kill_N_rm--container() {
    docker kill $1
    docker rm $1
}

# Image

docker_images_sort_by_size(){ docker images | sort -k7 -h ; }

docker_rmi_all(){        docker rmi $(docker images -q) ; }
docker_rmi_all_unused(){ docker image prune ; }

docker_rmi_all_none() {
    docker_rm_all_stopped
    docker images | egrep '<none>' | awk '{print $3}' | xargs --no-run-if-empty docker rmi
}

# Run

mode_d='-d --restart unless-stopped'
mode_host="--privileged --user=root --cap-add=ALL \
    --pid=host --ipc=host --net host \
    -v /dev:/dev -v /lib/modules:/lib/modules \
    -v /boot:/boot -v /:/host"

docker_run_rmit(){     docker run --rm -it $mode_host -v $PWD:/data -w /data $* ; }
docker_run_vim() {     docker_run_rmit --entrypoint vim haron/vim $1 ; }
docker_run_vim_py() {  docker_run_rmit --entrypoint vim fedeg/python-vim $1 ; }

# handling parameters

for func in "$@"; do
    run "docker_$func"
done