. ../linux/init.sh

sshd_change_port(){
    sed -r -i "s/^[#]? *Port .*/Port $1/" /etc/ssh/sshd_config
    grep ^Port /etc/ssh/sshd_config
}

sshd_allow_root_login(){
    sed -r -i 's/^[#]? *PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    grep PermitRootLogin /etc/ssh/sshd_config
}

sshd_change_root_password(){
    echo "root:${1}" | chpasswd
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