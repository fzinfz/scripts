. ./init.sh

cd $DIR_CERT

for f in $(ls $DIR_CERT); do
    ls -l $f
    cat $f | grep BEGIN -A1
    [ $? -ne 0 ] && cat $f && echo
    echo_yellow $(linesep -)
done
