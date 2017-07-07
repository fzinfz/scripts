sed -r -i 's/[#]?Port 22/Port $1/' /etc/ssh/sshd_config
service sshd restart
