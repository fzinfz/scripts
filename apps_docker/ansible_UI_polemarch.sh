. ../linux/init.sh

echo_tip https://about.polemarch.org/en/latest/quickstart.html#install-from-docker

n=polemarch ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run --name polemarch \
    --restart always --net host -d \
    -v /data/conf/polemarch/projects:/projects \
    -v /data/conf/polemarch/hooks:/hooks \
    vstconsulting/polemarch
    
echo_tip ":8080 admin/admin"
echo_tip https://about.polemarch.org/en/latest/gui.html

docker logs -f $n