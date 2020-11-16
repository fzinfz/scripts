source ./init.sh

[ ! -d /etc/supervisor ] && apt install -y supervisor

run 'service supervisor status | head -3'

file_conf=/etc/supervisor/supervisord.conf
[ ! -f ${file_conf}.bak ] && run "cp -p ${file_conf} ${file_conf}.bak"

run "diff ${file_conf} ${file_conf}.bak"


dir_conf=/etc/supervisor/conf.d

echo_tip "cp files manually"
for f in $(ls supervisor/*.conf); do
    n=$(basename $f)
    [ ! -f $dir_conf/$n ] && echo "cp -p $f $dir_conf/"
done

run "ls -l $dir_conf"
run 'supervisorctl reload'
run 'ss -lntup | grep supervisord'

run 'supervisorctl status'