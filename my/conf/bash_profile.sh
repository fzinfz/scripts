if [ -f ~/.bashrc ]; then . ~/.bashrc; fi

if [ -d /data/scripts/lib ]; then
	cd /data/scripts/lib && for f in *.sh; do . $f; done
fi

alias cdl="cd /data/scripts/linux/"

cd /data && ls -l
