sed -r -i "s/^[#]? *Port .*/Port $1/" /etc/ssh/sshd_config
service sshd restart
