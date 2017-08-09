alias git_add_commit_push="git add -A ; git commit -am 'update' ; git push"
alias ls="ls --color=auto"

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

export TZ=Asia/Shanghai
