. ../linux/init.sh
. ../lib/file.sh

echo_title $SHELL | grep bash
[ $? -eq 0 ] && if_replace_file ./conf/bash_profile.sh ~/.bash_profile
run "grep color ~/.bashrc"
cmd vim && if_replace_file ./conf/vimrc ~/.vimrc

echo_title 'setup timezone'
timedatectl set-ntp true
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone

echo_title 'setup git'
run git config --global push.default simple
run git config --global pull.ff only
run git config user.name fzinfz
run git config user.email $(grep email ../.git/config | cut -d= -f2)

echo_title 'chmod'
for d in apps_docker cloud linux my nw web; do 
    run "chmod +x ../$d/*.sh"
done

run "chmod -x ../lib/*.sh"

echo_title 'create links for /data'
for p in /data_*; do
    echo_title $p
    ls /data_1T/* &>/dev/null || continue
    for p2 in $(ls -d $p/*); do
        n=`basename $p2`
        if [ -d "/data/$n" ]; then
            [ ! -L /data/$n ] && echo_warn `ls -ld /data/$n`
        else
            [ -d $p2 ] && run ln -s $p2 /data/$n
        fi
    done
done

run . ~/.bash_profile