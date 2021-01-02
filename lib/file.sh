. ../linux/init.sh

curl_download--url(){
    curl -sSLO $1
    # -S, --show-error    Show error. With -s, make curl show errors when they occur
    # -s, --silent        Silent mode (don't output anything)
    # -o, --output FILE   Write to FILE instead of stdout
    # -O, --remote-name   Write output to a file named as the remote file
    # -L, --location      Follow redirects (H)
}

rsync--local--remote---port() { rsync -aP -e "ssh -p $3" $1 $2 ; }

grep_in_files--regex--path() {
    grep --color=auto -rn -P "$1" $2
    # -r, --recursive           like --directories=recurse
    # -n, --line-number         print line number with output lines
    # -P, --perl-regexp         PATTERN is a Perl regular expression
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

mount_iso--flename--mountpoint() {
    mount -o loop,ro $1 $2
}

mount_nfs--server_ip--path--local_path() {
    mount.nfs $1:$2 $3
    #mount -tnfs4 -ominorversion=1 server_nfs_4.1:/dir
}

mount_cifs_N_fstab--path--mountpoint---user--passwd(){

    echo_tip "make sure single quoted network path, eg: '\\server\folder'"

    path=$1
    mount_point=$2
    [ -z $3 ] && user=administrator || user=$3
    passwd=$4

    run "mount -t cifs $path $mount_point -o username=$user,password=$passwd"

    echo_tip echo $path $mount_point cifs username=$user,password=$passwd 0 0 >>  /etc/fstab
    
}