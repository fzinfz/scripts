. ../linux/init.sh

echo_title $SHELL | grep bash
if [ $? -eq 0 ]; then    
    if [ -f ~/.bash_profile ]; then
        run "head ~/.bash_profile"
    else
        cp -pv bash_profile.sh ~/.bash_profile_my
        echo '. ~/.bash_profile_my' > ~/.bash_profile
    fi
fi

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
    for p2 in $(ls -d $p/*); do
        n=`basename $p2`
        if [ -d "/data/$n" ]; then
            [ ! -L /data/$n ] && echo_warn `ls -ld /data/$n`
        else
            [ -d $p2 ] && run ln -s $p2 /data/$n
        fi
    done
done
run ls /data/ -l