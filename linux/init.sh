#!/bin/bash

shopt -s expand_aliases

alias ls="ls --color=auto"
alias ll="ls -l"

now(){ date "+%H:%M:%S"; }

echo_color(){ 
    color=$1
    shift
    echo -e "\e[${color}m$@\e[0m"
}

echo_green(){          echo_color 92 "$@"; }
echo_red(){            echo_color 91 "$@"; }
echo_yellow(){         echo_color 93 "$@"; }
echo_cyan(){           echo_color 36 "$@"; }
echo_cyan_bright(){    echo_color 96 "$@"; }

echo_success(){        echo_green "[$(now)] <SUCCESS> $@"; }
echo_error(){            echo_red "[$(now)] <ERROR> $@"; }
echo_hightlight(){    echo_yellow "[$(now)] <!!!> $@"; }
echo_debug(){           echo_cyan "[$(now)] <DEBUG> $@"; }
echo_info(){     echo_cyan_bright "[$(now)] <INFO> $@"; }

linesep(){
    columns=$(expr $(tput cols)  - 20)
    for i in $(seq 1 $columns); do printf "$1"; done
}

echo_script_header(){ echo_yellow $(linesep -); echo_info `whoami` @ `hostname` @ `date` ; echo; }

run(){ echo_debug "$@"; eval "$@"; }
run_title(){ echo_hightlight "$@"; eval "$@"; }

curl_N_source__url() { source /dev/stdin <<< "$(curl -sSL $1)"; }

## Parameters: file [echo_prefix]
grep_functions(){ grep -oP '^\w[^(]+(?=\()' ; }

run_if_shell(){
    if [ -z "${0##*.sh}" ]; then
        echo_script_header
        for cmd in $(cat $0 | grep_functions); do run_title "$cmd"; done
    fi
}

# git

alias git_commit_reuse_previous_message="git commit -c ORIG_HEAD"
alias git_commit_amend="git commit --amend -C ORIG_HEAD"
alias git_discard_changes="git checkout -- ."
alias git_unstage="git reset HEAD "
alias git_uncommit="git reset --soft HEAD~1"
alias git_gitignore_download-py="wget https://raw.githubusercontent.com/fzinfz/tsadmin/master/.gitignore"

git_add_commit_push---comment() {
    if [ -z $1 ];then
        c='update'
    else
        c=$1
    fi

    git add -A
    git commit -am "$c"
    git push
}