SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"; 
[ ! -f ./init.sh ] && cd $SCRIPTPATH

for tag in disk network sys video; do 
    f=check_${tag}.sh
    echo_title "Running $f"; 
    cat_script $f | grep_functions
    echo
    [ -f $f ] && bash $f
    echo
done