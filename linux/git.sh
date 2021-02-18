. ./init.sh
. ../lib/git.sh

[ -z "$1" ] && p=/data || p=$1
[ -z "$2" ] && action='status' || action=$2

echo_script_header

git_config_show

for d in $(ls -d $p/*); do
    if [ -d $d/.git ]; then
        cd $d && run "git $action # $d"
        echo_yellow $(linesep -)
    fi
done

echo_script_header
