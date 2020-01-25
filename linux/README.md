# Source
  
    [ -f ./init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/init.sh)"

# Check functions

    for f in check_*.sh; do echo "# $f"; my_functions $f; echo; done