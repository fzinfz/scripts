if [ -d /data/scripts/lib ]; then
	cd /data/scripts/lib && for f in *.sh; do . $f; done
fi

cd /data

alias cdl="cd /data/scripts/linux/"
