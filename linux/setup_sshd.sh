[ -f init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

setup_sshd(){
    sshd_port=$1
    root_password=$2

    apt update || yum update
    apt install -y openssh-server || yum install -y openssh-server
    mkdir /var/run/sshd
    sed -r -i 's/^[#]? *PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -r -i "s/^[#]? *Port .*/Port ${sshd_port}/" /etc/ssh/sshd_config
    echo "root:${root_password}" | chpasswd
    /usr/sbin/sshd
}

# https://docs.docker.com/engine/examples/running_ssh_service/#run-a-test_sshd-container
# SSH login fix. Otherwise user is kicked off after login
#sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
#echo "export VISIBLE=now" >> /etc/profile

ssh_key_add() {
    if [ -z "$SSH_AUTH_SOCK" ] ; then
        eval `ssh-agent -s` 
        ssh-add 
    else
        echo "key exists: $SSH_AUTH_SOCK"
    fi
}

ssh_key_add_silent() {
    if [ -z "$SSH_AUTH_SOCK" ] ; then
        eval `ssh-agent -s` > /dev/null
        ssh-add > /dev/null
    fi
}

sshd-change__port() {
    sed -r -i "s/^[#]? *Port .*/Port $1/" /etc/ssh/sshd_config
    service sshd restart
}