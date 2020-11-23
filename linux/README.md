Examples:

# init.sh (base functions)
  
    [ -f ./init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/init.sh)"


# install.sh examples

    curl -sS https://raw.githubusercontent.com/fzinfz/scripts/master/linux/install.sh | bash -s -- -p=base,dev
    
Parameters: ( can be used together )

        -h            # show help
        -u            # update repo
        -p=...        # dry run for packages will be installed, will grep `$regex_packages`
        -p=base,VT,docker -i  # install packages
        -f=vscodei     # run install_*() functions in script, don't need -i

# Check OS Env

    ./check.sh # local only