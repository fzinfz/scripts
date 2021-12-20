# undo

git_undo(){
    read -p ". | files => " a
    run "git checkout -- $a"
    run git status
}

alias git_unstage="git reset HEAD"
alias git_uncommit="git reset --soft HEAD~1"

# index

alias git_stop_track="git update-index --assume-unchanged"
alias git_resume_track="git update-index --no-assume-unchanged"

# remove files

git_remove_from_all_commits--path(){
    git filter-branch --tree-filter "rm -rf $1" -- --all
    echo_tip "run: git push -f"
}

# pull

git_pull_force(){ 
    git fetch --all
    git reset --hard origin/master
}

# branch

git_clone--branch--url(){ git clone -b $1 $2; }

git_branch_new(){  git checkout -b $1 ; }

git_branch_rm(){ 
    run "git branch -d $1"
    run "git push origin --delete $1"
}

# commit

alias git_commit_reuse_previous_message="git commit -c ORIG_HEAD"

git_amend(){
    git add -A
    
    read -p "new msg: (Enter if no change) " a
    [ -z "$a" ] && run "git commit --amend -C HEAD" || run "git commit --amend -m '$a'"
    
    run git status
    
    ask "git push?"
    [ "$a" = "y" ] && git push -f
}

git_add_commit---comment() {
    git add -A
    [ -z $1 ] && c='update' || c=$1
    git commit -am "$c"
}


# log | https://stackoverflow.com/questions/1441010

git config --global alias.hs "log --pretty='%C(yellow)%h %C(cyan)%cd %Cblue%aN%C(auto)%d %Creset%s' --graph --date=relative --date-order"
git_log---lines(){ 
    [ -z "$1" ] && lines=15 || lines=$1
    git hs -${lines}; 
}

# diff

git_diff(){
    git status
    pause
    git diff --cached
}

alias git_diff_last_commit="git show"

# config

alias git_config_show="git config --list --show-origin"

git_config_proxy_http--ip--port(){
    git config --global http.proxy http://$1:$2
}

# misc

alias gitignore_py="curl -O https://raw.githubusercontent.com/fzinfz/tsadmin/master/.gitignore"
