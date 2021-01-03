. ../linux/init.sh

n=$1

run "docker ps | grep -P '^CONTAINER|$n'"

run "docker stats --no-stream | grep -P '^CONTAINER|$n'"

run "free -h"

