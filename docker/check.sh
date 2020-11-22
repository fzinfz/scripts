source ../linux/init.sh

echo_title 'docker images'
run 'docker images --format "{{.Repository}}:{{.Tag}}" | sort'
run 'docker images --format "{{.Size}}\t{{.Repository}}:{{.Tag}}" | sort -h'
run 'docker images --format "{{.CreatedAt}}\t{{.Repository}}:{{.Tag}}" | sort'

echo_title 'docker ps'
run 'docker ps'
run 'docker ps --no-trunc --format "{{.Names}}\t{{.Image}}\t{{.Command}}" | sort'