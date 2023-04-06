. ./init.sh

ip route | grep ^default | xargs -I %s -- echo ip route del %s
echo_tip ip route replace 