if [ "$0" = "source_OR_bash.sh" ]; then
	echo "called by $"
	alias quit=exit; 
else 
	echo "called by source"
	alias quit=return; 
fi

echo '$0:'$0

echo 'ps of $$:'
ps -p $$ -o comm=

echo 'ps tree of $$:'
ps -efHww | grep $$ --color

type quit
quit
