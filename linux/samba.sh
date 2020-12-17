n=samba ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run  --restart=unless-stopped --net host --name $n  \
        -v /data:/data -d \
        dperson/samba -p -s "public;/data;yes;no"

sleep 2

docker logs -f samba
