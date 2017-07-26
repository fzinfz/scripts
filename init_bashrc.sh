cat >> ~/.bashrc << EOL

alias git_add_commit_push="git add -A ; git commit -am 'update' ; git push"

export docker_run_host='--privileged --cap-add=ALL -it -v /dev:/dev -v /lib/modules:/lib/modules --pid=host --ipc=host --net host -v /:/host'

mkdir ~/.dir_colors
eval `dircolors ~/.dir_colors`
alias ls="ls --color=auto"

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

EOL

source ~/.bashrc
