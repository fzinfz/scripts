# clone latest commit

    git clone --branch master --depth 1 https://github.com/fzinfz/scripts.git

# .sh scripts

    . ./linux/init.sh && cd FOLDER && ./SCRIPT_NAME.sh # only support bash

## install.sh

    curl -sS https://raw.githubusercontent.com/fzinfz/scripts/master/linux/install.sh | bash -s -- -p=base,dev
    
Parameters: ( can be used together )

        -h            # show help
        -u            # update repo
        -p=...        # dry run for packages will be installed, will grep `$regex_packages`
        -p=base,VT,docker -i  # install packages
        -f=vscodei     # run install_*() functions in script, don't need -i
