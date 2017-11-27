#!/bin/bash

# https://www.gnu.org/software/bash/manual/bashref.html#Special-Parameters

set -e

ps -aux | grep $0
echo '$$': $$ $'\n    'process ID of the invoking shell, not the subshell.

echo '$?': $? $'\n    'exit status of the most recently executed foreground pipeline.
echo '$!': $! $'\n    'process ID of the job most recently placed into the background
echo '$#': $# $'\n    'parameters count
echo '$-': $- $'\n    'set flags

echo '$0': $0 $'\n    'name of the shell or shell script
echo '$_': $_ $'\n    'https://unix.stackexchange.com/questions/280453

echo '$@': $@ $'\n    "$1" "$2" ….'
echo '$*': $* $'\n    "$1IFS$2IFS…" '

eval $@
eval $*
