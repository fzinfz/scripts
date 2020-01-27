. init.sh

for f in check_*.sh; do 
    echo_title "Running $f"; 
    cat $f | grep_functions
    echo
    ./$f
    echo
done