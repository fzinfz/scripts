source ./init.sh

dir_git_parent=/data

mkdir -p /var/log/cron

run "service cron status | head -3"

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; 
cat <<EOF | crontab -
SHELL=/bin/bash

5-55/10 * * * * $SCRIPTPATH/git.sh $dir_git_parent pull &>/var/log/cron/git.log
EOF

run "crontab -l"
echo_tip "To edit manually: crontab -e"
echo_tip "To check log: tail -f /var/log/syslog | grep -i cron"
