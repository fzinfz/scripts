cat /etc/config/dhcp | grep -E '^config|leasefile'; echo

for f in $(cat /etc/config/dhcp | grep leasefile | grep -o "/[^']*"); do
    echo "# $f"; cat $f; echo; 
done