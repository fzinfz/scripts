. ./init.sh

for tag in disk nw sys video; do 
    for f in ${tag}*.sh; do
        echo_tip "./$f"; 
        cat_script $f | grep_functions
        echo
    done
done