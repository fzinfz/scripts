source ./init.sh

alias git_gitignore_download_py="wget https://raw.githubusercontent.com/fzinfz/tsadmin/master/.gitignore"

# undo

alias git_discard_changes="git checkout -- ."

git_discard_change--files(){
    git restore --staged "$@"
    git checkout -- "$@"
    git status
}

alias git_unstage="git reset HEAD "
alias git_uncommit="git reset --soft HEAD~1"

alias git_stop_track="git update-index --assume-unchanged"
alias git_resume_track="git update-index --no-assume-unchanged"

# commit

alias git_commit_reuse_previous_message="git commit -c ORIG_HEAD"
alias git_commit_amend="git commit --amend -C ORIG_HEAD"

git_add_commit---comment() {
    [ -z $1 ] && c='update' || c=$1
    git commit -am "$c"
}

# log

git_log---head(){
    [ -z "$1" ] && items=5 || items=$1
    git log | grep -v ^Author | grep -v ^$ | grep commit.* -A2 | head -n $(echo "$items * 3" | bc)
}

# diff

git_diff_staged---files(){
    git diff --cached $@
}

alias git_diff_last_commit="git show"

# config

alias git_config_show="git config --list --show-origin"

git_config_proxy_http--ip--port(){
    git config --global http.proxy http://$1:$2
}
