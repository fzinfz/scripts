docker run -i -t --net host --name anaconda3 \
    -v /data:/data \
    continuumio/anaconda3 /bin/bash -c "\
    jupyter notebook \
    --notebook-dir=/data --ip='*' --port=8888 \
    --no-browser --allow-root"

