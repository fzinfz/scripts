. ../lib/docker.sh

echo_title 'systemctl enable'
run "service docker status | grep Loaded | grep 'disabled;'"
[ $? -eq 0 ] && run 'systemctl enable --now docker.service'
run 'service docker status | head -3'

echo_title 'cleaning up'
run "type docker_rmi_all_none"
docker_rmi_all_none

echo_title 'docker images'
run 'docker images --format "{{.Repository}}:{{.Tag}}" | sort'
run 'docker images --format "{{.Size}}\t{{.Repository}}:{{.Tag}}" | sort -h'
run 'docker images --format "{{.CreatedAt}}\t{{.Repository}}:{{.Tag}}" | sort'

echo_title 'docker ps'
run 'docker ps'
run 'docker ps --no-trunc --format "{{.Names}}  \t : {{.Command}}" | sort'
run 'docker ps --no-trunc --format "{{.Names}}  \t : {{.Mounts}}"  | sort'

echo_title 'check os'
doker_dir=$(docker info 2>/dev/null | grep "Docker Root Dir" | cut -d: -f2)
run "df -h $doker_dir"

run "free -h"