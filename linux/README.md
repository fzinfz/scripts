Examples:

# init.sh (base functions)
  
    [ -f ./init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/init.sh)"

# docker.lib.sh ( docker functions )

    source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/docker.lib.sh)"

# install.sh examples

    ./install.sh -h  # show help
    ./install.sh -i -p=base,VT,docker -f=vscodei
    
    Parameters: ( can be used together )
        -u            # update repo
        -p=base       # dry run for packages will be installed, will grep `$regex_packages`
        -p=base,VT,docker -i  # install packages
        -f=vscodei     # run install_*() functions in script, don't need -i

# Check
Check All

    ./check.sh
    
Source `check_*` functions

    for f in check_*.sh; do echo "# $f"; . $f; cat $f | grep_functions; echo; done
    
