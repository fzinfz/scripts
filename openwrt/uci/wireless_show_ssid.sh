echo -e "mode \t key \t ssid"
for n in $(uci show wireless | grep -E "mode='(ap|sta)'" | cut -d. -f2); do 
echo -n $(uci show wireless.$n.mode | cut -d"'" -f2)
echo -n -e " \t "
echo -n $(uci show wireless.$n.key | cut -d"'" -f2)
echo -n -e " \t "
echo -n $(uci show wireless.$n.ssid | cut -d"'" -f2)
echo
done | sort
