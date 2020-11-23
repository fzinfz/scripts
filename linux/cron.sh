source ./init.sh

dir_git_parent=/data

mkdir -p /var/log/cron

run "service cron status | head -3"

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; 
run "echo '5-55/10 * * * * root $SCRIPTPATH/git.sh $dir_git_parent status 2>&1 > /var/log/cron/git.log' | crontab -"

run "crontab -l"
echo_tip "To edit manually: crontab -e"