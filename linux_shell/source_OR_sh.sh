shopt -s expand_aliases

echo "\$0: [$0]"

# write in one line: not working
if [ "$0" = "source_OR_sh.sh" ]; then
	echo "called by *sh*"
	alias q=exit
else 
	echo "called by source"
	alias q=return
fi

echo
echo 'ps of $$:'
ps -p $$ -o comm=

echo
echo 'ps tree of $$:'
ps -efHww | grep $$ --color

echo
type q
q 11