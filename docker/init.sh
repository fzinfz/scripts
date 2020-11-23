source ../linux/init.sh

run "docker info # install docker if error"
[ $? -ne 0 ] && curl -fsSL get.docker.com | sh

run "service docker status | grep Loaded | grep 'disabled;'"
[ $? -eq 0 ] && run 'systemctl enable --now docker.service'
run 'service docker status | head -3'