. ../linux/init.sh

# tmux

tmux_show_screen_keys(){
    cat /usr/share/doc/tmux/examples/screen-keys.conf | grep '\bbind \w'
}

# env

nl="printf \n"

add_current_path_to_PATH() {
    CURRENT_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
    if [[ ! $PATH = *"$CURRENT_DIR"* ]];then
        export PATH=$PATH:$CURRENT_DIR
    fi
}

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

history--tail_count() {
    if [ -z ${1+x} ] ;then
        cat /root/.bash_history
    else
        cat /root/.bash_history | tail -n$1
    fi

    # echo "if history items missing, run init_bashrc.sh first."
}

# ssh

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

sshd-change--port() {
    sed -r -i "s/^[#]? *Port .*/Port $1/" /etc/ssh/sshd_config
    service sshd restart
}

# 3rd party hw

hw_dell--ip--action() {
    echo actions: powerdown powerup powerstatus graceshutdown hardreset powercycle
    echo Doc: http://www.dell.com/support/manuals/us/en/04/integrated-dell-remote-access-cntrllr-8-with-lifecycle-controller-v2.00.00.00/racadm_idrac_pub-v1/serveraction?guid=guid-69ea52c5-153d-4369-b7c4-6694a3b9e0d4&lang=en-us
    ssh root@$1 "racadm serveraction  $2"
}
