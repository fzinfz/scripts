# https://github.com/alexanderfefelov/docker-dude/blob/master/Dockerfile

docker run \
  --name dude \
  --detach \
  --restart unless-stopped \
  --volume /etc/localtime:/etc/localtime:ro --volume /etc/timezone:/etc/timezone:ro \
  --volume dude:/dude/data \
  --publish 85:80 \
  --publish 5443:443 \
  --publish 514:514/udp \
  --publish 2210:2210 \
  --publish 2211:2211 \
  --health-cmd /healthcheck.sh --health-start-period 3s --health-interval 1m --health-timeout 1s --health-retries 3 \
  --log-opt max-size=10m --log-opt max-file=5 \
  alexanderfefelov/dude
