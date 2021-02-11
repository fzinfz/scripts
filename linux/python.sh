. ./init.sh &>/dev/null || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

install_py_packages(){

    conda config --add channels conda-forge
    conda install -y \
        pika pyzmq scrapy uwsgi gunicorn django flask bottle hug pyramid python-graphviz \
        pyzmq pymongo pymysql mysql-connector-python psycopg2 sqlite influxdb-client

    pip install fabric2

}

install_kernel_bash(){

    # https://github.com/Calysto/metakernel/tree/master/metakernel_bash
    pip install metakernel_bash

    # https://github.com/takluyver/bash_kernel
    pip install --upgrade pexpect
    pip install bash_kernel
    python -m bash_kernel.install
    
}

install_kernel_py27(){

    conda create --name=py27 python=2.7 -y
    source activate py27
    python2 -m pip install ipykernel
    python2 -m ipykernel install --user
    source deactivate py27

}

unset install

for i in "$@"; do
    case $i in
        -i=*|--install=*)
            install="${i#*=}"
        ;;           
        *)
            echo_error "Unknown Parameter: $i"
        ;;
    esac
done

echo_debug "install=$install"

for func in ${install//,/ }
do
    run "install_$func"
done