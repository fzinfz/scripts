ifconfig $1 down
brctl delbr $1

echo Modify \"/etc/network/interfaces\" manually
cat /etc/network/interfaces
