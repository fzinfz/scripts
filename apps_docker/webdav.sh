docker run --restart always -v /data/share:/var/lib/dav \
    -e ANONYMOUS_METHODS=ALL \
    --publish 8088:80 -d bytemark/webdav
