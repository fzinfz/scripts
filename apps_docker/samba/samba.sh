. ./_pre.sh

n=samba ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

FOLDER_SAMBA=/data/share/data # permission may be changed?

run "\
docker run  --restart=unless-stopped --net host --name $n  \
        -v $FOLDER_SAMBA:$FOLDER_SAMBA -d \
        dperson/samba -p -s 'public;$FOLDER_SAMBA;yes;no'
"

sleep 2

./_post.sh $n
