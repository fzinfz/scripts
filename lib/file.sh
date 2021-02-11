curl_download--url(){
    curl -sSLO $1
    # -S, --show-error    Show error. With -s, make curl show errors when they occur
    # -s, --silent        Silent mode (don't output anything)
    # -o, --output FILE   Write to FILE instead of stdout
    # -O, --remote-name   Write output to a file named as the remote file
    # -L, --location      Follow redirects (H)
}

rsync--local--remote---port() { rsync -aP -e "ssh -p $3" $1 $2 ; }

grep_in_files--regex--path---ext() {
    s="grep --color=auto --line-number --exclude-dir=.ipynb_checkpoints"
    [ -n "$3" ] && s="$s --include \*.$3"
    
    s="$s -r -P '$1' $2"
    run "$s"
}

find--path--name() {
    find $1 -iname $2
    # find . ! -readable / -writable / -executabl
    # find . ! -perm -g=w
}

_archive_handle(){
    file $f | grep "$1"
    if [ $? -eq 0 ]; then
        run "$2 $3 $f"
        read -p "Extract? (y/n) " a
        [ "$a" = "y" ] && run "$2 $4 $f"
        
        func_exit "Done!"
    fi
}

archive_handle(){
    f=$1
    
    func_exit() { : "${__exit:?$1}"; }
    
    _archive_handle "gzip compressed data" tar tvf xvf
    _archive_handle "xar archive" 7z l x
    _archive_handle "" 7z l x
}

if_replace_file(){
    src=$1
    dest=$2
    if [ ! -f $dest ]; then
        run "cp -pv $src $dest"
    else
        run "diff $src $dest"
        if [ $? -ne 0 ]; then
            if [ -f $dest ]; then
                run "head $dest"
                run "cat $dest | wc -l"
                action="rm -f $dest"
                ask "${action} ?"
                [[ $a =~ [Yy] ]] && run $action
            fi
            [ -f $dest ] || cp -pv $src $dest
        fi
    fi    
}