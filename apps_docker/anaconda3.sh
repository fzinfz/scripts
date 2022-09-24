n=anaconda3
docker stop $n 2>/dev/null; docker rm $n 2>/dev/null

docker run -d --net host --name $n \
    --restart unless-stopped \
    -v /data:/data \
    continuumio/anaconda3 /bin/bash -c "\
    jupyter notebook \
    --notebook-dir=/data --ip='*' --port=8890 \
    --no-browser --allow-root"

echo "docker exec -it $n /bin/bash"
echo "(conda list | grep jupyter) || conda install jupyter -y --quiet"
    