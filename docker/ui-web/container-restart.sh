n=container-restart
docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

#GREP_E_STRING="^hy"
GREP_vE_STRING="portainer"
TIMEZONE="Asia/Shanghai"

docker run -d \
  --restart unless-stopped \
  --name $n  \
  -p 5000:5000 \
  -e GREP_E_STRING=$GREP_E_STRING \
  -e GREP_vE_STRING=$GREP_vE_STRING \
  -e TIMEZONE=$TIMEZONE \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/app \
  fzinfz/python:flask-docker \
  python /app/container-restart.py