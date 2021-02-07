. ../linux/init.sh

echo_title $SHELL | grep bash
[ $? -eq 0 ] && [ ! -f ~/.bash_profile ] && cp -pv bash_profile ~/.bash_profile

[ ! -f ~/.vimrc ] && cp -pv vimrc ~/.vimrc

echo_title 'setup timezone'
timedatectl set-ntp true
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone

echo_title 'setup git'
git config --global push.default simple
git config user.name fzinfz
git config user.email fzinfz@gmail.com

echo_title 'chmod'
for d in apps_docker cloud linux my web; do 
    run "chmod 755 ../$d/*.sh"
done

echo_title 'create links for /data'
for d in /data_*; do
    echo_title $d
    for d2 in $d/*/; do
        n=`basename $d2`
        [ ! -d /data/$n ] && run ln -s $d2 /data/$n
    done
done
ls /data/ -l