# check

docker_images(){
    echo_title 'docker images'
    run 'docker images | (sed -u 1q; sort)'
    run 'docker images --format "table {{.Size}}\t{{.Repository}}:{{.Tag}}" | sort -h'
    run 'docker images --format "table {{.CreatedAt}}\t{{.Repository}}:{{.Tag}}" | sort -h'
}
alias di=docker_images

docker_status(){
    echo_title "docker info"
    docker info 2>/dev/null | grep Proxy
    docker info 2>/dev/null | perl -ne 'print if /Registry Mirrors/ ... /Live/' | head -n -1
    
    echo_title "docker ps"
    run 'docker ps --format "table {{.CreatedAt}}\t{{.Names}}\t{{.Status}}" | sort -h'
    run 'docker ps --format "table {{.Names}}\t{{.ID}}\t{{.Ports}}" | (sed -u 1q; sort)' 
    run 'docker ps --no-trunc --format "{{.Names}}\t : {{.Command}}" | sort' && echo
    run 'docker ps --no-trunc --format "table {{.Names}}\t : {{.Mounts}}"  | (sed -u 1q; sort)'
}
alias dk=docker_status

# volumn

docker_volumes_cd(){
    [ -z "$1" ] && cd /var/lib/docker/volumes/ || \
        cd $(docker inspect --format='{{.Mounts}}' $1 | grep -oP '/\S+' | head -1)
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
    run "docker container update $1 --restart unless-stopped"
    echo_tip other options: no always on-failure[:max-retries]
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
