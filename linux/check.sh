[ -f init.sh ] && source ./init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

for tag in disk network sys video; do 
    f=check_${tag}.sh
    echo_title "Running $f"; 
    cat_script $f | grep_functions
    echo
    [ -f $f ] && bash $f
    echo
done