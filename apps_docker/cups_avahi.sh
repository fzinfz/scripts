docker run -d --rm \
    -e CUPS_WEBINTERFACE="yes" \
    -e CUPS_REMOTE_ADMIN="yes" \
    --name cups-avahi \
    drpsychick/airprint-bridge

echo "http :631"

echo /etc/cups/printers.conf