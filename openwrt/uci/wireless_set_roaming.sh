for n in $(uci show wireless | grep "mode='ap'" | cut -d. -f2); do 
uci set wireless.$n.ieee80211r='1'
uci set wireless.$n.mobility_domain='0591'
uci set wireless.$n.ft_over_ds='0'
uci set wireless.$n.ft_psk_generate_local='1'
uci set wireless.$n.bss_transition='1'
done

uci commit wireless && wifi reload
