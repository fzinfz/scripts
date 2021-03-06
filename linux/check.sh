. ./init.sh

for tag in disk ../nw/check sys video; do 
    for f in ${tag}*.sh; do
        echo_tip "./$f"; 
        cat $f | grep_functions
        echo
    done
done

echo_tip ../nw/ovs.sh