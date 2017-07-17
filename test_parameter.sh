if [ -z $1 ];then
	echo "zero length"
fi

if [ -z ${1+x} ]; then
	echo "null"
fi
