Examples:

# init.sh (base functions)
  
    [ -f ./init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/init.sh)"

# install.sh

    ./install.sh -i -p=base,VT,docker -f=vscodei

# Check
Check All

    ./check.sh
    
Source `check_*` functions

    for f in check_*.sh; do echo "# $f"; . $f; cat $f | grep_functions; echo; done
    
