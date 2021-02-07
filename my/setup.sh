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
for p in /data_*; do
    echo_title $p
    for p2 in $p/*/; do
        n=`basename $p2`
        if [ -d /data/$n ]; then
            [ ! -L /data/$n ] && echo_error `ls -ld /data/$n`
        else
            run ln -s $p2 /data/$n
        fi
    done
done
run ls /data/ -l