. ../linux/init.sh

dir_git_parent=/data

mkdir -p /var/log/cron

run "service cron status | head -3"

run "crontab -l # before"

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; 
cat <<EOF | crontab -
SHELL=/bin/bash

5-55/10 * * * * cd /data/scripts/linux && ./git.sh /data pull &>/var/log/cron/git.log
0 2 * * * docker exec jupyter bash -c "cd /data/flask-DLT645 && echo y | ./push_to_influxdb.sh" &>/tmp/influxdb.txt
EOF

run "crontab -l # after"
echo_tip "To edit manually: crontab -e"
run "ls -lh /var/log/cron/git.log"
run "tail -f /var/log/syslog | grep -i cron"
