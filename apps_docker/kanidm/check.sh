docker run --rm -i -t -v kanidmd:/data \
    -v $PWD/server.toml:/data/server.toml \
    kanidm/server:latest /sbin/kanidmd configtest