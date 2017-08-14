alias ls="ls --color=auto"
alias dd_bandwidth="dd if=/dev/zero of=/root/testfile bs=200M count=1 oflag=direct"
alias dd_iops="dd if=/dev/zero of=/root/testfile bs=512 count=10000 oflag=direct"

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

export TZ=Asia/Shanghai

# add current file path to $PATH
CURRENT_DIR=$(dirname "$(readlink -f "$BASH_SOURCE")")
if [[ ! $PATH = *"$CURRENT_DIR"* ]];then
    export PATH=$PATH:$CURRENT_DIR
fi

alias git_before_commit-remove--file="git reset HEAD"
alias git_commit-reuse_previous_message="git commit -c ORIG_HEAD"
alias git_commit_amend="git commit --amend -c ORIG_HEAD"
alias git_uncommit="git reset --soft HEAD~1"
alias git_upstream-merge="git fetch upstream; git checkout master; git merge upstream/master"
alias git_upstream-add--url="git remote add upstream"
alias git_gitignore_download-py="wget https://raw.githubusercontent.com/github/gitignore/master/Python.gitignore; mv *.gitignore .gitignore"

