SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; [ -f $SCRIPTPATH/init.sh ] && source $SCRIPTPATH/init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

[ -z "$1" ] && read -p "Parent folder: " p || p=$1
[ -z "$2" ] && action='status' || action=$2

echo_script_header

for d in $(ls -d $p/*); do
    if [ -d $d/.git ]; then
        cd $d && run "git $action # $d"
        echo_yellow $(linesep -)
    fi
done

echo_script_header
