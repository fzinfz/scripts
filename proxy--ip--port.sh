export http_proxy=http://$1:$2/
export https_proxy=$http_proxy 
export no_proxy="localhost,127.0.0.1,192.168.*.*,10.*.*.*,172.16.*.*,172.23.*.*"
export ftp_proxy=$http_proxy
export rsync_proxy=$http_proxy
