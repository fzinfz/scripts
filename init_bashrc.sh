cat >> ~/.bashrc << EOL

alias git_add_commit_push="git add -A ; git commit -am 'update' ; git push"

eval `dircolors ~/.dir_colors`
alias ls="ls --color=auto"

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

EOL

source ~/.bashrc
