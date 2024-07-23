/ip firewall mangle
add action=accept chain=prerouting dst-address=192.168.89.0/24 in-interface=Local
add action=accept chain=prerouting dst-address=192.168.88.0/24 in-interface=Local

add action=mark-connection chain=prerouting dst-address-type=!local in-interface=Local new-connection-mark=WAN1_conn passthrough=yes per-connection-classifier=both-addresses-and-ports:2/0
add action=mark-connection chain=prerouting dst-address-type=!local in-interface=Local new-connection-mark=WAN2_conn passthrough=yes per-connection-classifier=both-addresses-and-ports:2/1
add action=mark-connection chain=input in-interface=WAN1 new-connection-mark=WAN1_conn
add action=mark-connection chain=input in-interface=WAN2 new-connection-mark=WAN2_conn

add action=mark-routing chain=prerouting connection-mark=WAN1_conn in-interface=Local new-routing-mark=to_WAN1
add action=mark-routing chain=prerouting connection-mark=WAN2_conn in-interface=Local new-routing-mark=to_WAN2
add action=mark-routing chain=output connection-mark=WAN1_conn new-routing-mark=to_WAN1
add action=mark-routing chain=output connection-mark=WAN2_conn new-routing-mark=to_WAN2

/ip firewall nat
add action=masquerade chain=srcnat out-interface=WAN2
add action=masquerade chain=srcnat out-interface=WAN1

/ip route
add check-gateway=arp disabled=yes distance=3 gateway=WAN1 routing-mark=to_WAN1
add check-gateway=arp disabled=yes distance=1 gateway=WAN2 routing-mark=to_WAN2
add distance=1 dst-address=10.0.0.0/8 gateway=WAN1
