source ./init.sh

alias git_gitignore_download_py="wget https://raw.githubusercontent.com/fzinfz/tsadmin/master/.gitignore"

alias git_discard_changes="git checkout -- ."
alias git_unstage="git reset HEAD "
alias git_uncommit="git reset --soft HEAD~1"

alias git_commit_reuse_previous_message="git commit -c ORIG_HEAD"
alias git_commit_amend="git commit --amend -C ORIG_HEAD"

git_add_commit---comment() {
    [ -z $1 ] && c='update' || c=$1
    git commit -am "$c"
}

git_log---head(){
    [ -z "$1" ] && items=5 || items=$1
    git log | grep -v ^Author | grep -v ^$ | grep commit.* -A2 | head -n $(echo "$items * 3" | bc)
}

alias git_diff_staged="git diff --cached"