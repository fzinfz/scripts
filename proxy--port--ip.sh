if [ -z ${2+x}; then
  ip="127.0.0.1"
 else
  ip=$2
 fi

if [ -z ${1+x}; then
  port=1080
 else
  port=$1
 fi
 
export http_proxy=http://$ip:$port  
export https_proxy=$http_proxy   
export no_proxy="localhost,127.0.0.1,192.168.*.*,10.*.*.*,172.16.*.*,172.17.*.*"  
export ftp_proxy=$http_proxy  
export rsync_proxy=$http_proxy
