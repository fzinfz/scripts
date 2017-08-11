alias ls="ls --color=auto"

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

export TZ=Asia/Shanghai

# add current file path to $PATH
CURRENT_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
if [[ ! $PATH = *"$CURRENT_DIR"* ]];then
    export PATH=$PATH:$CURRENT_DIR
fi
