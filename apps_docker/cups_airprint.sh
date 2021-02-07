docker run \
    -d --restart unless-stopped \
    --name=cups \
    --net=host \
    -v /var/run/dbus:/var/run/dbus \
    --device /dev/bus \
    --device /dev/usb \
    -e CUPSADMIN="admin" \
    -e CUPSPASSWORD="admin" \
    tigerj/cups-airprint