ping nfs.home -c 1 | grep icmp_seq 1>/dev/null
if [ $? -eq 0 ]; then
	cd /data/scripts/lib && for f in *.sh; do . $f; done
fi

cd /data
