. ../linux/init.sh

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
