cat >> ~/.bashrc << EOL

alias git_add_commit_push="git add -A ; git commit -am 'update' ; git push"
alias ls="ls --color=auto"

export docker_run_d='-d --restart unless-stopped'
export docker_run_host='--privileged --cap-add=ALL -it -v /dev:/dev -v /lib/modules:/lib/modules --pid=host --ipc=host --net host -v /:/host'

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

EOL

source ~/.bashrc
