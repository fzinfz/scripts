shopt -s expand_aliases

[ "$(tty | grep pts | wc -l)" -gt 0 ] && tty

echo '$SHELL:' $SHELL
echo '$0:' $0
echo '$BASH_VERSION:' $BASH_VERSION
echo

# write in one line: not working
if [ "$0" = "source_OR_sh.sh" ]; then
	echo "called by *sh*"
	alias q=exit
else 
	echo "called by source"
	alias q=return
fi
type q

echo
echo 'ps of $$:'
ps -p $$ -o comm=

echo
echo 'ps tree of $$:'
ps -efHww | grep $$ --color

q 11