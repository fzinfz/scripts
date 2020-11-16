SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; [ -f $SCRIPTPATH/init.sh ] && source $SCRIPTPATH/init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

[ -z "$1" ] && read -p "Parent folder: " p || p=$1
[ -z "$2" ] && action='status' || action=$2

for d in $(ls -d $p/*); do
    if [ -d $d/.git ]; then
        ls -d $d
        cd $d && git $action
        echo_yellow $(linesep -)
    fi
done