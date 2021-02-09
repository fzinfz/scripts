

ps -ef | grep qemu | grep -oP '(guest|mac|file)=\S*' | grep -v master-key.aes | perl -pe 's/guest/\nguest/g'