. ../linux/init.sh

dir_git_parent=/data

dir_cron_log=/tmp/cron
mkdir -pv $dir_cron_log


run "service cron status"

crontab -l | grep -q git.log && {

    run "cat $dir_cron_log/git.log" 

}|| {

    run "crontab -l | grep -vE ^# # before edit"

    (crontab -l; echo "5-55/10 * * * * cd /data/scripts/linux && ./git.sh /data pull &>$dir_cron_log/git.log") | crontab -

    run "crontab -l | grep -vE ^# # after edit"
    run "ls -lh $dir_cron_log/git.log"

}

echo_tip "To edit manually: crontab -e"
echo_tip "journalctl -u cron.service | tail -10"