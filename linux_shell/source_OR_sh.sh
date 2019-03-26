# sh/source working; bash not working

# write in one line: not working
if [ "$0" = "source_OR_bash.sh" ]; then
	echo "called by $"
	alias q=exit; 
else 
	echo "called by source"
	alias q=return; 
fi

echo '$0:'$0

echo 'ps of $$:'
ps -p $$ -o comm=

echo 'ps tree of $$:'
ps -efHww | grep $$ --color

type q
q
