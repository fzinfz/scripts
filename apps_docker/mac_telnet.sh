. ./_pre.sh

echo_tip https://github.com/haakonnessjoen/MAC-Telnet

run docker run -it --rm --net=host haakonn/mactelnet macping -h
run docker run -it --rm --net=host haakonn/mactelnet mactelnet -h

docker run -it --rm --net=host haakonn/mactelnet mactelnet -l -t 10 | uniq

[ -f /data/conf/mac_telnetd.conf ] && {
pause_run mactelnetd
docker run -v /data/conf/mac_telnetd.conf:/build/etc/mactelnetd.users \
    -it --rm --net=host haakonn/mactelnet mactelnetd -f 
}
