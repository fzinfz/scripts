#!/bin/bash

p=$1
shift

case $p in 
	update ) 
		cmd="curl https://raw.githubusercontent.com/fzinfz/notes/master/_run.sh > _run.sh"
		;;
	nmap )
		cmd="$p -sV -p$2 $1"
		;;
	dd_bw )
		cmd="dd if=/dev/zero of=/root/testfile bs=200M count=1 oflag=direct"
		;;
	dd_iops )
		cmd="dd if=/dev/zero of=/root/testfile bs=512 count=1000 oflag=direct"
		;;
	*)
esac

echo $cmd
eval $cmd
