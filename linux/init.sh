#!/bin/bash

shopt -s expand_aliases

alias ls="ls --color=auto"

now(){ date "+%H:%M:%S"; }
ts(){ date "+%Y%m%d_%H%M%S"; }

echo_color(){ color=$1; shift; echo -e "\e[${color}m$@\e[0m"; }
echo_green(){          echo_color 92 "$@"; }
echo_red(){            echo_color 91 "$@"; }
echo_yellow(){         echo_color 93 "$@"; }
echo_magenta(){        echo_color 95 "$@"; }
echo_cyan(){           echo_color 36 "$@"; }
echo_cyan_bright(){    echo_color 96 "$@"; }

echo_success(){        echo_green "[$(now)] <SUCCESS> $@"; }
echo_error(){            echo_red "[$(now)] <ERROR> $@"; }
echo_warn(){         echo_magenta "[$(now)] <WARN> $@"; }

echo_debug(){           echo_cyan "[$(now)] <DEBUG> $@"; }
echo_info(){     echo_cyan_bright "[$(now)] <INFO> $@"; }
echo_tip(){          echo_magenta "[$(now)] <TIP> $@"; }

echo_hightlight(){    echo_yellow "[$(now)] <!!!> $@"; }
echo_title(){         echo_yellow "[$(now)] <TITLE> $@"; }

BC=$'\e[95m'; EC=$'\e[0m'; 
q(){   read -p "${BC}[$(now)] <Question> $1${EC} " ${2:-a} ; }
ask(){ read -p "${BC}[$(now)] <Question> $1${EC} (y/n) " ${2:-a} ; }
ask_run(){ ask "$@"; [[ $a =~ [Yy] ]] && run "$@"; }
pause(){ read -p "${BC}[$(now)] Press <ENTER> to continue${EC} " ; }
pause_run(){ echo; read -p "${BC}[$(now)] Press <ENTER> to run $1 or <Ctrl+C> to quit${EC} " ; }

linesep(){    
    if [ "$TERM" = "xterm" ]; then
        columns=$(expr $(tput cols)  - 20)
    else
        columns=30
    fi
    
    for i in $(seq 1 $columns); do printf "$1"; done
}

echo_script_header(){ echo_yellow $(linesep -); echo_info `whoami` @ `hostname` @ `date` \| $0 ; echo; }
alias echo_header=echo_script_header

cmd(){ command -v $1 &>/dev/null ; }

exit_err(){ echo_error "$1"; exit; }

run(){ echo_debug "$@"; eval "$@"; }
run_title(){ echo_title "$@"; eval "$@"; }
run1(){ echo_debug "$@" | tr -d '\n'; echo_yellow ' ===> ' | tr -d '\n';  eval "$@"; }
runT(){ echo; echo_title "$@"; type "$@"; eval "$@"; }

read_if_empty(){ eval "[ -z \"\$$1\" ] && read -p '$1: ' $1 && export $1=\$$1"; }

curl_N_source() { source /dev/stdin <<< "$(curl -sSL $1)"; }
alias source_url=curl_N_source

cat_script(){ [ -f $1 ] && cat $1 || curl -sS https://raw.githubusercontent.com/fzinfz/scripts/master/linux/$1 ; }

grep_functions(){ grep -oP '^[a-z][^(]+(?=\(\)\{)' ; }  # func_name(){  
run_if_shell(){
    if [ -z "${0##*.sh}" ]; then
        echo_script_header
        for cmd in $(cat $0 | grep_functions); do run_title "$cmd"; done
    fi
}

cat_one_line_files(){
    for f in $1; do
        [ -f $f ] && printf "${BC}$f : ${EC}" && head -1 $f
    done            
}

select_file(){
    files=( $(ls $@ 2>/dev/null | sort) )
    
    if [ ${#files[@]} -eq 1 ]; then
        selected_file=${files[0]}
    elif [ ${#files[@]} -gt 1 ]; then 
        for i in "${!files[@]}"; do
          printf '[%s] %s\n' "$i" "${files[i]}"
        done

        read -p "Please input file index: " i
        [[ $i =~ [0-9]+ ]] || exit_err non-num
        selected_file=${files[i]}
    else
        selected_file=''
    fi
    echo_debug "selected_file=$selected_file"
}
