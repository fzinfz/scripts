/caps-man security
add authentication-types=wpa2-psk encryption=aes-ccm group-encryption=aes-ccm \
    name=WPA2-AES passphrase=00000000

/caps-man configuration
# set vlan: datapath.vlan-id=10 datapath.vlan-mode=use-tag # `Datapaths` Tab: empty
add channel.band=2ghz-b/g/n channel.control-channel-width=20mhz \
    channel.extension-channel=XX country=china \
    datapath.client-to-client-forwarding=yes datapath.local-forwarding=yes \
    name=cfg-2ghz security=WPA2-AES ssid=Mesh-2.4G
add channel.band=5ghz-a/n/ac channel.control-channel-width=20mhz \
    channel.extension-channel=XXXX country=china \
    datapath.client-to-client-forwarding=yes datapath.local-forwarding=yes \
    name=cfg-5ghz-ac security=WPA2-AES ssid=Mesh-5G
add channel.band=5ghz-a/n channel.control-channel-width=20mhz \
    channel.extension-channel=XX country=china \
    datapath.client-to-client-forwarding=yes datapath.local-forwarding=yes \
    name=cfg-5ghz-an security=WPA2-AES ssid=Mesh-5G

/caps-man provisioning
add action=create-dynamic-enabled hw-supported-modes=gn master-configuration=\
    cfg-2ghz name-format=prefix-identity name-prefix=2ghz
add action=create-dynamic-enabled hw-supported-modes=ac master-configuration=\
    cfg-5ghz-ac name-format=prefix-identity name-prefix=5ghz-ac
add action=create-dynamic-enabled hw-supported-modes=an master-configuration=\
    cfg-5ghz-an name-format=prefix-identity name-prefix=5ghz-an

/caps-man manager
set enabled=yes