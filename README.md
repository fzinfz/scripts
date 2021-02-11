# Web Tools in `doc` folder
Plain Text or HTML Table To Markdown converter: https://html.ferro.pro/md.html

# General linux shell scripts

    . ./linux/init.sh && cd FOLDER && ./SCRIPT_NAME.sh

## Templates
- Gen README.md: https://github.com/fzinfz/scripts/blob/master/apps_docker/_gen_README.sh

## install.sh

    curl -sS https://raw.githubusercontent.com/fzinfz/scripts/master/linux/install.sh | bash -s -- -p=base,dev
    
Parameters: ( can be used together )

        -h            # show help
        -u            # update repo
        -p=...        # dry run for packages will be installed, will grep `$regex_packages`
        -p=base,VT,docker -i  # install packages
        -f=vscodei     # run install_*() functions in script, don't need -i
