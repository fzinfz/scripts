. ../linux/init.sh

cd_docker_volumn(){
    [ -z "$1" ] && cd /var/lib/docker || \
        cd /var/lib/docker/volumes/$1/_data/
}

# Install

docker_install_from_curl(){  curl -fsSL get.docker.com | bash ; }
docker_install_from_apt(){   apt install -y docker.io ; }

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
docker_ps--container(){
    printf "ps -ef \n    "
    docker exec -it $1 ps -ef | grep -v 'ps -ef'
}

docker_inspect--container(){
    for k in .Name .HostConfig.Binds .Config.Cmd .Config.Entrypoint; do
        printf "$k\n    "
        docker inspect --format="{{$k}}" $1
    done
}

docker_inspect_all(){
    for c in $(docker ps -q); do
        docker_inspect--container $c
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
    docker_stop_all
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

docker_image_transfer--host--image(){
    run "docker save $2 | ssh -C $1 docker load"
}

docker_image_transfer_all--host(){
    [ -z "$1" ] && read -p 'Host: ' h || h=$1 
    for i in $(docker images | tail +2 | awk '{print $1}'); do
	docker_image_transfer--host--image $h $i
    done
}

docker_rmi_all(){        docker rmi $(docker images -q) ; }
docker_rmi_all_unused(){ docker image prune ; }

docker_rmi_all_none() {
    docker images | egrep '<none>' | awk '{print $3}' | xargs --no-run-if-empty docker rmi
}

# Run

docker_run_rmit(){     docker run --rm -it --net host -v $PWD:/data -w /data $* ; }
docker_run_vim() {     docker_run_rmit --entrypoint vim haron/vim $1 ; }
docker_run_vim_py() {  docker_run_rmit --entrypoint vim fedeg/python-vim $1 ; }
