docker_init(){
    d=${PWD##*/}
    f=$(basename $0 .sh)
    n=${d}_${f}
    run "docker stop $n 2>/dev/null; docker rm $n 2>/dev/null"
}