. ../_pre.sh

echo_tip https://about.polemarch.org/en/latest/quickstart.html#install-from-docker

POLEMARCH_PORT=9180

n=polemarch ; docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run --name polemarch \
    --restart always -d \
    -p $POLEMARCH_PORT:8080 \
    -v /data/docker-data/polemarch/projects:/projects \
    -v /data/docker-data/polemarch/hooks:/hooks \
    vstconsulting/polemarch
    
echo_tip ":$POLEMARCH_PORT admin/admin"
echo_tip https://about.polemarch.org/en/latest/gui.html

../_post.sh $n