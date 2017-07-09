cat >> ~/.bashrc << EOL

alias git_add_commit_push="git add -A ; git commit -am 'update' ; git push"

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

EOL

source ~/.bashrc
