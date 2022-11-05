. ../linux/init.sh

[ -f /data/conf/init.sh ] && . /data/conf/init.sh

run "free -h"

if_my_VPS(){ hostname | grep -P "\w+\d+[cC]\d+[gG]" 1>/dev/null; } 
if_tailscale(){ run 'ip addr | grep tailscale | grep inet | grep -oP "100\S+(?=/)"'; }
ip_vpn(){ ip addr | grep -oP "(?<=inet )100[.\d]+"; }
