[ -f init.sh ] && source init.sh || source /dev/stdin <<< "$(curl -sSL https://raw.githubusercontent.com/fzinfz/scripts/master/linux/init.sh)"

command -v conda >/dev/null 2>/dev/null && cmd_conda=Y

install_packages(){

    conda config --add channels conda-forge
    conda install -y \
        pika pyzmq scrapy uwsgi gunicorn django flask bottle hug pyramid python-graphviz \
        pyzmq pymongo pymysql mysql-connector-python psycopg2 sqlite

    pip install fabric2

}

install_kernel_py27(){

    conda create --name=py27 python=2.7 -y
    source activate py27
    python2 -m pip install ipykernel
    python2 -m ipykernel install --user
    source deactivate py27

}