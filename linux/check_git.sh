SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; [ -f $SCRIPTPATH/init.sh ] && source $SCRIPTPATH/init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

p=$1
for d in $(ls -d $p/*); do
    if [ -d $d/.git ]; then
        ls -d $d
        cd $d && git status
        echo_yellow $(linesep -)
    fi
done